-- =============================================================================
-- 1. CONFIGURATION
-- =============================================================================
\set db_name          'akp_be'
\set db_owner         'dookug'
\set db_owner_pwd     'dookug_pwd'
\set schema_name      'dookug'
\set service_user     'dookug_service'
\set service_pwd      'dookug_pwd'

-- Helper variables for roles
\set role_read        :schema_name '_read'
\set role_write       :schema_name '_write'
\set role_exec        :schema_name '_exec'

-- =============================================================================
-- 2. USER AND DATABASE (RUNS IN POSTGRES DB)
-- =============================================================================

-- Recreate owner
DROP ROLE IF EXISTS :db_owner;
CREATE ROLE :db_owner WITH LOGIN PASSWORD :'db_owner_pwd' CREATEDB CREATEROLE NOSUPERUSER;
-- Immediately after creation, add the NON-superuser (who runs the script) to the dookug role
-- This way postgres will be able to act on its behalf (SET ROLE)
GRANT :db_owner TO CURRENT_USER;

-- Create database (If it already exists, it will throw an error, but the script continues to \c)
-- CREATE DATABASE :db_name OWNER :db_owner;

-- =============================================================================
-- 3. CONNECT TO AKP_BE DB AND OBJECTS
-- =============================================================================
\c :db_name

-- Create schema
CREATE SCHEMA IF NOT EXISTS :schema_name;
ALTER SCHEMA :schema_name OWNER TO :db_owner;

-- Service user
DROP USER IF EXISTS :service_user;
CREATE USER :service_user WITH PASSWORD :'service_pwd';

-- Roles
DROP ROLE IF EXISTS :role_read;
CREATE ROLE :role_read INHERIT;

DROP ROLE IF EXISTS :role_write;
CREATE ROLE :role_write INHERIT;

DROP ROLE IF EXISTS :role_exec;
CREATE ROLE :role_exec INHERIT;

GRANT :role_read TO :role_write;
GRANT :role_write TO :role_exec;

GRANT :role_exec TO :db_owner;
GRANT :role_exec TO :service_user;


-- =============================================================================
-- 4. SYSTEM PERMISSIONS
-- =============================================================================
-- Public schema configuration
ALTER SCHEMA public OWNER TO :db_owner;
GRANT USAGE, CREATE ON SCHEMA public TO :db_owner;

-- Default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO :db_owner;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO :db_owner;

GRANT CONNECT ON DATABASE :db_name TO :db_owner;
GRANT USAGE ON LANGUAGE plpgsql TO :db_owner;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO :db_owner;