--liquibase formatted sql

---------------------------------------------------------------------------------------------------
--changeset endre.balazs:${schema_name}-PUBLIC_ROLE_EXISTS_FUNCTION dbms:postgresql runOnChange:true endDelimiter:/
--comment Creating public_role_exists function...
---------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.public_role_exists(text);

CREATE OR REPLACE FUNCTION public.public_role_exists(p_role_name text)
 RETURNS BOOLEAN
 LANGUAGE PLPGSQL
AS $FUNCTION$
DECLARE
  cnt int;
BEGIN

  cnt := -1;
  SELECT count(*) INTO cnt 
    FROM pg_catalog.pg_roles
   WHERE rolname = p_role_name;

  RETURN cnt = 1;
  
END;
$FUNCTION$
;
/

-- Permissions

ALTER FUNCTION public.public_role_exists(text) OWNER TO ${dba_user_name};

GRANT EXECUTE ON FUNCTION public.public_role_exists(text) TO ${dba_user_name};

