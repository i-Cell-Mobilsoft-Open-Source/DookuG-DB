--liquibase formatted sql

--===============================================================================================--
-- EXTENSIONS ==
---------------------------------------------------------------------------------------------------
--changeset jozsef.holczer:${schema_name}-SCHEDULE_CRONJOB_PART_MAINTENANCE-ICMV2-204-01 dbms:postgresql runOnChange:true endDelimiter:/
--comment Init pg_cron job...
---------------------------------------------------------------------------------------------------
-- The CRON extension can only be installed in default Postgres DB (blackbox)
-- This part comes into the picture during embedding the DB into another DB. 
/*If you want to install it into another "project" DB, you get the following or similar error message:
    Migration failed for changeset cron_jobs/init_cron_jobs.sql::...:
    Reason: liquibase.exception.DatabaseException: ERROR: can only create extension in database postgres
    Detail: Jobs must be scheduled from the database configured in cron.database_name, since the pg_cron background worker reads job descriptions from this database.
    Hint: Add cron.database_name...
*/
DO $do$
BEGIN
    --The CREATE_DATABASE env variable is declared and explained in before-liquibase.sql
    IF ${CREATE_DATABASE} = true THEN

        CREATE extension IF NOT EXISTS pg_cron; 

        --I do not want to delete the previously inserted jobs because the host db already put its records there.
        --DELETE FROM cron.job;

        --Why PERFORM?
        /*The SELECT drops this error:
            liquibase.exception.DatabaseException: ERROR: query has no destination for result data
            Hint: If you want to discard the results of a SELECT, use PERFORM instead.
            Where: PL/pgSQL function inline_code_block line 9 at SQL statement 
        */
        PERFORM cron.schedule_in_database('run_maintenance', '@daily', $stmt$SELECT partman.run_maintenance(p_analyze := false)$stmt$, '${database_name}'); 
        PERFORM cron.schedule_in_database('${schema_name}_proc_partition_deleter', '@daily', $stmt$CALL public.proc_partition_deleter('${service_name}')$stmt$, '${database_name}'); 

    END IF;
END 
$do$;
/