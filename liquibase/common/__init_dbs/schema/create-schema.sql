--liquibase formatted sql

--===============================================================================================--
-- SCHEMA ==
---------------------------------------------------------------------------------------------------
--changeset bertalan.pasztor:${schema_name}-CREATE_SCHEMA dbms:postgresql endDelimiter:/
--comment Creating schema...
---------------------------------------------------------------------------------------------------

DO $$
BEGIN

--
  CREATE SCHEMA IF NOT EXISTS ${schema_name} AUTHORIZATION ${dba_user_name};
  GRANT USAGE ON SCHEMA ${schema_name} TO ${schema_name}_read;
  GRANT USAGE ON SCHEMA ${schema_name} TO ${schema_name}_write;
  GRANT USAGE ON SCHEMA ${schema_name} TO ${schema_name}_exec;  
  GRANT USAGE ON SCHEMA ${schema_name} TO ${service_name};
  GRANT USAGE ON SCHEMA ${schema_name} TO  ${schema_name}_sel;

-- Setting the host db service user
  IF '${S2_SCHEMA_NAME}' != '${schema_name}' THEN
    GRANT ${schema_name}_read TO ${service_name};
    GRANT ${schema_name}_write TO ${service_name};
    GRANT ${schema_name}_exec TO ${service_name};
    GRANT ${schema_name}_full TO ${service_name};
  END IF;
END
$$;
COMMIT;
/
