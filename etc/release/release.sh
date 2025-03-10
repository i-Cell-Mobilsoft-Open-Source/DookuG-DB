#!/usr/bin/env bash

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

set -ex

# import .env file (resolves inner values as well)
. .env

echo "Starting release from $RELEASED_VERSION"

###############################################################################
# tag + push images
###############################################################################
docker push ${DOCKER_LIQUIBASE_DOOKUG}:${VERSION}

echo "Release from $VERSION ended"
