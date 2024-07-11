# devops-github-reusable-workflows

A collection of reusable Workflows to help standardise the CI pipelines of teams across the organisation.

## `[CI] Lint and Deploy Terraform stacks`

Deploys Terraform code that uses our standard folder structure. The Terraform code will be linted, scanned, validated, planned and deployed. This currently only supports using an AWS S3 backend. Support for using an Azure backend is planned.

