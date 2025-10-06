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

#in case of local development, you don't need to fill the INSTALL_SCHEMA.
S2_SCHEMA_NAME=${INSTALL_SCHEMA:-dookug}
echo "PROJECT SCHEMA=$S2_SCHEMA_NAME"
export S2_SCHEMA_NAME

echo "AUTO_INSTALL=$AUTO_INSTALL"  


# in case of embedding, the database_name comes from the last tag (host_db) of the project url (e.g.: jdbc:postgresql://module-host-postgredb:5432/host_db) if it is not set explicitly.
#it is required here in Oracle as well, b/c without it a Java Exception occurs.
DATABASE_NAME=${DATABASE_NAME:-$(basename "${INSTALL_URL_PROJECT:-dookug_db}")}
export DATABASE_NAME

if [[ "$AUTO_INSTALL" == "postgresql" ]]; then

  #The following parameter needed for Postgres, if our current repo is embedded in to another repo. 
  # The default CREATE_DATABASE is initialized in step1, and needs to be overwritten during runtime.
  # If you need to embed it, then CREATE_DATABASE=false, and with this, we can avoid to create an empty DB within the "parent (host)" DB. 
  # This parameter is used in "dookug-db/liquibase/common/_create_dbs/create-database.sql"
  CREATE_DATABASE=${CREATE_DATABASE:-true}
  echo "CREATE_DATABASE=$CREATE_DATABASE"
  export CREATE_DATABASE
  
  echo "PROJECT DATABASE=$DATABASE_NAME"
  
  #in case of local development, you don't need to fill the INSTALL_PGTOOLS, but id you don't need it, you need to fill it with 0.
  INSTALL_PGTOOLS=${INSTALL_PGTOOLS:-true}
  export INSTALL_PGTOOLS
  echo "INSTALL_PGTOOLS=$INSTALL_PGTOOLS"
fi  

#in case of local development, you don't need to fill the INSTALL_USERNAME_ADMIN.
if [[ "$AUTO_INSTALL" == "postgresql" ]]; then
  INSTALL_USERNAME_ADMIN=${INSTALL_USERNAME_ADMIN:-postgres}
  INSTALL_USERNAME_PROJECT=${INSTALL_USERNAME_PROJECT:-${S2_SCHEMA_NAME}}
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
  
  PG_TOOLS_INSTALLED=false    
  
  for step in "${STEPS[@]}"; do
  
    defaults_file="./postgresql/defaults-step-0${step}.properties"
    
    case $step in
      1)
        echo "Running step-0${step} - DB initialization..."
        echo "  INSTALL_USERNAME_ADMIN=$INSTALL_USERNAME_ADMIN"
        echo "  INSTALL_URL_ADMIN=$INSTALL_URL_ADMIN"
        liqui_url="${INSTALL_URL_ADMIN}"
        liqui_user="${INSTALL_USERNAME_ADMIN}"
        liqui_passw="${INSTALL_PASSWORD_ADMIN}"
        ;;
      2)
        echo "Running step-0${step}:"
        echo "  INSTALL_USERNAME_PROJECT=$INSTALL_USERNAME_PROJECT"
        echo "  INSTALL_URL_PROJECT=$INSTALL_URL_PROJECT"
        liqui_url="${INSTALL_URL_PROJECT}"
        liqui_user="${INSTALL_USERNAME_PROJECT}"
        liqui_passw="${INSTALL_PASSWORD_PROJECT}"
        #The pg_tools is in an external image, needs to be handled separately.
        if [[ "$PG_TOOLS_INSTALLED" == false &&  "$INSTALL_PGTOOLS" == true ]]; then
          echo "  step-0${step} - Install PG_TOOLS partition manager into ${S2_SCHEMA_NAME} DB..."
          changelog_file="./partman/liquibase/changelog/liquibase-install-step-0${step}.xml"
          # --default-schema-name=public: The PG_TOOLS is an external image, so we need to provide where to find the databasechangelog table.
          liquibase \
            --searchPath=../${DOCKER_REPOSITORY}/liquibase/changelog \
            --defaults-file="${defaults_file}" \
            --changeLogFile="${changelog_file}" \
            --url="${liqui_url}" \
            --default-schema-name=public \
            --username="${liqui_user}" \
            --password="${liqui_passw}" \
            update
          PG_TOOLS_INSTALLED=true
        fi
        ;;
      3)
        echo "Running step-0${step} - Add the service user to the CRON scheduler..."
        echo "  INSTALL_USERNAME_ADMIN=$INSTALL_USERNAME_ADMIN"
        echo "  INSTALL_URL_ADMIN=$INSTALL_URL_ADMIN"
        liqui_url="${INSTALL_URL_ADMIN}"
        liqui_user="${INSTALL_USERNAME_ADMIN}"
        liqui_passw="${INSTALL_PASSWORD_ADMIN}"
        ;;
      4)
        echo "Running step-0${step} - install DEV templates into ${S2_SCHEMA_NAME} schema..."
        echo "  INSTALL_USERNAME_PROJECT=$INSTALL_USERNAME_PROJECT"
        echo "  INSTALL_URL_PROJECT=$INSTALL_URL_PROJECT"
        liqui_url="${INSTALL_URL_PROJECT}"
        liqui_user="${INSTALL_USERNAME_PROJECT}"
        liqui_passw="${INSTALL_PASSWORD_PROJECT}"
        ;;
    esac

    #only for step2 without pg_tools installation
    if [[ ("$PG_TOOLS_INSTALLED" == true && ${step} == 2) || ("$INSTALL_PGTOOLS" == false && ${step} == 2) ]]; then
      echo "  step-0${step} - Objects creation into ${S2_SCHEMA_NAME} schema..."
    fi

    #only for step2 without pg_tools installation, OR for the other steps.
    if [[ ( "$PG_TOOLS_INSTALLED" == true && ${step} == 2 ) || ("$INSTALL_PGTOOLS" == false) || ${step} != 2 ]]; then
      changelog_file="liquibase-install-step-0${step}.xml"
      liquibase \
        --searchPath=../${DOCKER_REPOSITORY}/liquibase/changelog \
        --liquibaseSchemaName=public \
        --defaults-file="${defaults_file}" \
        --changeLogFile="${changelog_file}" \
        --url="${liqui_url}" \
        --username="${liqui_user}" \
        --password="${liqui_passw}" \
        update
    fi

  done
  exit 0
# ------------Oracle install----------------  
elif [[ "$AUTO_INSTALL" == "oracle" ]]; then
  for step in "${STEPS[@]}"; do

    case $step in
      1)
        echo "Running step-0${step} - DB initialization..."
        echo "  INSTALL_USERNAME_ADMIN=$INSTALL_USERNAME_ADMIN"
        echo "  INSTALL_URL_ADMIN=$INSTALL_URL_ADMIN"
        liqui_url="${INSTALL_URL_ADMIN}"
        liqui_user="${INSTALL_USERNAME_ADMIN}"
        liqui_passw="${INSTALL_PASSWORD_ADMIN}"
        ;;
      2)
        echo "Running step-0${step} - Objects creation into ${S2_SCHEMA_NAME} schema"
        echo "  INSTALL_USERNAME_PROJECT=$INSTALL_USERNAME_PROJECT"
        echo "  INSTALL_URL_PROJECT=$INSTALL_URL_PROJECT"
        liqui_url="${INSTALL_URL_PROJECT}"
        liqui_user="${INSTALL_USERNAME_PROJECT}"
        liqui_passw="${INSTALL_PASSWORD_PROJECT}"
        ;;
      3)
        liqui_url=""
        liqui_user=""
        liqui_passw=""
        ;;
      4)
        echo "Running step-0${step} - install DEV templates into ${S2_SCHEMA_NAME} schema..."
        echo "  INSTALL_USERNAME_PROJECT=$INSTALL_USERNAME_PROJECT"
        echo "  INSTALL_URL_PROJECT=$INSTALL_URL_PROJECT"
        liqui_url="${INSTALL_URL_PROJECT}"
        liqui_user="${INSTALL_USERNAME_PROJECT}"
        liqui_passw="${INSTALL_PASSWORD_PROJECT}"
        ;;
    esac
    defaults_file="./oracle/defaults-step-0${step}.properties"
    #Step3 is not needed here.
    if [[ ${step} != 3 ]]; then
      changelog_file="liquibase-install-step-0${step}.xml"
      liquibase \
        --searchPath=../${DOCKER_REPOSITORY}/liquibase/changelog \
        --defaults-file="${defaults_file}" \
        --changeLogFile="${changelog_file}" \
        --url="${liqui_url}" \
        --username="${liqui_user}" \
        --password="${liqui_passw}" \
        update
    fi
  done
  exit 0
fi  