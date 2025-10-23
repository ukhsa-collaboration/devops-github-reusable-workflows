#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

cache_dir="$HOME/.terraform.d/plugin-cache"

if [[ -z "${GITHUB_ENV:-}" ]]; then
  log_error "GITHUB_ENV environment variable is not set."
  exit 1
fi

printf 'TF_PLUGIN_CACHE_DIR=%s\n' "$cache_dir" >> "$GITHUB_ENV"
mkdir --parents "$cache_dir"
log_debug "Configured Terraform plugin cache at ${cache_dir}"
