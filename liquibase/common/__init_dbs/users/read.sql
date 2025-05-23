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

--changeset endre.balazs:${schema_name}-READ_USER dbms:postgresql runOnChange:true endDelimiter:/
--comment Creating Read user with limited rights...

DO $$
DECLARE
  v_user_name  text := '${schema_name}_read';
BEGIN
     
  -- -- --
  IF not public_user_exists(v_user_name) THEN
    CREATE USER ${schema_name}_read WITH PASSWORD '${schema_password}';
  END IF;
  
END$$;
/

