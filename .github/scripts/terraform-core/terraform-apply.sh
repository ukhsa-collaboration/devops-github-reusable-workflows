#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

TERRAFORM_COMMAND=${TERRAFORM_COMMAND:-terraform}
TERRAFORM_ARGS=${TERRAFORM_ARGS:-}

if ! command -v "$TERRAFORM_COMMAND" >/dev/null 2>&1; then
  log_error "Required command '${TERRAFORM_COMMAND}' not found on PATH."
  exit 1
fi

if [[ ! -f tfplan ]]; then
  log_error "tfplan file not found; cannot apply."
  exit 1
fi

apply_cmd=("$TERRAFORM_COMMAND" apply)

if [[ -n "$TERRAFORM_ARGS" ]]; then
  # shellcheck disable=SC2206
  extra_args=($TERRAFORM_ARGS)
  apply_cmd+=("${extra_args[@]}")
fi

apply_cmd+=(tfplan)

log_debug "Running Terraform apply command: ${apply_cmd[*]}"
"${apply_cmd[@]}"
