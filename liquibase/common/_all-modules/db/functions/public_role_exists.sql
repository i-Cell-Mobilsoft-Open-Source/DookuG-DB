-- Copyright (C) 2025 i-Cell Mobilsoft Zrt.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- SPDX-License-Identifier: Apache-2.0

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

