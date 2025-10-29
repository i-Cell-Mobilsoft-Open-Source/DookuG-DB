#!/bin/bash

# path of the playbook file
PLAYBOOK_DIR=$(dirname "$(realpath "$0")")

# generating local antora site with antora cli (https://docs.antora.org/antora/latest/install/install-antora/)
npx antora $PLAYBOOK_DIR/local-antora-playbook.yml

# opening the documentation in the browser
xdg-open "$PLAYBOOK_DIR/build/site/index.html"
