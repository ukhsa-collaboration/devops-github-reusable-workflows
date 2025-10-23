#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

STACK_DIRECTORY=${STACK_DIRECTORY:-}

if [[ -z "$STACK_DIRECTORY" ]]; then
  log_error "STACK_DIRECTORY environment variable is required."
  exit 1
fi

if [[ -z "${GITHUB_ENV:-}" ]]; then
  log_error "GITHUB_ENV environment variable is not set."
  exit 1
fi

state_name=$(basename "$STACK_DIRECTORY")
printf 'state_name=%s\n' "$state_name" >> "$GITHUB_ENV"
log_debug "Exported state_name=${state_name}"
