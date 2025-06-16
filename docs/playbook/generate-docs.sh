#!/bin/bash

# playbook file útvonala
PLAYBOOK_DIR=$(dirname "$(realpath "$0")")

# local antora site generálása antora cli-vel (https://docs.antora.org/antora/latest/install/install-antora/)
npx antora $PLAYBOOK_DIR/local-antora-playbook.yml

# dokumentáció megnyitása böngészőben
xdg-open "$PLAYBOOK_DIR/build/site/index.html"
