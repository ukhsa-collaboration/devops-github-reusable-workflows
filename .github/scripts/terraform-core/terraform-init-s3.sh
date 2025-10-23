#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-}
AWS_REGION=${AWS_REGION:-}
ENVIRONMENT_NAME=${ENVIRONMENT_NAME:-}
TF_VERSION=${TF_VERSION:-}
state_name=${state_name:-}

for var_name in AWS_ACCOUNT_ID AWS_REGION ENVIRONMENT_NAME state_name; do
  if [[ -z "${!var_name}" ]]; then
    log_error "${var_name} environment variable is required for S3 backend initialisation."
    exit 1
  fi
done

if ! command -v terraform >/dev/null 2>&1; then
  log_error "Terraform command not found on PATH."
  exit 1
fi

s3_key="${ENVIRONMENT_NAME}/${state_name}/terraform.tfstate"
s3_bucket="${AWS_ACCOUNT_ID}-${AWS_REGION}-state"

log_debug "State will be persisted to: s3://${s3_bucket}/${s3_key}"

if [[ -n "$TF_VERSION" && "$(printf '%s\n' "1.11.0" "$TF_VERSION" | sort -V | head -n1)" == "1.11.0" ]]; then
  log_debug "Using native S3 locking (use_lockfile=true)."
  terraform init \
    -backend-config=use_lockfile=true \
    -backend-config="bucket=${s3_bucket}" \
    -backend-config="key=${s3_key}"
else
  log_debug "Using DynamoDB table for state locking."
  dynamodb_table="${AWS_REGION}-state-locks"
  terraform init \
    -backend-config="dynamodb_table=${dynamodb_table}" \
    -backend-config="bucket=${s3_bucket}" \
    -backend-config="key=${s3_key}"
fi
