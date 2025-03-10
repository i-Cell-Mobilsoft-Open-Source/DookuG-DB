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

--changeset jozsef.szollosi:${schema_name}_set_character_semantics runAlways:true dbms:oracle endDelimiter:/ 
--comment Changing the VARCHAR2 columns with BYTE semantics to CHAR semantics within the schema...

DECLARE
   TYPE t_stmts IS TABLE OF VARCHAR2(2018);
   l_mod t_stmts;
BEGIN
   SELECT 'alter table ' || table_name || ' modify ' || column_name || ' ' ||
          data_type || '(' || data_length || ' char)' stmt 
     BULK COLLECT INTO l_mod
     FROM user_tab_cols
    WHERE data_type = 'VARCHAR2'
      AND char_used = 'B'
      AND column_id is not null
      AND table_name NOT IN (SELECT object_name FROM user_recyclebin UNION ALL SELECT view_name FROM user_views)
      and (table_name, column_name) not in (select name, column_name from USER_SUBPART_KEY_COLUMNS);
   FOR i IN 1 .. l_mod.count LOOP
      EXECUTE IMMEDIATE l_mod(i);
   END LOOP;
END;
/
