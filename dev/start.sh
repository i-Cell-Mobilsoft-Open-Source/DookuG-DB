#!/bin/bash
# ===============================================================================
# Development database initialization script
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

set -e

# Determine script and project paths and load environment files.
CURRENT_PATH=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(cd "${CURRENT_PATH}/.." && pwd)

set -a

# Load local development environment variables
if [[ -f "${CURRENT_PATH}/.env" ]]; then
    . "${CURRENT_PATH}/.env"
fi

set +a

DOCKER_HOST_ADDR="localhost"
NETWORK_ARG="--network=host"

# Ask which database engine to use
read -r -p "Database engine [postgres/oracle] (default: postgres): " TARGET_ENGINE_INPUT
TARGET_ENGINE=${TARGET_ENGINE_INPUT:-postgres}

# ===============================================================================
# LOGGING
# ===============================================================================
print_section() {
    echo -e "\n================================================================================"
    echo ">>> $1"
    echo -e "================================================================================\n"
}

# Initializes the Postgres environment: starts the container, waits for it to
# start, and creates the project database and user.
init_postgres() {
    print_section "INITIALIZING POSTGRESQL CONTAINER & DATABASE"
    
    if docker inspect -f '{{.State.Running}}' "${CONTAINER_NAME}" 2>/dev/null | grep -q "true"; then
      echo "Container ${CONTAINER_NAME} is already running, skipping docker compose up."
    else
      echo "Starting local Postgres container..."
      docker compose -f "${CURRENT_PATH}/docker-compose.yaml" up -d postgres --build --force-recreate --remove-orphans
    fi

    echo "Waiting for PostgreSQL to start..."
    until docker exec "${CONTAINER_NAME}" pg_isready -U "postgres" >/dev/null 2>&1; do
      sleep 1
    done
    echo "PostgreSQL is ready!"

    echo "Checking / Creating user role: ${DB_OWNER}..."
    docker exec -e PGPASSWORD="${PGPASSWORD}" "${CONTAINER_NAME}" \
      psql -U "postgres" -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='${DB_OWNER}'" \
      | grep -q 1 || \
    docker exec -e PGPASSWORD="${PGPASSWORD}" "${CONTAINER_NAME}" \
      psql -U "postgres" -d postgres -c "CREATE USER \"${DB_OWNER}\" WITH PASSWORD '${DB_OWNER_PASSW}' CREATEROLE;"

    echo "Checking / Creating database: ${DB_NAME}..."
    docker exec -e PGPASSWORD="${PGPASSWORD}" "${CONTAINER_NAME}" \
        psql -U "postgres" -d postgres -tc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" \
        | grep -q 1 || \
    docker exec -e PGPASSWORD="${PGPASSWORD}" "${CONTAINER_NAME}" \
        psql -U "postgres" -d postgres -c "CREATE DATABASE \"${DB_NAME}\" WITH OWNER=\"${DB_OWNER}\" TEMPLATE = 'template0' ENCODING='${ENCODING}' LC_COLLATE = '${LC_COLLATE}' LC_CTYPE = '${LC_CTYPE}';"

    # Connection settings for Liquibase (Postgres)
    JDBC_URL="jdbc:postgresql://${DOCKER_HOST_ADDR}:${LOCAL_PORT}/${DB_NAME}"
    CRESCHEMA_USER="${DB_OWNER}"
    CRESCHEMA_PASS="${DB_OWNER_PASSW}"
}

# Initializes the Oracle environment: starts the XE container, waits for the
# boot process to complete, and configures administrator access.
init_oracle() {
    print_section "INITIALIZING ORACLE XE CONTAINER"
    
    if docker inspect -f '{{.State.Running}}' "${ORACLE_CONTAINER_NAME}" 2>/dev/null | grep -q "true"; then
      echo "Container ${ORACLE_CONTAINER_NAME} is already running, skipping docker compose up."
    else
      echo "Starting local Oracle container..."
      docker compose -f "${CURRENT_PATH}/docker-compose.yaml" up -d oracle --build --force-recreate --remove-orphans
    fi

    echo "Waiting for Oracle DB start... (This might take a few minutes)"
    until docker exec -i "${ORACLE_CONTAINER_NAME}" sqlplus -S sys/${ORACLE_PASSWORD}@localhost:1521/XEPDB1 as sysdba <<< "SELECT 1 FROM DUAL;" 2>/dev/null | grep -q -w "1"; do
      sleep 5
      echo -n "."
    done
    echo -e "\nOracle DB is ready!"

    # Connection settings for Liquibase (Oracle)
    JDBC_URL="jdbc:oracle:thin:@//${DOCKER_HOST_ADDR}:${ORACLE_PORT}/XEPDB1"
    CRESCHEMA_USER="SYSTEM"
    CRESCHEMA_PASS="${ORACLE_PASSWORD}"
}

SCHEMA_ARRAY=(dookug)

# Installs the schemas and database tables for the specified schema.
run_install() {
    local schema="$1"

    local SCHEMA_UPPER=$(echo "${schema}" | tr '[:lower:]' '[:upper:]')
    local SCHEMA_PASSW_VAR="${SCHEMA_UPPER}_PASSWORD"
    local SCHEMA_SERVICE_PASSW_VAR="${SCHEMA_UPPER}_SERVICE_PASSWORD"
    local SCHEMA_PASSW="${!SCHEMA_PASSW_VAR}"
    local SCHEMA_SERVICE_PASSW="${!SCHEMA_SERVICE_PASSW_VAR}"

    print_section "1. STEP: Creating database schemas and privileges - Schema: ${schema}"
    docker run --rm \
      ${NETWORK_ARG} \
      -v $(pwd)/../docker/dookug_db/${schema}_creschema/liquibase:/liquibase/changelog \
      "${LIQUIBASE_IMAGE}" \
      --show-banner=false \
      --url="${JDBC_URL}" \
      --username="${CRESCHEMA_USER}" \
      --password="${CRESCHEMA_PASS}" \
      --changeLogFile="changelog/${schema}_creschema-master.xml" \
      --secureParsing=false \
      --database-changelog-lock-table-name=${schema}_dbchloglock \
      --database-changelog-table-name=${schema}_dbchlog \
      update \
      -D${schema}_password="${SCHEMA_PASSW}" \
      -D${schema}_service_password="${SCHEMA_SERVICE_PASSW}"

    print_section "2. STEP: Schema migration (update) - Schema: ${schema}"
    docker run --rm \
      ${NETWORK_ARG} \
      -v $(pwd)/../docker/dookug_db/${schema}/liquibase:/liquibase/changelog \
      -v $(pwd)/../docker/common:/liquibase/common \
      "${LIQUIBASE_IMAGE}" \
      --show-banner=false \
      --url="${JDBC_URL}" \
      --username="${schema}" \
      --password="${SCHEMA_PASSW}" \
      --changeLogFile="changelog/${schema}-master.xml" \
      --secureParsing=false \
      update 
}

if [[ "${TARGET_ENGINE}" == "postgres" ]]; then
    init_postgres
elif [[ "${TARGET_ENGINE}" == "oracle" ]]; then
    init_oracle
else
    echo "Unsupported database engine: ${TARGET_ENGINE}"
    exit 1
fi

for schema in "${SCHEMA_ARRAY[@]}"; do
    run_install "$schema"
done

echo "[END] Database setup complete for ${TARGET_ENGINE}."
