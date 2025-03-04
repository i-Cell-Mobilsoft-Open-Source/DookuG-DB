-- Copyright (C) 2025 i-Cell Mobilsoft Zrt.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- SPDX-License-Identifier: Apache-2.0

--liquibase formatted sql

--===============================================================================================--
-- EXTENSIONS ==
---------------------------------------------------------------------------------------------------
--changeset jozsef.holczer:${schema_name}-PG_CRON-MLFFDEV-10151-01 dbms:postgresql runOnChange:true endDelimiter:/
--comment pg_cron extension install
---------------------------------------------------------------------------------------------------
-- The CRON extension can only be installed in default Postgres DB (blackbox)
-- This part comes into the picture during embedding the DB into another DB. 
/*If you want to install it into another "project" DB, you get the following or similar error message:
    Migration failed for changeset cron_jobs/init_cron_jobs.sql::...:
    Reason: liquibase.exception.DatabaseException: ERROR: can only create extension in database postgres
    Detail: Jobs must be scheduled from the database configured in cron.database_name, since the pg_cron background worker reads job descriptions from this database.
    Hint: Add cron.database_name...
*/
DO $$
BEGIN
    --The CREATE_DATABASE env variable is declared and explained in before-liquibase.sql
    IF ${CREATE_DATABASE} = true THEN
        CREATE extension IF NOT EXISTS pg_cron;
    END IF;
END
$$;
/

