#!/bin/bash
set -e
. $(pwd)/../../../.env
. $(pwd)/.env

DOCKER_HOST_ADDR="localhost"
NETWORK_ARG="--network=host"

docker run  --rm \
      ${NETWORK_ARG} \
      "${DOCKER_DOOKUG_CRESCHEMA_LIQUIBASE}" \
      --url="${JDBC_URL}" \
      --username="${CRESCHEMA_USER}" \
      --password="${CRESCHEMA_PASSW}" \
      --changeLogFile="changelog/dookug_creschema-master.xml" \
      --secureParsing=false \
      --database-changelog-lock-table-name=${DOOKUG_SCHEMA}_dbchloglock \
      --database-changelog-table-name=${DOOKUG_SCHEMA}_dbchlog \
      update \
      -Ddookug_schema="${DOOKUG_SCHEMA}" \
      -Ddookug_password="${DOOKUG_SCHEMA_PASSW}" \
      -Ddookug_service_password="${DOOKUG_SERVICE_PASSW}" \
      -Ddookug_tablespace="${DOOKUG_TABLESPACE}"