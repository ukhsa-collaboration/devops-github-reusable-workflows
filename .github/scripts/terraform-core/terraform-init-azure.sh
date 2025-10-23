#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

ENVIRONMENT_NAME=${ENVIRONMENT_NAME:-}
AZURE_RESOURCE_GROUP_NAME=${AZURE_RESOURCE_GROUP_NAME:-}
AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID:-}
state_name=${state_name:-}
stack_directory=${DIRECTORY:-}

if [[ -z "$stack_directory" ]]; then
  log_error "DIRECTORY environment variable is required."
  exit 1
fi

if [[ -z "$state_name" ]]; then
  log_error "state_name must be exported before running this script."
  exit 1
fi

if [[ -z "$AZURE_RESOURCE_GROUP_NAME" ]]; then
  log_error "AZURE_RESOURCE_GROUP_NAME is required for Azure backend initialisation."
  exit 1
fi

if [[ -z "$AZURE_SUBSCRIPTION_ID" ]]; then
  log_error "AZURE_SUBSCRIPTION_ID is required for Azure backend initialisation."
  exit 1
fi

if [[ -z "$ENVIRONMENT_NAME" ]]; then
  log_error "ENVIRONMENT_NAME is required for Azure backend initialisation."
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  log_error "Terraform command not found on PATH."
  exit 1
fi

container_name=$(dirname "$stack_directory" | tr -cd '[:alnum:]-' | cut -c1-62)
storage_account_name="$(echo "$AZURE_SUBSCRIPTION_ID" | tr -d '-' | cut -c 1-12)state"

log_debug "Initialising Terraform with Azure backend. Container: ${container_name}, Storage Account: ${storage_account_name}"

terraform init \
  -backend-config="storage_account_name=${storage_account_name}" \
  -backend-config="container_name=${container_name}" \
  -backend-config="key=${ENVIRONMENT_NAME}/${state_name}/terraform.tfstate" \
  -backend-config="resource_group_name=${AZURE_RESOURCE_GROUP_NAME}"
