#!/usr/bin/env bash

# Utility logging helpers for workflow scripts.

log_debug() {
  printf 'DEBUG: %s\n' "$*" >&2
}

log_info() {
  printf 'INFO: %s\n' "$*" >&2
}

log_error() {
  printf 'ERROR: %s\n' "$*" >&2
}
