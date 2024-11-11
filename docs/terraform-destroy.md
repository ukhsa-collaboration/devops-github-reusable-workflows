## Terraform Destroy
##### terrraform-destroy.yml

This workflow facilitates the destruction of Terraform-managed resources, designed to run as part of a continuous integration pipeline. It provides configuration options for the environment and AWS region, with additional controls for executing the Terraform plan. This workflow executes a reverse-ordered destruction process for Terraform stacks, utilising defined directory dependencies for resource teardown.

#### Workflow Inputs

`environment_name` (optional, default: dev): Specifies the environment in which to destroy resources (e.g., dev, prd).

`aws_region` (optional, default: eu-west-2): AWS region for executing the destruction process.

`execute_terraform_plan` (optional, default: false): Boolean to determine whether to perform a Terraform plan execution before destroy.

`repo` (optional, default: ${{ github.repository }}): Organisation/repository name containing the Terraform code.

`ref` (optional, default: ${{ github.ref }}): Branch or tag of the Terraform code. Defaults to the calling workflow’s branch.

`runner_label` (optional, default: ubuntu-latest): Target runner environment. Use "self-hosted" for custom runners, or leave as default.

#### Secrets

`AWS_ROLE_NAME, AWS_ACCOUNT_ID` (optional): Credentials for AWS account access. Not compatiable with Azure credentials.

`AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_RESOURCE_GROUP_NAME` (optional): Azure credentials for authentication and resource management. Not compatiable with AWS credentials.

`TF_MODULES_SSH_DEPLOY_KEY` (optional): SSH key to clone Terraform modules as part of initialisation.

`REPO_SSH_DEPLOY_KEY` (optional): SSH key to checkout private repositories with remote Terraform configurations.