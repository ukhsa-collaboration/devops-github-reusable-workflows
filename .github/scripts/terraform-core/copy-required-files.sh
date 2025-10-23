#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

DIRECTORY=${DIRECTORY:-}

if [[ -z "$DIRECTORY" ]]; then
  log_error "DIRECTORY environment variable is required."
  exit 1
fi

files_to_copy=("providers.tf" "terraform.tf")

for FILE in "${files_to_copy[@]}"; do
  if [[ ! -f "$DIRECTORY/$FILE" ]]; then
    log_info "$(basename "$DIRECTORY") will attempt to use the ${FILE} file in the root directory."
    cp "$FILE" "$DIRECTORY/" || exit 1
  else
    log_debug "$(basename "$DIRECTORY") has its own ${FILE} file. Not copying."
  fi
done
