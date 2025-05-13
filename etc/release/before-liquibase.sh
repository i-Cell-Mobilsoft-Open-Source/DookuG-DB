#!/bin/bash

# Copyright (c) 2025 i-Cell Mobilsoft Zrt.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License. You may
# obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

set -e

# in case of embedding, the database_name comes from the last tag (noteefly_db) of the project url (e.g.: jdbc:postgresql://module-noteefly-postgredb:5432/noteefly_db) if it is not set explicitly.
DATABASE_NAME=${DATABASE_NAME:-$(basename "${INSTALL_URL_PROJECT:-dookug_db}")}
export DATABASE_NAME

#in case of local development, you don't need to fill the INSTALL_SCHEMA.
S2_SCHEMA_NAME=${INSTALL_SCHEMA:-dookug}
echo "S2_SCHEMA_NAME=$S2_SCHEMA_NAME"
export S2_SCHEMA_NAME

#in case of local development, you don't need to fill the INSTALL_PGTOOLS, but id you don't need it, you need to fill it with 0.
INSTALL_PGTOOLS=${INSTALL_PGTOOLS:-1}
export INSTALL_PGTOOLS

#in case of local development, you don't need to fill the INSTALL_USERNAME_ADMIN.
echo "AUTO_INSTALL=$AUTO_INSTALL"  
if [[ "$AUTO_INSTALL" == "postgresql" ]]; then
  INSTALL_USERNAME_ADMIN=${INSTALL_USERNAME_ADMIN:-postgres}
  INSTALL_USERNAME_PROJECT=${INSTALL_USERNAME_PROJECT:-postgres}
  INSTALL_PASSWORD_ADMIN=${INSTALL_PASSWORD_ADMIN:-postgres}
  INSTALL_PASSWORD_PROJECT=${INSTALL_PASSWORD_PROJECT:-postgres}
  INSTALL_URL_ADMIN=${INSTALL_URL_ADMIN:-jdbc:postgresql://module-dookug-postgredb:5432/postgres}
  INSTALL_URL_PROJECT=${INSTALL_URL_PROJECT:-jdbc:postgresql://module-dookug-postgredb:5432/dookug_db}
elif [[ "$AUTO_INSTALL" == "oracle" ]]; then
  INSTALL_USERNAME_ADMIN=${INSTALL_USERNAME_ADMIN:-system}
  INSTALL_USERNAME_PROJECT=${INSTALL_USERNAME_PROJECT:-${S2_SCHEMA_NAME}}
  INSTALL_PASSWORD_ADMIN=${INSTALL_PASSWORD_ADMIN:-developer}
  INSTALL_PASSWORD_PROJECT=${INSTALL_PASSWORD_PROJECT:-developer}
  INSTALL_URL_ADMIN=${INSTALL_URL_ADMIN:-jdbc:oracle:thin:@module-dookug-oracle:1521/xepdb1}
  INSTALL_URL_PROJECT=${INSTALL_URL_PROJECT:-jdbc:oracle:thin:@module-dookug-oracle:1521/xepdb1}
fi
export INSTALL_USERNAME_ADMIN
export INSTALL_USERNAME_PROJECT
export INSTALL_PASSWORD_ADMIN
export INSTALL_PASSWORD_PROJECT
export INSTALL_URL_ADMIN
export INSTALL_URL_PROJECT

#The following parameter needed for Postgres, if our current repo is embedded in to another repo. 
# The default CREATE_DATABASE is initialized in step1, and needs to be overwritten during runtime.
# If you need to embed it, then CREATE_DATABASE=false, and with this, we can avoid to create an empty DB within the "parent (host)" DB. 
# This parameter is used in "dookug-db/liquibase/common/_create_dbs/create-database.sql"
CREATE_DATABASE=${CREATE_DATABASE:-true}
echo "CREATE_DATABASE=$CREATE_DATABASE"
export CREATE_DATABASE

# The following parameter is used to set the order of the install steps.
# The default order is 1,2,3,4.
# If you want to alter the order, or you just need specific step(s), you can set the INSTALL_STEPS environment variable outside from DevOps.
# The variable cannot be empty! If all steps are required, then set it to "1,2,3,4, etc.".
STEPS=${INSTALL_STEPS:-"1,2,3,4"}
echo "INSTALL_STEPS=$STEPS"
echo "---------------------------"
IFS=',' read -ra STEPS <<< "$STEPS"

#sanity check:
#creating an ordered copy.
SORTED_STEPS=$(printf '%s\n' "${STEPS[@]}" | sort -n | paste -sd "," -)
#if the steps are not in order.
if [[ "$STEPS" != "$SORTED_STEPS" ]]; then
  # order it by ascending order.
  SORTED_STEPS=$(printf '%s\n' "${STEPS[@]}" | sort -n | paste -sd "," -)
  # overwrite the STEPS variable with the ordered one.
  IFS=',' read -ra STEPS <<< "$SORTED_STEPS"
fi  

# ----------Postgres install------------------
if [[ "$AUTO_INSTALL" == "postgresql" ]]; then
  for step in "${STEPS[@]}"; do
    case $step in
      1)
        echo "Running step-01 - DB initialization..."
        echo "  INSTALL_USERNAME_ADMIN=$INSTALL_USERNAME_ADMIN"
        echo "  INSTALL_URL_ADMIN=$INSTALL_URL_ADMIN"
        liquibase --defaults-file=./postgresql/defaults-step-01.properties \
                  --changeLogFile=/changelog/liquibase-install-step-01.xml \
                  --url="${INSTALL_URL_ADMIN}" \
                  --username="${INSTALL_USERNAME_ADMIN}" \
                  --password="${INSTALL_PASSWORD_ADMIN}" \
                  update
        ;;
      2)
        if [[ "$INSTALL_PGTOOLS" == "1" ]]; then         
          echo "Running step-02 - install PG_TOOLS partition manager into ${S2_SCHEMA_NAME} DB..."
          echo "  INSTALL_USERNAME_PROJECT=$INSTALL_USERNAME_PROJECT"
          echo "  INSTALL_URL_PROJECT=$INSTALL_URL_PROJECT"
          liquibase --searchPath=../${DOCKER_REPOSITORY}/liquibase/changelog \
              --defaults-file=./postgresql/defaults-step-02.properties \
              --changeLogFile=./partman/liquibase/changelog/liquibase-install-step-02.xml \
              --url="${INSTALL_URL_PROJECT}" \
              --username="${INSTALL_USERNAME_PROJECT}" \
              --password="${INSTALL_PASSWORD_PROJECT}" \
              update
        fi      

        echo "Running step-02 - Objects creation into ${S2_SCHEMA_NAME} schema..."
        echo "  INSTALL_USERNAME_PROJECT=$INSTALL_USERNAME_PROJECT"
        echo "  INSTALL_URL_PROJECT=$INSTALL_URL_PROJECT"
        liquibase --searchPath=../${DOCKER_REPOSITORY}/liquibase/changelog \
                  --defaults-file=./postgresql/defaults-step-02.properties \
                  --changeLogFile=liquibase-install-step-02.xml \
                  --url="${INSTALL_URL_PROJECT}" \
                  --username=${INSTALL_USERNAME_PROJECT} \
                  --password="${INSTALL_PASSWORD_PROJECT}" \
                  update
        ;;          
      3) 
        echo "Running step-03 - Add the service user to the CRON scheduler..."
        echo "  INSTALL_USERNAME_ADMIN=$INSTALL_USERNAME_ADMIN"
        echo "  INSTALL_URL_ADMIN=$INSTALL_URL_ADMIN"
        liquibase --defaults-file=./postgresql/defaults-step-03.properties \
                  --changeLogFile=/changelog/liquibase-install-step-03.xml \
                  --url="${INSTALL_URL_ADMIN}" \
                  --username=${INSTALL_USERNAME_ADMIN}  \
                  --password="${INSTALL_PASSWORD_ADMIN}" \
                  update
        ;;
      4) 
        echo "Running step-04 - install DEV templates into ${S2_SCHEMA_NAME} schema..."
        echo "  INSTALL_USERNAME_PROJECT=$INSTALL_USERNAME_PROJECT"
        echo "  INSTALL_URL_PROJECT=$INSTALL_URL_PROJECT"
        liquibase --searchPath=../${DOCKER_REPOSITORY}/liquibase/changelog \
                  --defaults-file=./postgresql/defaults-step-04.properties \
                  --changeLogFile=liquibase-install-step-04.xml \
                  --url="${INSTALL_URL_PROJECT}" \
                  --username=${INSTALL_USERNAME_PROJECT} \
                  --password="${INSTALL_PASSWORD_PROJECT}" \
                  update
        ;;
    esac
  done
#------------Oracle install----------------  
elif [[ "$AUTO_INSTALL" == "oracle" ]]; then
  for step in "${STEPS[@]}"; do
    case $step in
      1)
        echo "Running step-01 - DB initialization..."
        echo "  INSTALL_USERNAME_ADMIN=$INSTALL_USERNAME_ADMIN"
        echo "  INSTALL_URL_ADMIN=$INSTALL_URL_ADMIN"
        liquibase --defaults-file=./oracle/defaults-step-01.properties \
                  --changeLogFile=/changelog/liquibase-install-step-01.xml \
                  --url="${INSTALL_URL_ADMIN}" \
                  --username="${INSTALL_USERNAME_ADMIN}" \
                  --password="${INSTALL_PASSWORD_ADMIN}" \
                  update
        ;;
      2) 
        echo "Running step-02 - Objects creation into ${S2_SCHEMA_NAME} schema..."
        echo "  INSTALL_USERNAME_PROJECT=$INSTALL_USERNAME_PROJECT"
        echo "  INSTALL_URL_PROJECT=$INSTALL_URL_PROJECT"
        liquibase --searchPath=../${DOCKER_REPOSITORY}/liquibase/changelog \
                  --defaults-file=./oracle/defaults-step-02.properties \
                  --changeLogFile=liquibase-install-step-02.xml \
                  --url="${INSTALL_URL_PROJECT}" \
                  --username=${INSTALL_USERNAME_PROJECT} \
                  --password="${INSTALL_PASSWORD_PROJECT}" \
                  update
        ;;          
      3) 
        echo "Running step-03 - an empty step..."
        liquibase --defaults-file=./oracle/defaults-step-03.properties \
                  --changeLogFile=/changelog/liquibase-install-step-03.xml \
                  --url="${INSTALL_URL_ADMIN}" \
                  --username="${INSTALL_USERNAME_ADMIN}" \
                  --password="${INSTALL_PASSWORD_ADMIN}" \
                  update
        ;;
      4) 
        echo "Running step-04 - install DEV templates into ${S2_SCHEMA_NAME} schema..."
        echo "  INSTALL_USERNAME_PROJECT=$INSTALL_USERNAME_PROJECT"
        echo "  INSTALL_URL_PROJECT=$INSTALL_URL_PROJECT"
        liquibase --searchPath=../${DOCKER_REPOSITORY}/liquibase/changelog \
                  --defaults-file=./oracle/defaults-step-04.properties \
                  --changeLogFile=liquibase-install-step-04.xml \
                  --url="${INSTALL_URL_PROJECT}" \
                  --username="${INSTALL_USERNAME_PROJECT}" \
                  --password="${INSTALL_PASSWORD_PROJECT}" \
                  update
        ;;
    esac
  done
fi  

exit 0
