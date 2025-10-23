#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/logging.sh"

SSH_DEPLOY_KEY=${SSH_DEPLOY_KEY:-}
SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-/tmp/ssh_agent.sock}

ensure_command() {
  local cmd=$1
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Required command '${cmd}' not found on PATH."
    exit 1
  fi
}

if [[ -z "${GITHUB_ENV:-}" ]]; then
  log_error "GITHUB_ENV environment variable is not set."
  exit 1
fi

if [[ -n "$SSH_DEPLOY_KEY" ]]; then
  ensure_command ssh-keyscan
  ensure_command ssh-agent
  ensure_command ssh-add

  mkdir -p ~/.ssh
  ssh-keyscan github.com >> ~/.ssh/known_hosts
  eval "$(ssh-agent -a "$SSH_AUTH_SOCK" -s)"
  echo "$SSH_DEPLOY_KEY" | tr -d '\r' | ssh-add -
  log_debug "Added SSH deploy key to agent."
else
  log_debug "SSH deploy key not provided; skipping agent configuration."
fi

printf 'SSH_AUTH_SOCK=%s\n' "$SSH_AUTH_SOCK" >> "$GITHUB_ENV"
