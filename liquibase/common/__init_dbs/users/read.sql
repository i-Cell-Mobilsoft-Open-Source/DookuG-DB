--liquibase formatted sql

--===============================================================================================--
-- USER ==
---------------------------------------------------------------------------------------------------
--changeset endre.balazs:${schema_name}-READ_USER dbms:postgresql runOnChange:true endDelimiter:/
--comment Creating Read user with limited rights...
---------------------------------------------------------------------------------------------------
SET search_path = public;

DO $$
DECLARE
  v_user_name  text := '${schema_name}_read';
BEGIN
     
  -- -- --
  IF not public_user_exists(v_user_name) THEN
    CREATE USER ${schema_name}_read WITH PASSWORD '${schema_password}';
  END IF;
  
END$$;
/

