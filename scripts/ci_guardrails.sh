#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLASSES_DIR="$ROOT_DIR/force-app/main/default/classes"

echo "Running DI/architecture guardrails..."

fail() {
  echo "ERROR: $1"
  exit 1
}

# 1) No direct selector/service instantiation outside ProductionServices.
if rg -n "new\s+[A-Za-z0-9_]+Selector\(" "$CLASSES_DIR" --glob "!**/ProductionServices.cls" >/dev/null; then
  fail "Selector instantiation found outside ProductionServices"
fi
if rg -n "new\s+[A-Za-z0-9_]+Service\(" "$CLASSES_DIR" --glob "!**/ProductionServices.cls" >/dev/null; then
  fail "Service instantiation found outside ProductionServices"
fi

# 2) Warn when http.send is used directly (should be wrapped in IHttpClient).
if rg -n "http\.send\(" "$CLASSES_DIR" >/dev/null; then
  echo "WARNING: Direct http.send detected. Prefer IHttpClient wrapper."
fi

echo "Guardrails OK"

