--liquibase formatted sql

-- Copyright (c) 2025 i-Cell Mobilsoft Zrt.
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

--changeset jozsef.holczer:${schema_name}-PG_SCHEMA_ROLES dbms:postgresql runOnChange:true endDelimiter:/
--comment Creating Postgresql Schema Roles...

DO $$ 
BEGIN 
  IF NOT public_role_exists('${schema_name}_read') THEN
    CREATE ROLE ${schema_name}_read INHERIT;
  END IF;
  --
  IF NOT public_role_exists('${schema_name}_write') THEN
    CREATE ROLE ${schema_name}_write INHERIT;
  END IF;
  --
  IF NOT public_role_exists('${schema_name}_exec') THEN
    CREATE ROLE ${schema_name}_exec INHERIT;
  END IF;
  --
  GRANT ${schema_name}_read TO ${schema_name}_write;
  GRANT ${schema_name}_write TO ${schema_name}_exec;
END $$;
/

--changeset jozsef.holczer:${schema_name}-ORA_SCHEMA_ROLES dbms:oracle endDelimiter:/
--comment Creating Oracle Schema Roles...
---------------------------------------------------------------------------------------------------
BEGIN
  FOR r IN (SELECT 1 FROM dba_roles WHERE UPPER(role) = UPPER('${schema_name}_read')) LOOP
    RETURN;
  END LOOP;

  EXECUTE IMMEDIATE 'CREATE ROLE ' || UPPER('${schema_name}_read');
END;
/

BEGIN
  FOR r IN (SELECT 1 FROM dba_roles WHERE UPPER(role) = UPPER('${schema_name}_write')) LOOP
    RETURN;
  END LOOP;

  EXECUTE IMMEDIATE 'CREATE ROLE ' || UPPER('${schema_name}_write');
END;
/

BEGIN
  FOR r IN (SELECT 1 FROM dba_roles WHERE UPPER(role) = UPPER('${schema_name}_exec')) LOOP
    RETURN;
  END LOOP;

  EXECUTE IMMEDIATE 'CREATE ROLE ' || UPPER('${schema_name}_exec');
END;
/