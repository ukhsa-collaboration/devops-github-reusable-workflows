#!/usr/bin/env python3

"""Build the updated matrix entry for downstream Terraform jobs."""

import json
import os
import sys
from typing import Any, List


def log_debug(message: str) -> None:
    print(f"DEBUG: {message}", file=sys.stderr)


def log_error(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)


def parse_bool(value: Any, default: bool = False) -> bool:
    if value is None:
        return default
    return str(value).strip().lower() in {"1", "true", "yes", "on"}


def parse_int(value: Any, default: int = 0) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def load_runner_labels(raw: str) -> List[str]:
    if not raw:
        return []
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError as exc:
        log_error(f"RUNNER_LABEL_JSON is not valid JSON: {exc}")
        sys.exit(1)

    if isinstance(parsed, list):
        return [str(item) for item in parsed]
    if isinstance(parsed, str):
        return [parsed]

    log_error(
        "RUNNER_LABEL_JSON must be a JSON string or array of strings. "
        f"Received: {type(parsed).__name__}"
    )
    sys.exit(1)


def main() -> int:
    stack_directory = os.environ.get("STACK_DIRECTORY")
    if not stack_directory:
        log_error("STACK_DIRECTORY environment variable is required.")
        return 1

    runner_label_json = os.environ.get("RUNNER_LABEL_JSON", "")
    planned_changes_raw = os.environ.get("PLANNED_CHANGES")
    stack_order_raw = os.environ.get("STACK_ORDER")
    skip_when_destroying_raw = os.environ.get("SKIP_WHEN_DESTROYING")

    runner_labels = load_runner_labels(runner_label_json)
    planned_changes = parse_bool(planned_changes_raw, default=False)
    stack_order = parse_int(stack_order_raw, default=0)
    skip_when_destroying = parse_bool(skip_when_destroying_raw, default=False)

    log_debug(f"runner_label is: {runner_labels}")

    matrix_entry = {
        "directory": stack_directory,
        "runner_label": runner_labels,
        "planned_changes": planned_changes,
        "order": stack_order,
        "skip_when_destroying": skip_when_destroying,
    }

    output_path = "updated_matrix.json"
    with open(output_path, "w", encoding="utf-8") as json_file:
        json.dump(matrix_entry, json_file)

    log_debug(f"Wrote updated matrix to {output_path}")
    print(json.dumps(matrix_entry))

    return 0


if __name__ == "__main__":
    sys.exit(main())
