#!/usr/bin/env bash

set -euo pipefail

ORG_ALIAS="${1:-heimdall-ltf}"
DEVHUB_ALIAS="${2:-DevHub}"

echo "Logging into Dev Hub (alias: ${DEVHUB_ALIAS})..."
sf org login web --set-default-dev-hub --alias "${DEVHUB_ALIAS}"

echo "Creating scratch org (alias: ${ORG_ALIAS})..."
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --set-default \
  --alias "${ORG_ALIAS}"

# echo "Deploying core framework..."
# sf project deploy start --source-dir force-app

echo "Deploying examples (optional but recommended)..."
sf project deploy start --source-dir examples/force-app

echo "Running local tests..."
sf apex run test --test-level RunLocalTests --result-format human --synchronous

echo "Done. Scratch org is ready: ${ORG_ALIAS}"
