#!/bin/bash

# ===============================================================================
# Schema Creation (Creschema) Liquibase Docker Image Builder
#
# Ez a script az adatbázis séma inicializáló (creschema) Docker image-et 
# buildeli. 
#
# A build a projekt gyökerében lévő .env fájl változóira támaszkodik:
# - DOCKER_RUNTIME_LIQUIBASE: Az alap liquibase image
# - DOCKER_DOOKUG_CRESCHEMA_LIQUIBASE: A létrejövő creschema image neve
# ===============================================================================

set -e

CURRENT_PATH=$(dirname "$0")

. ${CURRENT_PATH}/../../../.env

echo "=== Liquibase Creschema Image Build Parameters ==="
echo "Base Liquibase Image:              DOCKER_RUNTIME_LIQUIBASE=${DOCKER_RUNTIME_LIQUIBASE}"
echo "Target Creschema Image:            DOCKER_DOOKUG_CRESCHEMA_LIQUIBASE=${DOCKER_DOOKUG_CRESCHEMA_LIQUIBASE}"
echo "=== Building Docker Image ==="

# Docker image build: a docker-compose.yml-ben 
# Paraméterek:
#   --progress=plain        - text output
#   LIQUIBASE_INSTALL_DIR   - changelog folder
docker compose --env-file ${CURRENT_PATH}/../../../.env -f ${CURRENT_PATH}/docker-compose.yml build --progress=plain
