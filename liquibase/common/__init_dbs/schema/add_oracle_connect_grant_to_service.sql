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

--changeset jozsef.holczer:${schema_name}-CONNECT_GRANT_TO_SERVICE dbms:oracle endDelimiter:/
--comment Add connect grant to Service User...

DECLARE
   l_service_name VARCHAR2(30)  := UPPER('${service_name}');
   l_sql        VARCHAR2(1000);
BEGIN
   EXECUTE IMMEDIATE 'alter session set "_oracle_script"=true';       
   
   l_sql := 'GRANT CONNECT TO ' || l_service_name; 
   EXECUTE IMMEDIATE l_sql;

END;
/
