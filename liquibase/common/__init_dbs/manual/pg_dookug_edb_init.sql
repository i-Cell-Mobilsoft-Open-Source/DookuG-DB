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
\set service_user     'dookug_service'
\set service_pwd      'dookug_pwd'

-- Helper variables for roles
\set role_read        :schema_name '_read'
\set role_write       :schema_name '_write'
\set role_exec        :schema_name '_exec'

-- =============================================================================
-- 2. USER CREATION
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
-- 3. CONNECT TO AKP_BE DB AND ROLES CREATION
-- =============================================================================
\c :db_name

-- to have rights on creating schemas in the database
GRANT CREATE, CONNECT, TEMPORARY ON DATABASE :db_name TO :db_owner;

--the db_owner will create the schema in the liquibase step

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
GRANT USAGE, CREATE ON SCHEMA public TO :db_owner;

-- Default privileges for future tables
ALTER DEFAULT PRIVILEGES FOR ROLE :db_owner IN SCHEMA public GRANT ALL ON TABLES TO :db_owner;
ALTER DEFAULT PRIVILEGES FOR ROLE :db_owner IN SCHEMA public GRANT ALL ON SEQUENCES TO :db_owner;

GRANT CONNECT ON DATABASE :db_name TO :db_owner;
GRANT USAGE ON LANGUAGE plpgsql TO :db_owner;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO :db_owner;