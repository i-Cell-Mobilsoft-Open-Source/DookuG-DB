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

--changeset bertalan.pasztor:${schema_name}_ADD_PRIVILEGES_TO_ALL_TABLES runOnChange:true dbms:postgresql endDelimiter:/
--comment Creating add_privileges_to_all_tables procedure...

DROP PROCEDURE IF EXISTS ${schema_name}.add_privileges_to_all_tables(text);

CREATE OR REPLACE PROCEDURE ${schema_name}.add_privileges_to_all_tables(IN p_table_schema text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
  rec RECORD;
BEGIN

  FOR rec IN SELECT schemaname, tablename FROM pg_catalog.pg_tables WHERE schemaname = p_table_schema AND tablename NOT LIKE '%hist'
  LOOP
    call add_privileges_to_table(rec.schemaname, rec.tablename);
  END LOOP;

  FOR rec IN SELECT schemaname, tablename FROM pg_catalog.pg_tables WHERE schemaname = p_table_schema AND tablename LIKE '%hist'
  LOOP
	  EXECUTE 'GRANT SELECT ON TABLE '||rec.tablename||' TO '||rec.schemaname||'_read';
  END LOOP;

END;
$procedure$
;

/

-- Permissions
ALTER PROCEDURE ${schema_name}.add_privileges_to_all_tables(text) OWNER TO ${pg_schema_user};

GRANT EXECUTE ON PROCEDURE ${schema_name}.add_privileges_to_all_tables(text) TO ${schema_name}_exec;

