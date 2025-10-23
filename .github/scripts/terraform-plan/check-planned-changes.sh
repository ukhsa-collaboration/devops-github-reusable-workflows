#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../lib/logging.sh
source "$SCRIPT_DIR/../lib/logging.sh"

MATRIX_FILE=${MATRIX_FILE:-updated_matrix.json}

if [[ -z "${GITHUB_OUTPUT:-}" ]]; then
  log_error "GITHUB_OUTPUT environment variable is not set."
  exit 1
fi

if [[ ! -f "$MATRIX_FILE" ]]; then
  log_error "Matrix file '${MATRIX_FILE}' not found."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  log_error "Required command 'jq' not found on PATH."
  exit 1
fi

planned_changes=$(jq -r '.planned_changes' "$MATRIX_FILE")

if [[ -z "$planned_changes" ]]; then
  log_error "Unable to read planned_changes from ${MATRIX_FILE}."
  exit 1
fi

log_debug "planned_changes: ${planned_changes}"
printf 'planned_changes=%s\n' "$planned_changes" >> "$GITHUB_OUTPUT"
