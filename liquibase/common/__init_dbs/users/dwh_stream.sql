--liquibase formatted sql

--===============================================================================================--
-- USER ==
---------------------------------------------------------------------------------------------------
--changeset bertalan.pasztor:${schema_name}-DWH_STREAM_USER dbms:postgresql runOnChange:true
--comment Creating dwh_stream user...
--
--preconditions onFail:MARK_RAN onError:HALT
--precondition-sql-check expectedResult:0 SELECT count(*) FROM pg_catalog.pg_user WHERE usename = 'dwh_stream'
---------------------------------------------------------------------------------------------------

CREATE USER dwh_stream WITH REPLICATION PASSWORD '${schema_password}';

