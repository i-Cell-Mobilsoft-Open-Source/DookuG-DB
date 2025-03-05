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

--changeset jozsef.holczer:${schema_name}-ORA_GRANTS dbms:oracle
--comment "Creating oracle grants..."

GRANT ${schema_name}_write TO ${schema_name}_exec;
GRANT ${schema_name}_read TO ${schema_name}_write;
GRANT ${schema_name}_exec TO ${schema_name}_service;
