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

# path of the playbook file
PLAYBOOK_DIR=$(dirname "$(realpath "$0")")

# generating local antora site with antora cli (https://docs.antora.org/antora/latest/install/install-antora/)
npx antora $PLAYBOOK_DIR/local-antora-playbook.yml

# opening the documentation in the browser
xdg-open "$PLAYBOOK_DIR/build/site/index.html"
