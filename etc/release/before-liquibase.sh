#!/bin/bash

# Copyright (C) 2025 i-Cell Mobilsoft Zrt.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

set -e

#The INSTALL_SCHEMA parameter is null initially, so let's set a default value.
S2_SCHEMA_NAME=${INSTALL_SCHEMA:-dookug}
echo "S2_SCHEMA_NAME=$S2_SCHEMA_NAME"
export S2_SCHEMA_NAME

#The following parameter needed for Postgres, if our current repo is embedded in to another repo. 
# The default CREATE_DATABASE is initialized in step1, and needs to be overwritten during runtime.
# If you need to embed it, then CREATE_DATABASE=false, and with this, we can avoid to create an empty DB within the "parent (host)" DB. 
# This parameter is used in "dookug-db/liquibase/common/_create_dbs/create-database.sql"
CREATE_DATABASE=${CREATE_DATABASE:-true}
echo "CREATE_DATABASE=$CREATE_DATABASE"
export CREATE_DATABASE
