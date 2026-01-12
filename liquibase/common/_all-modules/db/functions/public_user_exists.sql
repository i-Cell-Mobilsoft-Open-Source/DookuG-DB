--liquibase formatted sql

-- Copyright (c) 2026 i-Cell Mobilsoft Zrt.
--
-- Licensed under the Apache License, Version 2.0 (the "License"); you
-- may not use this file except in compliance with the License. You
-- may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
-- implied. See the License for the specific language governing
-- permissions and limitations under the License.
--
-- SPDX-License-Identifier: Apache-2.0

--changeset endre.balazs:${schema_name}-PUBLIC_USER_EXISTS_FUNCTION dbms:postgresql runOnChange:true endDelimiter:/
--comment Creating public_user_exists function...

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

GRANT EXECUTE ON FUNCTION public.public_user_exists(text) TO ${dba_user_name};

