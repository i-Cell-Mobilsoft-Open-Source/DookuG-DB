--liquibase formatted sql

--===============================================================================================--
-- ROLE ==
---------------------------------------------------------------------------------------------------
--changeset bertalan.pasztor:${schema_name}-POSTGRES_ROLE dbms:postgresql runOnChange:true
--comment Romoving REPLICATION role from postgres user...
---------------------------------------------------------------------------------------------------

ALTER USER postgres WITH NOREPLICATION;

