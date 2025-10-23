#!/usr/bin/env python3

import json
import os
import sys
import uuid
from typing import Any


def main() -> int:
    raw = os.environ.get("RAW_TERRAFORM_VARS", "")
    trimmed = raw.strip()

    if not trimmed or trimmed == "{}":
        print("DEBUG: No additional Terraform variables provided.")
        return 0

    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        print(
            "ERROR: other_variables input must be valid JSON representing a flat object.",
            file=sys.stderr,
        )
        return 1

    if not isinstance(payload, dict):
        print(
            "ERROR: other_variables input must be a JSON object.",
            file=sys.stderr,
        )
        return 1

    github_env = os.environ.get("GITHUB_ENV")
    if not github_env:
        print(
            "ERROR: GITHUB_ENV environment variable is not set.",
            file=sys.stderr,
        )
        return 1

    with open(github_env, "a", encoding="utf-8") as env_file:
        for key, value in payload.items():
            if not isinstance(key, str) or not key.strip():
                print(
                    "ERROR: Encountered an empty or non-string key while processing other_variables.",
                    file=sys.stderr,
                )
                return 1

            text_value = _stringify_value(value)
            delimiter = f"EOF_{uuid.uuid4().hex}"

            env_file.write(f"TF_VAR_{key}<<{delimiter}\n")
            env_file.write(f"{text_value}\n")
            env_file.write(f"{delimiter}\n")

            print(f"DEBUG: Exported TF_VAR_{key}")

    return 0


def _stringify_value(value: Any) -> str:
    if isinstance(value, (dict, list)):
        return json.dumps(value)
    return str(value)


if __name__ == "__main__":
    sys.exit(main())
