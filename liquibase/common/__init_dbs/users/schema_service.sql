--liquibase formatted sql

-----------------------------------------------------------------------
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
-----------------------------------------------------------------------

--changeset jozsef.holczer:${schema_name}-SERVICE_USER dbms:postgresql endDelimiter:/
--comment Creating service user of the DB schema...

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



