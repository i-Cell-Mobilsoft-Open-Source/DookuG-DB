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

--changeset jozsef.holczer:${pg_schema_user}_USER dbms:postgresql runOnChange:true endDelimiter:/
--comment Creating user of the DB project schema...

DO $$
BEGIN 
  
  IF not public.public_role_exists('${pg_schema_user}') THEN
    /*why superuser option?
    If we embed this db (this is the most common scenario) to other host db, then we get the following error without the superuser option:
    Unexpected error running Liquibase: ERROR: relation "databasechangeloglock" already exists
    [Failed SQL: (0) CREATE TABLE public.databasechangeloglock (...);
    So it cannot handle the liquichangelock table without the superuser option
    */
    CREATE USER ${pg_schema_user} WITH SUPERUSER PASSWORD '${schema_password}';
  ELSE
    -- this part is required, b/c though the user exists, but it cannot create the project schema.
    -- User already exists, ensure its password is correct AND it can log in.
    -- We explicitly add LOGIN and SUPERUSER here to ensure the required attributes are set.
    ALTER ROLE ${pg_schema_user} WITH SUPERUSER LOGIN PASSWORD '${schema_password}'; 
  END IF;
  
  -- the following needs later in schema installs.
  -- The following grants are idempotent and can be run unconditionally
  GRANT CREATE ON DATABASE ${database_name} TO ${pg_schema_user};
  GRANT ${schema_name}_exec TO ${pg_schema_user} WITH ADMIN OPTION;  
  
END$$;
/