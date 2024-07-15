# TFLint Composite Action

This GitHub Action runs TFLint with the specified Terraform version and cloud provider.

## Inputs

### `terraform_version`

The Terraform version to use for the TFLint checks.

- **Required**: true
- **Default**: '1.9.1'

### `cloud_provider`

The cloud provider to use for TFLint checks. Valid values are `aws` or `azure`.

- **Required**: true
- **Default**: 'aws'

## Example Usage

```yaml
name: TFLint Example Workflow

on:
  push:
    branches:
      - main

jobs:
  tflint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Run TFLint Composite Action
        uses: UKHSA-Internal/devops-github-reusable-workflows@feature/DOE-80
        with:
          terraform_version: '1.9.1'
          cloud_provider: 'aws'

