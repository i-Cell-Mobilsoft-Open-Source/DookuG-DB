--liquibase formatted sql

--===============================================================================================--
-- USER ==
---------------------------------------------------------------------------------------------------
--changeset jozsef.holczer:${schema_name}-SERVICE_USER dbms:postgresql endDelimiter:/
--comment Creating service user of the DB schema...
---------------------------------------------------------------------------------------------------
SET search_path = public;

DO $$
DECLARE
  v_user_name  text := '${service_name}';
BEGIN
     
  -- -- --
  IF not public_user_exists(v_user_name) THEN
    CREATE USER ${service_name} WITH PASSWORD '${schema_password}';
  END IF;
  
END$$;
/

--changeset bertalan.pasztor:${schema_name}-SERVICE_USER_SETPASS dbms:postgresql runOnChange:true endDelimiter:/
--comment DB Service Use password change...
---------------------------------------------------------------------------------------------------
SET search_path = public;

DO $$
BEGIN
  IF '${DB_SERVICE_USER_PASSWORD}' NOT LIKE '${DB_SERVICE_USER_PASS%' THEN
    ALTER USER ${service_name} WITH PASSWORD '${DB_SERVICE_USER_PASSWORD}';
  END IF;
END
$$;
COMMIT;
/



