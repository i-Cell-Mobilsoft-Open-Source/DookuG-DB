# Copyright (C) 2025 i-Cell Mobilsoft Zrt.
#
# SPDX-License-Identifier: Apache-2.0

#!/bin/bash
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
