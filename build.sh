#!/bin/bash
set -e

CURRENT_PATH=$(dirname "$0")

# Set variables
. ${CURRENT_PATH}/.env

docker compose -f ${CURRENT_PATH}/docker-compose.yml build --no-cache --progress=plain
