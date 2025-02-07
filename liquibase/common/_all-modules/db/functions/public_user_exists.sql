--liquibase formatted sql

---------------------------------------------------------------------------------------------------
--changeset endre.balazs:${schema_name}-PUBLIC_USER_EXISTS_FUNCTION dbms:postgresql runOnChange:true endDelimiter:/
--comment Creating public_user_exists function...
---------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.public_user_exists(text);

CREATE OR REPLACE FUNCTION public.public_user_exists(p_user_name text)
 RETURNS BOOLEAN
 LANGUAGE PLPGSQL
AS $FUNCTION$
DECLARE
  cnt int;
BEGIN

  cnt := -1;
  SELECT count(*) INTO cnt 
    FROM pg_catalog.pg_user
   WHERE usename = p_user_name;

  RETURN cnt = 1;
  
END;
$FUNCTION$
;
/

-- Permissions

ALTER FUNCTION public.public_user_exists(text) OWNER TO ${dba_user_name};

GRANT EXECUTE ON FUNCTION public.public_user_exists(text) TO ${dba_user_name};

