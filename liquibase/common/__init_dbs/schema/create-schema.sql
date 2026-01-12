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

--changeset bertalan.pasztor:${schema_name}-CREATE_SCHEMA dbms:postgresql runOnChange:true endDelimiter:/
--comment Creating schema...

SET search_path = public;

DO $$
BEGIN

--
  CREATE SCHEMA IF NOT EXISTS ${schema_name};
  GRANT USAGE ON SCHEMA ${schema_name} TO ${schema_name}_read;
  GRANT USAGE ON SCHEMA ${schema_name} TO ${schema_name}_write;
  GRANT USAGE ON SCHEMA ${schema_name} TO ${schema_name}_exec;  
  GRANT USAGE ON SCHEMA ${schema_name} TO ${service_name};
  --
END
$$;
COMMIT;
/
