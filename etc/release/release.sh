#!/usr/bin/env bash
set -ex

# import .env file (resolves inner values as well)
. .env

echo "Starting release from $RELEASED_VERSION"

###############################################################################
# tag + push images
###############################################################################
docker push ${DOCKER_LIQUIBASE_DOOKUG}:${VERSION}

echo "Release from $VERSION ended"
