#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

STACK_DIRECTORY=${STACK_DIRECTORY:-}
RUNNER_LABEL_JSON=${RUNNER_LABEL_JSON:-}
PLANNED_CHANGES=${PLANNED_CHANGES:-false}
STACK_ORDER=${STACK_ORDER:-0}
SKIP_WHEN_DESTROYING=${SKIP_WHEN_DESTROYING:-false}

if [[ -z "$STACK_DIRECTORY" ]]; then
  log_error "STACK_DIRECTORY environment variable is required."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  log_error "Required command 'jq' not found on PATH."
  exit 1
fi

log_debug "runner_label is: ${RUNNER_LABEL_JSON}"

jq -n \
  --arg dir "$STACK_DIRECTORY" \
  --argjson runner_label "$RUNNER_LABEL_JSON" \
  --argjson planned_changes "$PLANNED_CHANGES" \
  --argjson order "$STACK_ORDER" \
  --argjson skip_when_destroying "$SKIP_WHEN_DESTROYING" \
  '{
    directory: $dir,
    runner_label: ($runner_label | if type=="array" then . else [.] end),
    planned_changes: $planned_changes,
    order: $order,
    skip_when_destroying: $skip_when_destroying
  }' \
  > updated_matrix.json

log_debug "Wrote updated matrix to updated_matrix.json"
cat updated_matrix.json
