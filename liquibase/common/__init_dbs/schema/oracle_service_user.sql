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

--changeset jozsef.holczer:${schema_name}-CREATE_SERVICE_USER dbms:oracle endDelimiter:/
--comment Creating Service User...

DECLARE
   l_schemaname VARCHAR2(30)  := UPPER('${schema_name}');
   l_passw      VARCHAR2(100) := '${schema_password}';
   l_sql        VARCHAR2(1000);
BEGIN
   EXECUTE IMMEDIATE 'alter session set "_oracle_script"=true';       
   
   BEGIN
      FOR r IN (SELECT 1 FROM dba_users WHERE UPPER(username) = UPPER('${schema_name}_service')) LOOP
         RETURN;
      END LOOP;

      l_sql := 'CREATE USER ' || l_schemaname || '_SERVICE IDENTIFIED BY ' || l_passw || ' DEFAULT TABLESPACE TS_' || l_schemaname || ' TEMPORARY TABLESPACE TEMP';
      EXECUTE IMMEDIATE l_sql;
   END;

   l_sql := 'GRANT ALTER SESSION TO ' || l_schemaname || '_SERVICE'; 
   EXECUTE IMMEDIATE l_sql;
   
   l_sql := 'GRANT ' || l_schemaname || '_EXEC TO ' || l_schemaname || '_SERVICE'; 
   EXECUTE IMMEDIATE l_sql;
   
   l_sql := 'ALTER USER ' || l_schemaname || '_SERVICE DEFAULT ROLE ALL'; 
   EXECUTE IMMEDIATE l_sql;

END;
/
