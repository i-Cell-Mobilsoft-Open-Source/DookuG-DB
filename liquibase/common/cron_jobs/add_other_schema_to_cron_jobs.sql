--liquibase formatted sql

--===============================================================================================--
-- EXTENSIONS ==
---------------------------------------------------------------------------------------------------
--changeset jozsef.holczer:${schema_name}-add_to_cron_jobs-ICMV2-245 dbms:postgresql runOnChange:true
--preconditions onFail:MARK_RAN
--precondition-sql-check expectedResult:0 SELECT COUNT(1) FROM CRON.JOB WHERE LOWER(COMMAND) LIKE '%${service_name}%'
--comment Registering schema_name in pg_cron jobs...
---------------------------------------------------------------------------------------------------
SELECT cron.schedule_in_database('${schema_name}_proc_partition_deleter', '@daily', $stmt$CALL public.proc_partition_deleter('${service_name}')$stmt$, '${database_name}');