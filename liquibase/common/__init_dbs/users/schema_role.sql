--liquibase formatted sql

--===============================================================================================--
-- USER ==
---------------------------------------------------------------------------------------------------
--changeset bertalan.pasztor:${schema_name}-AUTH_ROLE dbms:postgresql 
--comment Creating DB schema role..
--
--preconditions onFail:MARK_RAN onError:HALT
--precondition-sql-check expectedResult:0 SELECT count(*) FROM pg_catalog.pg_roles WHERE rolname = '${schema_name}'
---------------------------------------------------------------------------------------------------
CREATE ROLE ${schema_name};

COMMIT;


