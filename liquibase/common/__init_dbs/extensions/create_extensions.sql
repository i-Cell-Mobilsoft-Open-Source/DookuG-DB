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

