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

--changeset bertalan.pasztor:${schema_name}_ADD_PRIVILEGES_TO_TABLE runOnChange:true dbms:postgresql endDelimiter:/
--comment Creating add_privileges_to_table procedure...

DROP PROCEDURE IF EXISTS ${schema_name}.add_privileges_to_table(text, text);

CREATE OR REPLACE PROCEDURE ${schema_name}.add_privileges_to_table(IN p_table_schema text, IN p_table_name text)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

  EXECUTE 'GRANT SELECT ON TABLE '||p_table_name||' TO '||p_table_schema||'_read';
  EXECUTE 'GRANT INSERT, UPDATE, DELETE ON TABLE '||p_table_name||' TO '||p_table_schema||'_write';
  EXECUTE 'ALTER TABLE '||p_table_name||' REPLICA IDENTITY FULL';

END;
$procedure$
;

/

-- Permissions

GRANT EXECUTE ON PROCEDURE ${schema_name}.add_privileges_to_table(text, text) TO ${schema_name}_exec;

