#!/usr/bin/env python3

"""Filter Terraform stack definitions based on planned changes and dependencies."""

import json
import os
import sys
from typing import Any, Dict, List


def log_debug(message: str) -> None:
    print(f"DEBUG: {message}", file=sys.stderr)


def log_error(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)


def load_stack_config(raw_config: str) -> List[Dict[str, Any]]:
    try:
        config = json.loads(raw_config)
    except json.JSONDecodeError as exc:
        log_error(f"STACK_CONFIG_JSON must be valid JSON: {exc}")
        sys.exit(1)

    if not isinstance(config, list):
        log_error("STACK_CONFIG_JSON must be a JSON array of stack objects.")
        sys.exit(1)

    return config


def ensure_output_file() -> str:
    github_output = os.environ.get("GITHUB_OUTPUT")
    if not github_output:
        log_error("GITHUB_OUTPUT environment variable is not set.")
        sys.exit(1)
    return github_output


def filter_stacks(
    stacks: List[Dict[str, Any]], environment_name: str
) -> List[Dict[str, Any]]:
    filtered: List[Dict[str, Any]] = []
    for stack in stacks:
        if not stack.get("planned_changes"):
            continue

        runner_label = stack.get("runner_label")
        if runner_label == "self-hosted":
            stack = dict(stack)  # shallow copy to avoid mutating original
            stack["runner_label"] = ["self-hosted", environment_name]
        filtered.append(stack)

    log_debug(f"Filtered matrix: {json.dumps(filtered)}")
    return filtered


def split_dependencies(
    filtered_stacks: List[Dict[str, Any]],
) -> Dict[str, List[Dict[str, Any]]]:
    empty_deps: List[Dict[str, Any]] = []
    non_empty_deps: List[Dict[str, Any]] = []

    for stack in filtered_stacks:
        dependencies = stack.get("dependencies", [])
        if isinstance(dependencies, list) and len(dependencies) > 0:
            non_empty_deps.append(stack)
        else:
            empty_deps.append(stack)

    combined = empty_deps + non_empty_deps

    log_debug(f"Stacks without dependencies: {json.dumps(empty_deps)}")
    log_debug(f"Stacks with dependencies: {json.dumps(non_empty_deps)}")
    log_debug(f"Combined stacks: {json.dumps(combined)}")

    return {
        "empty_deps": empty_deps,
        "non_empty_deps": non_empty_deps,
        "combined_stacks": combined,
    }


def write_outputs(
    filtered: List[Dict[str, Any]],
    groups: Dict[str, List[Dict[str, Any]]],
    output_path: str,
) -> None:
    with open(output_path, "a", encoding="utf-8") as output_file:
        output_file.write(f"filtered_matrix={json.dumps(filtered)}\n")
        output_file.write(f"empty_deps={json.dumps(groups['empty_deps'])}\n")
        output_file.write(f"non_empty_deps={json.dumps(groups['non_empty_deps'])}\n")
        output_file.write(f"combined_stacks={json.dumps(groups['combined_stacks'])}\n")


def main() -> int:
    environment_name = os.environ.get("ENVIRONMENT_NAME", "")
    stack_config_json = os.environ.get("STACK_CONFIG_JSON")

    if not stack_config_json:
        log_error("STACK_CONFIG_JSON environment variable is required.")
        return 1

    stacks = load_stack_config(stack_config_json)
    filtered = filter_stacks(stacks, environment_name)
    groups = split_dependencies(filtered)

    output_path = ensure_output_file()
    write_outputs(filtered, groups, output_path)

    return 0


if __name__ == "__main__":
    sys.exit(main())
