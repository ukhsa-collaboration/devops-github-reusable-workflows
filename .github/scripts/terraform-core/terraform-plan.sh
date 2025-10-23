#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

TERRAFORM_COMMAND=${TERRAFORM_COMMAND:-terraform}
TERRAFORM_ARGS=${TERRAFORM_ARGS:-}
TERRAFORM_VARIABLES=${TERRAFORM_VARIABLES:-}
TERRAFORM_ACTION=${TERRAFORM_ACTION:-apply}
SKIP_DESTROY=${SKIP_DESTROY:-false}

require_command() {
  local cmd=$1
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Required command '${cmd}' not found on PATH."
    exit 1
  fi
}

append_outputs() {
  if [[ -z "${GITHUB_OUTPUT:-}" ]]; then
    log_error "GITHUB_OUTPUT environment variable is not set."
    exit 1
  fi

  {
    printf 'terraform_exit_code=%s\n' "$terraform_exit_code"
    printf 'planned_changes=%s\n' "$planned_changes"
  } >> "$GITHUB_OUTPUT"
}

require_command "$TERRAFORM_COMMAND"
require_command jq

terraform_exit_code=0
planned_changes=
skip_destroy_normalized=${SKIP_DESTROY,,}

if [[ "$TERRAFORM_ACTION" == "destroy" && "$skip_destroy_normalized" == "true" ]]; then
  log_debug "Skipping terraform plan because SKIP_DESTROY flag in this stack is true."
  planned_changes=false
  append_outputs
  exit 0
fi

log_debug "Running terraform plan (action: ${TERRAFORM_ACTION})"

plan_cmd=("$TERRAFORM_COMMAND" plan -out=tfplan -detailed-exitcode -compact-warnings)

if [[ "$TERRAFORM_ACTION" == "destroy" ]]; then
  plan_cmd+=(-destroy)
fi

if [[ -n "$TERRAFORM_ARGS" ]]; then
  # shellcheck disable=SC2206
  extra_args=($TERRAFORM_ARGS)
  plan_cmd+=("${extra_args[@]}")
fi

if [[ -n "$TERRAFORM_VARIABLES" ]]; then
  # shellcheck disable=SC2206
  var_args=($TERRAFORM_VARIABLES)
  plan_cmd+=("${var_args[@]}")
fi

log_debug "Plan command: ${plan_cmd[*]}"

if ! "${plan_cmd[@]}"; then
  terraform_exit_code=$?
fi

log_debug "Terraform exit code is $terraform_exit_code"

if [[ $terraform_exit_code -eq 0 ]]; then
  log_debug "Terraform Plan exit code indicated no changes."
  planned_changes=false
elif [[ $terraform_exit_code -eq 2 ]]; then
  log_debug "Terraform Plan exit code indicated changes."
  planned_changes=true
else
  planned_changes=
  append_outputs
  log_error "Terraform plan failed with exit code $terraform_exit_code"
  exit "$terraform_exit_code"
fi

if [[ $terraform_exit_code -eq 0 || $terraform_exit_code -eq 2 ]]; then
  show_cmd=("$TERRAFORM_COMMAND" show -json tfplan)
  if ! "${show_cmd[@]}" | jq > tfplan.json; then
    log_error "Failed to generate tfplan.json output."
    exit 1
  fi
fi

append_outputs
