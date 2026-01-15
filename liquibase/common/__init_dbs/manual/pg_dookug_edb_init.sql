-- Copyright (c) 2026 i-Cell Mobilsoft Zrt.
--
-- Licensed under the Apache License, Version 2.0 (the "License"); you
-- may not use this file except in compliance with the License. You
-- may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
-- implied. See the License for the specific language governing
-- permissions and limitations under the License.
--
-- SPDX-License-Identifier: Apache-2.0

-- =============================================================================
-- 1. CONFIGURATION
-- =============================================================================
\set db_name          'akp_be'
\set db_owner         'dookug'
\set db_owner_pwd     'dookug_pwd'
\set schema_name      'dookug'
\set service_user     :schema_name '_service'
\set service_pwd      'dookug_pwd'
\set module_user_role 'module_user'
\set role_read        :schema_name '_read'
\set role_write       :schema_name '_write'
\set role_exec        :schema_name '_exec'

\echo '>>>> Block 1: Configuration initialized.'
\echo '-----------------------------------------'

-- =============================================================================
-- 2. USER CREATION (POSTGRES DB)
-- =============================================================================
\echo '>>>> Block 2: Starting User and Database Configuration in postgres db'

SELECT count(*) = 0 AS is_empty FROM pg_catalog.pg_roles WHERE rolname = :'db_owner' \gset
\if :is_empty
    \echo '--- Creating owner role: ' :db_owner
    CREATE ROLE :db_owner WITH LOGIN PASSWORD :'db_owner_pwd' CREATEDB CREATEROLE NOSUPERUSER;
\endif

GRANT :db_owner TO CURRENT_USER;

-- =============================================================================
-- 3. CONNECT TO TARGET DB AND ROLES CREATION
-- =============================================================================
\echo '-----------------------------------------'
\c :db_name
\echo '>>>> Block 3: Connected to database: ' :db_name

GRANT CREATE, CONNECT, TEMPORARY ON DATABASE :db_name TO :db_owner;

\echo '-----------------------------------------'
\echo '--- Creating service user and module roles'
SELECT count(*) = 0 AS is_empty_svc FROM pg_catalog.pg_roles WHERE rolname = :'service_user' \gset
\if :is_empty_svc
    CREATE USER :service_user WITH PASSWORD :'service_pwd';
\endif

SELECT count(*) = 0 AS is_empty_mod FROM pg_catalog.pg_roles WHERE rolname = :'module_user_role' \gset
\if :is_empty_mod
    CREATE ROLE :module_user_role;
\endif

\echo '-----------------------------------------'
\echo '--- Creating access roles (Read, Write, Exec)'
SELECT count(*) = 0 AS no_read FROM pg_catalog.pg_roles WHERE rolname = :'role_read' \gset
\if :no_read
    CREATE ROLE :role_read INHERIT;
\endif

SELECT count(*) = 0 AS no_write FROM pg_catalog.pg_roles WHERE rolname = :'role_write' \gset
\if :no_write
    CREATE ROLE :role_write INHERIT;
\endif

SELECT count(*) = 0 AS no_exec FROM pg_catalog.pg_roles WHERE rolname = :'role_exec' \gset
\if :no_exec
    CREATE ROLE :role_exec INHERIT;
\endif

GRANT :role_read TO :role_write;
GRANT :role_write TO :role_exec;
GRANT :role_exec TO :db_owner;
GRANT :role_exec TO :service_user;


--====================== PUBLIC Schema ===================================================
\echo '-----------------------------------------'
\echo '>>>> Block 4: Configuring PUBLIC schema shared access'

SET custom.module_user_role = :'module_user_role';

GRANT USAGE, CREATE ON SCHEMA public TO :module_user_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO :module_user_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO :module_user_role;

DO $$
DECLARE
    v_role text := current_setting('custom.module_user_role');
BEGIN
    RAISE NOTICE '--- Granting access to existing Liquibase tables in public schema';
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'databasechangelog') THEN
        EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.databasechangelog TO %I', v_role);
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'databasechangeloglock') THEN
        EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.databasechangeloglock TO %I', v_role);
    END IF;
END $$;

\echo '-----------------------------------------'
\echo '--- Configuring ownership and execute rights for public functions'
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO :module_user_role;

DO $$
DECLARE
    v_role text := current_setting('custom.module_user_role');
BEGIN
    IF EXISTS (SELECT 1 FROM pg_proc n JOIN pg_namespace m ON n.pronamespace = m.oid 
               WHERE m.nspname = 'public' AND n.proname = 'public_role_exists') THEN
        RAISE NOTICE '--- Transferring owner of public.public_role_exists to %', v_role;
        EXECUTE format('ALTER FUNCTION public.public_role_exists(text) OWNER TO %I', v_role);
        EXECUTE format('GRANT EXECUTE ON FUNCTION public.public_role_exists(text) TO %I', v_role);
    END IF;

    IF EXISTS (SELECT 1 FROM pg_proc n JOIN pg_namespace m ON n.pronamespace = m.oid 
               WHERE m.nspname = 'public' AND n.proname = 'public_user_exists') THEN
        RAISE NOTICE '--- Transferring owner of public.public_user_exists to %', v_role;
        EXECUTE format('ALTER FUNCTION public.public_user_exists(text) OWNER TO %I', v_role);
        EXECUTE format('GRANT EXECUTE ON FUNCTION public.public_user_exists(text) TO %I', v_role);
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_proc n JOIN pg_namespace m ON n.pronamespace = m.oid 
               WHERE m.nspname = 'public' AND n.proname = 'proc_partition_deleter') THEN
        RAISE NOTICE '--- Transferring owner of public.proc_partition_deleter to %', v_role;
        EXECUTE format('ALTER PROCEDURE public.proc_partition_deleter(text) OWNER TO %I', v_role);
    END IF;
END $$;

--====================== PARTMAN Schema ===================================================
\echo '-----------------------------------------'
\echo '>>>> Block 5: Configuring PARTMAN schema access (USAGE, CREATE, SELECT, INSERT)'

-- 1. Séma szintű jogok (Kell a CREATE is a belső műveletekhez!)
\echo '--- Granting USAGE and CREATE on partman schema'
GRANT USAGE, CREATE ON SCHEMA partman TO :module_user_role;

-- 2. Függvények futtatása
\echo '--- Granting EXECUTE on partman functions'
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA partman TO :module_user_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA partman GRANT EXECUTE ON FUNCTIONS TO :module_user_role;

-- 3. Táblák és Szekvenciák kezelése (Írási jog a konfigurációs táblákra)
\echo '--- Granting read/write on partman tables and sequences'
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA partman TO :module_user_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA partman TO :module_user_role;

-- 4. Alapértelmezett jogok a jövőre nézve
ALTER DEFAULT PRIVILEGES IN SCHEMA partman GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :module_user_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA partman GRANT USAGE, SELECT ON SEQUENCES TO :module_user_role;

-- 5. Ellenőrző üzenet PL/pgSQL blokkal
DO $$
DECLARE
    v_role text := current_setting('custom.module_user_role');
BEGIN
    RAISE NOTICE '--- Rights for % on PARTMAN schema synchronized ---', v_role;
END $$;

--current db owner inherits permissions from module role
ALTER ROLE :db_owner INHERIT;
GRANT :module_user_role TO :db_owner;

-- =============================================================================
-- 4-5. CRON CONFIGURATION (Must be run in 'postgres' database)
-- =============================================================================
\c postgres
\echo '-----------------------------------------'
\echo '>>>> Block 6: Configuring CRON jobs in postgres database'

SET custom.service_user = :'service_user';
SET custom.db_name = :'db_name';
SET custom.schema_name = :'schema_name';

DO $$
DECLARE
    v_svc    text := current_setting('custom.service_user');
    v_db     text := current_setting('custom.db_name');
    v_schema text := current_setting('custom.schema_name');
    v_job    text := v_schema || '_proc_partition_deleter';
    v_maint  text := 'run_maintenance';
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'cron') THEN
        RAISE NOTICE '--- Managing cron jobs for schema: %', v_schema;
        IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = v_job) THEN
            PERFORM cron.unschedule(v_job);
            RAISE NOTICE '--- Old job % unscheduled', v_job;
        END IF;
        
        IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = v_maint) THEN
            PERFORM cron.unschedule(v_maint);
            RAISE NOTICE '--- Old job % unscheduled', v_maint;
        END IF;

        PERFORM cron.schedule_in_database(v_job, '@daily', format('CALL public.proc_partition_deleter(%L)', v_svc), v_db);
        PERFORM cron.schedule_in_database(v_maint, '@daily', 'SELECT partman.run_maintenance(p_analyze := false)', v_db);
        
        RAISE NOTICE '--- Cron jobs successfully scheduled for database: %', v_db;
    ELSE
        RAISE EXCEPTION 'Schema "cron" not found!';
    END IF;
END $$;

\echo '-----------------------------------------'
\echo '>>>> Init script execution finished successfully.'