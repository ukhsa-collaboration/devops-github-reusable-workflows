#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../lib/logging.sh
source "$SCRIPT_DIR/../lib/logging.sh"

ENVIRONMENT_NAME=${ENVIRONMENT_NAME:-}
STACK_CONFIG_JSON=${STACK_CONFIG_JSON:-}

if [[ -z "$STACK_CONFIG_JSON" ]]; then
  log_error "STACK_CONFIG_JSON environment variable is required."
  exit 1
fi

if [[ -z "${GITHUB_OUTPUT:-}" ]]; then
  log_error "GITHUB_OUTPUT environment variable is not set."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  log_error "Required command 'jq' not found on PATH."
  exit 1
fi

filtered_matrix=$(printf '%s' "$STACK_CONFIG_JSON" | jq -c --arg env_name "$ENVIRONMENT_NAME" '
  [ .[]
    | select(.planned_changes == true)
    | if .runner_label == "self-hosted"
        then .runner_label = ["self-hosted", $env_name]
        else .
      end
  ]
')

log_debug "Filtered matrix: ${filtered_matrix}"

printf 'filtered_matrix=%s\n' "$filtered_matrix" >> "$GITHUB_OUTPUT"

empty_deps=$(printf '%s' "$filtered_matrix" | jq -c '[.[] | select((.dependencies | length) == 0)]')
non_empty_deps=$(printf '%s' "$filtered_matrix" | jq -c '[.[] | select((.dependencies | length) > 0)]')
combined_stacks=$(printf '%s %s' "$empty_deps" "$non_empty_deps" | jq -c -s add)

log_debug "Stacks without dependencies: ${empty_deps}"
log_debug "Stacks with dependencies: ${non_empty_deps}"
log_debug "Combined stacks: ${combined_stacks}"

{
  printf 'empty_deps=%s\n' "$empty_deps"
  printf 'non_empty_deps=%s\n' "$non_empty_deps"
  printf 'combined_stacks=%s\n' "$combined_stacks"
} >> "$GITHUB_OUTPUT"
