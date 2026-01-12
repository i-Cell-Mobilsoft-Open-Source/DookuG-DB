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

--changeset bertalan.pasztor:${schema_name}-CREATE_DATABASE runInTransaction:false dbms:postgresql
--comment Creating dookug DB...

--preconditions onFail:MARK_RAN onError:MARK_RAN
--precondition-sql-check expectedResult:0 SELECT count(*) FROM pg_catalog.pg_database WHERE datname = 'dookug_db'
--precondition-sql-check expectedResult:t SELECT ${CREATE_DATABASE} = true

-- Explanation of the above precondition:
/*
The database (DB) is always executed in the default PostgreSQL database.
However, there will be cases where we "embed" the DOOKUG-DB into another database, 
in such cases, the DOOKUG DB objects must be deployed into the other Postgres DB, eliminating the need for this "empty" DOOKUG-DB.

I changed the onError attribute to MARK_RAN because this was the only way to "force" Liquibase to skip this step.
The second precondition receives a false value externally during execution, but since it expects a true result, 
it would throw an error and halt with the previous attribute setting (HALT).

Unfortunately, the CREATE DATABASE command cannot be placed inside an anonymous block and combined with an IF condition (as we did in create_extension.sql).
*/

CREATE DATABASE ${database_name} WITH 
  OWNER = ${dba_user_name}
  ENCODING = 'UTF8'
  CONNECTION LIMIT = -1;
