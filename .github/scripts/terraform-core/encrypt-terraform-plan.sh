#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

ENCRYPTION_PASSPHRASE=${ENCRYPTION_PASSPHRASE:-}

if [[ -z "$ENCRYPTION_PASSPHRASE" ]]; then
  log_error "ENCRYPTION_PASSPHRASE environment variable is required."
  exit 1
fi

if ! command -v gpg >/dev/null 2>&1; then
  log_error "Required command 'gpg' not found on PATH."
  exit 1
fi

for plan_file in tfplan tfplan.json; do
  if [[ ! -f "$plan_file" ]]; then
    log_error "Required file '${plan_file}' not found for encryption."
    exit 1
  fi
done

pass_file=$(mktemp)
printf "%s" "$ENCRYPTION_PASSPHRASE" > "$pass_file"

if ! gpg --batch --symmetric --passphrase-file "$pass_file" tfplan; then
  log_error "Failed to encrypt tfplan."
  rm -f "$pass_file"
  exit 1
fi

if ! gpg --batch --symmetric --passphrase-file "$pass_file" tfplan.json; then
  log_error "Failed to encrypt tfplan.json."
  rm -f "$pass_file"
  exit 1
fi

rm -f tfplan tfplan.json "$pass_file"
log_debug "Encrypted tfplan and tfplan.json, removed unencrypted files."
