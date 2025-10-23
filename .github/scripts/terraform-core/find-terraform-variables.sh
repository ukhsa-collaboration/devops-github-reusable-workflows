#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

DIRECTORY=${DIRECTORY:-}
ENVIRONMENT_NAME=${ENVIRONMENT_NAME:-}

if [[ -z "$DIRECTORY" ]]; then
  log_error "DIRECTORY environment variable is required."
  exit 1
fi

if [[ -z "$ENVIRONMENT_NAME" ]]; then
  log_error "ENVIRONMENT_NAME environment variable is required."
  exit 1
fi

if [[ -z "${GITHUB_OUTPUT:-}" ]]; then
  log_error "GITHUB_OUTPUT environment variable is not set."
  exit 1
fi

resolve_path() {
  local path=$1
  if command -v realpath >/dev/null 2>&1; then
    realpath "$path"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$path"
  else
    readlink -f "$path"
  fi
}

var_flags=()

app_tfvars=$(find "./$DIRECTORY/tfvars/" -maxdepth 1 -name "*${ENVIRONMENT_NAME}.tfvars" -print -quit 2>/dev/null || true)
if [[ -f "$app_tfvars" ]]; then
  var_flags+=("-var-file=$(resolve_path "$app_tfvars")")
fi

env_tfvars="./environment/${ENVIRONMENT_NAME}.tfvars"
if [[ -f "$env_tfvars" ]]; then
  var_flags+=("-var-file=$(resolve_path "$env_tfvars")")
fi

global_tfvars="globals.tfvars"
if [[ -f "$global_tfvars" ]]; then
  var_flags+=("-var-file=$(resolve_path "$global_tfvars")")
fi

joined_flags=""
if (( ${#var_flags[@]} > 0 )); then
  joined_flags="${var_flags[*]}"
fi

log_debug "Will use variables: ${joined_flags}"
printf 'tf_vars=%s\n' "$joined_flags" >> "$GITHUB_OUTPUT"
