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

--changeset jozsef.szollosi:${schema_name}_recompile_invalid_objects runAlways:true dbms:oracle endDelimiter:/ 
--comment Recompile invalid packages, functions, procedures, triggers...

declare
cursor c is
select 'ALTER ' || case when object_type = 'PACKAGE BODY' then 'PACKAGE' else object_type end || ' ' || object_name || ' COMPILE' stmt
  from user_objects
 where status = 'INVALID'
   and object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER');
begin
   for i in c loop
      execute immediate i.stmt;
   end loop;
end;
/
