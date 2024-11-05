## Terraform Code Check
##### terraform-code-check.yml

This workflow performs a series of checks on Terraform code, ensuring it meets formatting and security standards. It supports various configuration options, allowing users to tailor the workflow to their specific Terraform setup. The workflow includes linting, formatting, and security scanning steps, providing detailed status feedback.

#### Workflow Inputs

`stack_root_directory` (required): Specifies the root directory of the Terraform stack for code checks.

`tflint_module_scan` (optional): Boolean value indicating whether TFLint should download Terraform modules during the linting process.

`checkov_deep_scan` (optional, default: false): Boolean value determining if Checkov should perform a deep scan, which includes external modules.

`repo` (optional, default: ${{ github.repository }}): The organisation/repository name of the repository containing Terraform code. Typically left blank to clone the calling repository.

`ref` (optional, default: ${{ github.ref }}): Specifies the branch or tag of the Terraform code to check. By default, it uses the branch of the calling workflow.

`runner_label` (optional, default: ubuntu-latest): Defines the runner environment for executing the workflow. Use "self-hosted" if a custom runner is configured.

#### Secrets

`TF_MODULES_SSH_DEPLOY_KEY` (optional): SSH key for cloning Terraform modules during terraform init.

`REPO_SSH_DEPLOY_KEY` (optional): SSH key for cloning the repository with Terraform stacks.