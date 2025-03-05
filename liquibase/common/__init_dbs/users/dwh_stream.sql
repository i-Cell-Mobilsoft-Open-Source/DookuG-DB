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

--changeset bertalan.pasztor:${schema_name}-DWH_STREAM_USER dbms:postgresql runOnChange:true
--comment Creating dwh_stream user...

--preconditions onFail:MARK_RAN onError:HALT
--precondition-sql-check expectedResult:0 SELECT count(*) FROM pg_catalog.pg_user WHERE usename = 'dwh_stream'

CREATE USER dwh_stream WITH REPLICATION PASSWORD '${schema_password}';

