--liquibase formatted sql
--changeset jozsef.holczer:${schema_name}-ORA_GRANTS dbms:oracle
--comment "Creating oracle grants..."

GRANT ${schema_name}_write TO ${schema_name}_exec;
GRANT ${schema_name}_read TO ${schema_name}_write;
GRANT ${schema_name}_exec TO ${schema_name}_service;
