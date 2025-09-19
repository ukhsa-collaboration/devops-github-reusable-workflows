# Container Image Build - Python/AWS Workflow

Reusable workflow that builds and tests a Python-based container image, surfaces results in GitHub summaries/PR comments, optionally tags the image for release, and can drive opinionated Amazon ECS deployments.

## Overview
- `.python-version` pins interpreter version locally and in CI for consistent tooling.
- Prefers `pyproject.toml` (with pinned dependencies and optional extras) but falls back to requirements.txt and requirements-dev.txt files.
- Runs Hadolint (optional) plus Ruff format/lint checks for Python projects.
- Supports arbitrary unit/integration test commands; results are summarised and commented on PRs.
- Builds with `docker/build-push-action` without Github-specific caching so it works well on self-hosted runners.
- Optionally pushes/publishes to Amazon ECR, signs release digests with Cosign, and deploys to ECS services per-environment.

## Prerequisites
- The calling repository must contain a Dockerfile and whatever Python/test assets your commands require (ideally managed via `pyproject.toml` so dependencies remain pinned).
- When pushing to ECR or deploying, create the following secrets in the caller repository or organisation:
  - `AWS_ACCOUNT_ID_ECR_REGISTRY`: Account id that owns the ECR registry.
  - `AWS_DEPLOY_ROLE`: IAM role name that should be assumed for all AWS actions.
  - `AWS_ACCOUNT_ID_<ENV>` for every deployment environment (e.g. `AWS_ACCOUNT_ID_DEV`). Reference the secret name in the `deploy_environments` matrix.

## Required Inputs
| Input | Type | Description |
| --- | --- | --- |
| `app_name` | string | Application name used to name images and smoke-test messaging. |
| `service_identifier` | string | Identifier used for registry paths, SSM keys, and ECS resource names. |

## Frequently Used Inputs
| Input | Type | Default | Purpose |
| --- | --- | --- | --- |
| `runner_labels` | string | `["ubuntu-latest"]` | JSON array of runner labels. |
| `run_unit_tests` | boolean | `true` | Enable/disable unit tests. |
| `unit_test_command` | string | `pytest -q` | Command executed for unit tests. |
| `run_integration_tests` | boolean | `false` | Toggle integration tests in the build job. |
| `integration_test_command` | string | `""` | Command executed when integration tests enabled. |
| `push_image` | boolean | `false` | Push built image to the registry. Required for release/deploy. |
| `release_tag` | string | `""` | Tag applied in the release job (enables release/deploy when non-empty). |
| `deploy_environments` | string | `[]` | JSON array describing deployments. See below. |
| `registry_hostname` | string | `""` | Override registry host (defaults to `${account}.dkr.ecr.${region}.amazonaws.com`). |
| `lint_dockerfile` / `lint_python` | boolean | `true` | Toggle linting stages. |
| `enable_trivy` | boolean | `true` | Run Trivy scan when image is pushed. |
| `sign_release` | boolean | `false` | Sign the pushed digest with Cosign during the release job. |

> Additional inputs are documented inline in `.github/workflows/container-image-build-python.yml` but are not typically changed.

## Deployment Matrix Schema
Provide `deploy_environments` as a JSON array. Each object supports:

```json
[
  {
    "name": "dev",
    "aws_account_id_secret": "AWS_ACCOUNT_ID_DEV",
    "ssm_parameter_name": "/myapp/dev/image_tag",
    "task_definition": "my-ecs-task",
    "container_name": "app",
    "ecs_cluster": "my-ecs-cluster",
    "ecs_service": "my-ecs-service",
    "base_url": "https://dev.example.com",
    "integration_test_command": "pytest tests/integration --base-url=$BASE_URL",
    "deploy_script": "scripts/post_deploy.sh",
    "smoke_test_url": "https://dev.example.com/health"
  }
]
```

Fields are optional; omit keys you do not need. The deploy job only runs when `deploy_environments` is non-empty **and** both `push_image` and `release_tag` are set.

## Example Caller Workflow
```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  container:
    uses: ukhsa-colloboration/devops-github-reusable-workflows/.github/workflows/container-image-build-python.yml@v1
    with:
      app_name: frontend
      service_identifier: my-service
      push_image: ${{ github.ref == 'refs/heads/main' }}
      release_tag: ${{ github.ref_name }}
      deploy_environments: >-
        [
          {
            "name": "dev",
            "base_url": "https://dev.example.com",
            "smoke_test_url": "https://dev.example.com/health"
          }
        ]
    secrets: inherit
```

## Regression Tests
`_test-container-image-build-python.yml` reuses the workflow against a lightweight fixture in `fixtures/container_image_app`.

- The fixture ships with a pinned `pyproject.toml` (including `ruff` and `pytest`) and uses `tool.pytest.ini_options` so no `PYTHONPATH` overrides are required.
- Developers get the same Python version locally thanks to the `.python-version` file in the repo root.

You can execute the regression workflow locally with [act](https://github.com/nektos/act):

```bash
act pull_request -W .github/workflows/_test-container-image-build-python.yml --container-architecture linux/amd64
```

## Surfacing Results
- The build job writes a markdown summary to the Actions job summary and posts/updates a PR comment (with a hidden marker) so reviewers do not have to inspect logs.
- Trivy results, unit/integration test status, and the image reference all appear in the summary.
- Release and deployment jobs append their own sections to the summary for downstream visibility.

## Notes
- Trivy scanning requires the image to be pushed; disable `enable_trivy` or skip pushing if scanning is not desired.
- The release/deploy jobs assume Amazon ECR/ECS; customise or set `deploy_environments: []` to disable them.
- Caching is intentionally minimal to ensure compatibility with self-hosted runners without GitHub cache services.
