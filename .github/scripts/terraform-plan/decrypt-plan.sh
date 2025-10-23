#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../lib/logging.sh
source "$SCRIPT_DIR/../lib/logging.sh"

ENCRYPTION_PASSPHRASE=${ENCRYPTION_PASSPHRASE:-}
PLAN_JSON_ENCRYPTED=${PLAN_JSON_ENCRYPTED:-tfplan.json.gpg}
PLAN_JSON_OUTPUT=${PLAN_JSON_OUTPUT:-tfplan.json}

if [[ -z "$ENCRYPTION_PASSPHRASE" ]]; then
  log_error "ENCRYPTION_PASSPHRASE environment variable is required."
  exit 1
fi

if [[ ! -f "$PLAN_JSON_ENCRYPTED" ]]; then
  log_error "Encrypted plan file '${PLAN_JSON_ENCRYPTED}' not found."
  exit 1
fi

if ! command -v gpg >/dev/null 2>&1; then
  log_error "Required command 'gpg' not found on PATH."
  exit 1
fi

pass_file=$(mktemp)
printf "%s" "$ENCRYPTION_PASSPHRASE" > "$pass_file"

if ! gpg --decrypt --batch --passphrase-file "$pass_file" --out "$PLAN_JSON_OUTPUT" "$PLAN_JSON_ENCRYPTED"; then
  rm -f "$pass_file"
  log_error "Failed to decrypt ${PLAN_JSON_ENCRYPTED}."
  exit 1
fi

rm -f "$pass_file"
log_debug "Decrypted ${PLAN_JSON_ENCRYPTED} to ${PLAN_JSON_OUTPUT}."
