#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLASSES_DIR="$ROOT_DIR/force-app/main/default/classes"

echo "Running DI/architecture guardrails..."

fail() {
  echo "ERROR: $1"
  exit 1
}

run_search() {
  local pattern="$1"
  local exclude_file="${2:-}"

  if command -v rg >/dev/null 2>&1; then
    if [[ -n "$exclude_file" ]]; then
      rg -n "$pattern" "$CLASSES_DIR" --glob "!**/$exclude_file"
    else
      rg -n "$pattern" "$CLASSES_DIR"
    fi
  else
    if [[ -n "$exclude_file" ]]; then
      grep -R -n -E --exclude="$exclude_file" "$pattern" "$CLASSES_DIR"
    else
      grep -R -n -E "$pattern" "$CLASSES_DIR"
    fi
  fi
}

# 1) No direct selector/service instantiation outside ProductionServices.
if run_search "new[[:space:]]+[A-Za-z0-9_]+Selector\\(" "ProductionServices.cls" >/dev/null; then
  fail "Selector instantiation found outside ProductionServices"
fi
if run_search "new[[:space:]]+[A-Za-z0-9_]+Service\\(" "ProductionServices.cls" >/dev/null; then
  fail "Service instantiation found outside ProductionServices"
fi

# 2) Warn when http.send is used directly (should be wrapped in IHttpClient).
if run_search "http\.send\\(" >/dev/null; then
  echo "WARNING: Direct http.send detected. Prefer IHttpClient wrapper."
fi

echo "Guardrails OK"

