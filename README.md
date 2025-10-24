 # GitHub Actions Workflows Documentation

This repository contains several reusable GitHub Actions workflows. Below is an overview and links to detailed documentation for each workflow.

> :warning: To avoid unexpected breaking changes, it is recommended that you pin to a specific version of this repo using either a git tag or a commit hash and not to use `main`. This practice will help ensure the stability of your workflows.

## Workflows

1. [Terraform Code Check](docs/terraform-code-check.md)
2. [Terraform Plan Apply](docs/terraform-plan-apply.md)
3. [Terraform Destroy](docs/terraform-destroy.md)
4. [Terraform Core](docs/terraform-core.md)
6. [Container Image Build (Python)](docs/container-image-build-python.md)

## Testing

- Each workflow has a matching `_test-*.yml` regression workflow. These tests exercise the reusable workflow with lightweight fixtures so breaking changes surface before release.
- `_skip_test-*.yml` workflows are intentional noops used to satisfy branch protection rules when a workflow must report success even if the full regression run is skipped.
- Run the associated regression workflow locally with [`act`](https://github.com/nektos/act) (e.g. `act pull_request -W .github/workflows/_test-container-image-build-python-aws-ecs.yml --container-architecture linux/amd64`) before pushing updates.
