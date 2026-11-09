#!/bin/bash

# ===============================================================================
# Schema Liquibase Docker Image Builder
#
# Ez a script a séma migrációs Docker image-et buildeli.
#
# A build a projekt gyökerében lévő .env fájl változóira támaszkodik:
# - DOCKER_RUNTIME_LIQUIBASE: Az alap liquibase image
# - DOCKER_DOOKUG_LIQUIBASE: A létrejövő séma migrációs image neve
# ===============================================================================

set -e

CURRENT_PATH=$(dirname "$0")

. ${CURRENT_PATH}/../../../.env

echo "=== Liquibase Image Build Parameters ==="
echo "Base Liquibase Image:    DOCKER_RUNTIME_LIQUIBASE=${DOCKER_RUNTIME_LIQUIBASE}"
echo "Target Image:            DOCKER_DOOKUG_LIQUIBASE=${DOCKER_DOOKUG_LIQUIBASE}"
echo "=== Building Docker Image ==="

# Docker image build
# Paraméterek:
#   --progress=plain        - Szöveges kimenet
#   LIQUIBASE_INSTALL_DIR   - changelog folder
#   LIQUIBASE_INSTALL_COMMON_DIR - Common utilities
docker compose --env-file ${CURRENT_PATH}/../../../.env -f ${CURRENT_PATH}/docker-compose.yml build --progress=plain
