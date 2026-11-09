#!/bin/bash
set -e
. $(pwd)/../../../.env
. $(pwd)/.env


DOCKER_HOST_ADDR="localhost"
NETWORK_ARG="--network=host"

docker run  \
    ${NETWORK_ARG} \
    "${DOCKER_DOOKUG_LIQUIBASE}" \
    --url="${JDBC_URL}" \
    --username="${DOOKUG_SCHEMA}" \
    --password="${DOOKUG_SCHEMA_PASSW}" \
    --changeLogFile="changelog/dookug-master.xml" \
    --secureParsing=false \
    update 
