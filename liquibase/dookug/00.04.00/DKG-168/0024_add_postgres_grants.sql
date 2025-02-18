--liquibase formatted sql

--changeset jozsef.holczer:${schema_name}-add_postgres_grants dbms:postgresql labels:00.04.00
--comment Add missing postgres Schema Grants.

GRANT USAGE ON SCHEMA ${schema_name} TO ${service_name};
GRANT USAGE ON SCHEMA ${schema_name} TO  ${schema_name}_sel;
GRANT ${schema_name}_full TO ${service_name};
