# ===============================================================================
# Development database initialization script (PowerShell)
#
# Main features:
# - Supports Postgres and Oracle for starting a local container.
# - Runs Liquibase migrations.
#
# In the local development environment, no image is built to run Liquibase.
# Instead, the script mounts the XML/SQL files from the local filesystem into
# the Liquibase container. This is better and faster for local development because
# project-specific Liquibase Docker images do not need to be rebuilt when changelog
# files change. On every run, the script uses and applies the latest local files.
#
# ===============================================================================

$ErrorActionPreference = "Stop"

$CURRENT_PATH = $PSScriptRoot
$PROJECT_ROOT = (Resolve-Path "$CURRENT_PATH\..").Path

# Load environment variables
$envFiles = @("$CURRENT_PATH\.env")
foreach ($file in $envFiles) {
    if (Test-Path $file) {
        Get-Content $file | ForEach-Object {
            if ($_ -match "^\s*([^#\s][^=]*?)\s*=\s*(.*)$") {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                # Remove quotes if they exist around the value
                if ($value.StartsWith('"') -and $value.EndsWith('"')) {
                    $value = $value.Substring(1, $value.Length - 2)
                }
                # Handle ${VAR} substitutions in the value (basic)
                if ($value -match '\$\{([^}]+)\}') {
                    $envVar = $matches[1]
                    $envVal = [System.Environment]::GetEnvironmentVariable($envVar)
                    if ($envVal) {
                        $value = $value -replace "\$\{$envVar\}", $envVal
                    }
                }
                [System.Environment]::SetEnvironmentVariable($key, $value)
            }
        }
    }
}

$TARGET_ENGINE = "postgres"
$targetEngineInput = Read-Host "Database engine [postgres/oracle/edb] (default: postgres)"
if (-not [string]::IsNullOrWhiteSpace($targetEngineInput)) {
    $TARGET_ENGINE = $targetEngineInput
}

# On Windows, Docker Desktop reaches the host at host.docker.internal.
$DOCKER_HOST_ADDR = "host.docker.internal"

# ===============================================================================
# LOGGING AND BANNER HELPERS
# ===============================================================================
$script:LIQUIBASE_BANNER_ARG = ""

function Disable-SubsequentBanners {
    $script:LIQUIBASE_BANNER_ARG = "--show-banner=false"
}

function Print-Section {
    param ([string]$title)
    Write-Host ""
    Write-Host "================================================================================"
    Write-Host ">>> $title"
    Write-Host "================================================================================"
    Write-Host ""
}

# Initializes the Postgres environment: starts the container, waits for it to
# become ready, and creates the project database and user.
function Init-Postgres {
    Print-Section "INITIALIZING POSTGRESQL CONTAINER & DATABASE"
    
    $isContainerRunning = docker inspect -f '{{.State.Running}}' "$env:CONTAINER_NAME" 2>$null
    if ($isContainerRunning -match "true") {
        Write-Host "Container $env:CONTAINER_NAME is already running, skipping docker compose up."
    } else {
        Write-Host "Starting local Postgres container..."
        docker compose -f "$CURRENT_PATH\docker-compose.yaml" up -d postgres --build --force-recreate --remove-orphans
    }

    Write-Host "Waiting for PostgreSQL to start..."
    while ($true) {
        docker exec "$env:CONTAINER_NAME" pg_isready -U postgres *> $null 2>&1
        if ($LASTEXITCODE -eq 0) { break }
        Start-Sleep -Seconds 1
    }
    Write-Host "PostgreSQL is ready!"

    Write-Host "Checking / Creating user role: $env:DB_OWNER..."

    $result = docker exec -e PGPASSWORD="$env:PGPASSWORD" "$env:CONTAINER_NAME" `
        psql -U postgres -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='$env:DB_OWNER'"

    if (-not ($result -match "1")) {
        docker exec -e PGPASSWORD="$env:PGPASSWORD" "$env:CONTAINER_NAME" `
            psql -U postgres -d postgres -c "CREATE USER `"$env:DB_OWNER`" WITH PASSWORD '$env:DB_OWNER_PASSW' CREATEROLE;"
    }

    Write-Host "Checking / Creating database: $env:DB_NAME..."
    $result = docker exec -e PGPASSWORD="$env:PGPASSWORD" "$env:CONTAINER_NAME" `
        psql -U postgres -d postgres -tc "SELECT 1 FROM pg_database WHERE datname='$env:DB_NAME'"

    if (-not ($result -match "1")) {
        docker exec -e PGPASSWORD="$env:PGPASSWORD" "$env:CONTAINER_NAME" `
            psql -U postgres -d postgres -c "CREATE DATABASE `"$env:DB_NAME`" WITH OWNER=`"$env:DB_OWNER`" TEMPLATE='template0' ENCODING='$env:ENCODING' LC_COLLATE='$env:LC_COLLATE' LC_CTYPE='$env:LC_CTYPE';"
    }

    $script:JDBC_URL = "jdbc:postgresql://${DOCKER_HOST_ADDR}:$env:LOCAL_PORT/$env:DB_NAME"
    $script:CRESCHEMA_USER = $env:DB_OWNER
    $script:CRESCHEMA_PASS = $env:DB_OWNER_PASSW
}

# Initializes the Oracle environment: starts the XE container, waits for the
# boot process to complete, and configures administrator access.
function Init-Oracle {
    Print-Section "INITIALIZING ORACLE XE CONTAINER"
    
    $isContainerRunning = docker inspect -f '{{.State.Running}}' "$env:ORACLE_CONTAINER_NAME" 2>$null
    if ($isContainerRunning -match "true") {
        Write-Host "Container $env:ORACLE_CONTAINER_NAME is already running, skipping docker compose up."
    } else {
        Write-Host "Starting local Oracle container..."
        docker compose -f "$CURRENT_PATH\docker-compose.yaml" up -d oracle --build --force-recreate --remove-orphans
    }

    Write-Host "Waiting for Oracle DB start... (This might take a few minutes)"
    while ($true) {
        $sqlResult = "SELECT 1 FROM DUAL;" | docker exec -i "$env:ORACLE_CONTAINER_NAME" sqlplus -S "sys/$env:ORACLE_PASSWORD@localhost:1521/XEPDB1 as sysdba" 2>&1
        if ($sqlResult -match "1") { break }
        Write-Host -NoNewline "."
        Start-Sleep -Seconds 5
    }
    Write-Host "`nOracle DB is ready!"

    $script:JDBC_URL = "jdbc:oracle:thin:@//${DOCKER_HOST_ADDR}:$env:ORACLE_PORT/XEPDB1"
    $script:CRESCHEMA_USER = "SYSTEM"
    $script:CRESCHEMA_PASS = $env:ORACLE_PASSWORD
}

# Runs the installation for the specified schema.
# First creates the database objects (creschema), then the project-specific tables.
function Run-Install {
    param ([string]$schema)
    $TARGET_ENGINE_UPPER = $TARGET_ENGINE.ToUpper()

    # Resolve passwords dynamically
    $SCHEMA_UPPER = $schema.ToUpper()
    $SCHEMA_PASSW_VAR = "${SCHEMA_UPPER}_PASSWORD"
    $SCHEMA_SERVICE_PASSW_VAR = "${SCHEMA_UPPER}_SERVICE_PASSWORD"
    
    $SCHEMA_PASSW = [System.Environment]::GetEnvironmentVariable($SCHEMA_PASSW_VAR)
    $SCHEMA_SERVICE_PASSW = [System.Environment]::GetEnvironmentVariable($SCHEMA_SERVICE_PASSW_VAR)

    Print-Section "[FRESH][$TARGET_ENGINE_UPPER] STEP 1: Create database schemas and permissions (creschema) - Schema: ${schema}"
    
    $dockerArgsCreschema = @("run", "--rm")
    $dockerArgsCreschema += "-v", "${PROJECT_ROOT}/docker/dookug_db/${schema}_creschema/liquibase:/liquibase/changelog"
    $dockerArgsCreschema += $env:DOCKER_RUNTIME_LIQUIBASE
    if (-not [string]::IsNullOrEmpty($script:LIQUIBASE_BANNER_ARG)) {
        $dockerArgsCreschema += $script:LIQUIBASE_BANNER_ARG
    }
    $dockerArgsCreschema += "--url=$JDBC_URL"
    $dockerArgsCreschema += "--username=$CRESCHEMA_USER"
    $dockerArgsCreschema += "--password=$CRESCHEMA_PASS"
    $dockerArgsCreschema += "--changeLogFile=changelog/${schema}_creschema-master.xml"
    $dockerArgsCreschema += "--secureParsing=false"
    $dockerArgsCreschema += "--database-changelog-lock-table-name=${schema}_dbchloglock"
    $dockerArgsCreschema += "--database-changelog-table-name=${schema}_dbchlog"
    $dockerArgsCreschema += "update"
    $dockerArgsCreschema += "-D${schema}_password=${SCHEMA_PASSW}"
    $dockerArgsCreschema += "-D${schema}_service_password=${SCHEMA_SERVICE_PASSW}"

    docker $dockerArgsCreschema

    Disable-SubsequentBanners

    Print-Section "[FRESH][$TARGET_ENGINE_UPPER] STEP 2: Install database tables and data (update) - Schema: ${schema}"
    
    $dockerArgsSchema = @("run", "--rm")
    $dockerArgsSchema += "-v", "${PROJECT_ROOT}/docker/dookug_db/${schema}/liquibase:/liquibase/changelog"
    $dockerArgsSchema += "-v", "${PROJECT_ROOT}/docker/common:/liquibase/common"
    $dockerArgsSchema += $env:DOCKER_RUNTIME_LIQUIBASE
    if (-not [string]::IsNullOrEmpty($script:LIQUIBASE_BANNER_ARG)) {
        $dockerArgsSchema += $script:LIQUIBASE_BANNER_ARG
    }
    $dockerArgsSchema += "--url=$JDBC_URL"
    $dockerArgsSchema += "--username=$schema"
    $dockerArgsSchema += "--password=$SCHEMA_PASSW"
    $dockerArgsSchema += "--changeLogFile=changelog/${schema}-master.xml"
    $dockerArgsSchema += "--secureParsing=false"
    $dockerArgsSchema += "update"

    docker $dockerArgsSchema
}

$schemas = @("dookug")

# ===============================================================================
# MAIN EXECUTION
# ===============================================================================

if ($TARGET_ENGINE -eq "postgres") {
    Init-Postgres
} elseif ($TARGET_ENGINE -eq "oracle") {
    Init-Oracle
} else {
    Write-Host "Unsupported database engine: $TARGET_ENGINE"
    exit 1
}

foreach ($schema in $schemas) {
   Run-Install -schema $schema
}

Write-Host "[END] Database setup complete for $TARGET_ENGINE."