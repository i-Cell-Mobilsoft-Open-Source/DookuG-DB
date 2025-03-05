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

--changeset bertalan.pasztor:${schema_name}-CREATE_SCHEMA dbms:postgresql endDelimiter:/
--comment Creating schema...

DO $$
BEGIN

--
  CREATE SCHEMA IF NOT EXISTS ${schema_name} AUTHORIZATION ${dba_user_name};
  GRANT USAGE ON SCHEMA ${schema_name} TO ${schema_name}_read;
  GRANT USAGE ON SCHEMA ${schema_name} TO ${schema_name}_write;
  GRANT USAGE ON SCHEMA ${schema_name} TO ${schema_name}_exec;  
  GRANT USAGE ON SCHEMA ${schema_name} TO ${service_name};
  GRANT USAGE ON SCHEMA ${schema_name} TO  ${schema_name}_sel;

-- Setting the host db service user
  IF '${S2_SCHEMA_NAME}' != '${schema_name}' THEN
    GRANT ${schema_name}_read TO ${service_name};
    GRANT ${schema_name}_write TO ${service_name};
    GRANT ${schema_name}_exec TO ${service_name};
    GRANT ${schema_name}_full TO ${service_name};
  END IF;
END
$$;
COMMIT;
/
