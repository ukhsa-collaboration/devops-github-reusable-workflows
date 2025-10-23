#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

if [[ ! -f "./backend.tf" ]]; then
  log_error "backend.tf not found in working directory."
  exit 1
fi

backend_type=$(grep -oP 'backend\s+"?\K[^"\s]+' ./backend.tf || true)

if [[ -z "$backend_type" ]]; then
  log_error "Unable to determine backend type from backend.tf."
  exit 1
fi

if [[ -z "${GITHUB_OUTPUT:-}" ]]; then
  log_error "GITHUB_OUTPUT environment variable is not set."
  exit 1
fi

log_debug "Determined backend type: ${backend_type}"
printf 'backend_type=%s\n' "$backend_type" >> "$GITHUB_OUTPUT"
