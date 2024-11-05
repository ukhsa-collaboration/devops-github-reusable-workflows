# devops-github-reusable-workflows

The devops-github-reusable-workflows repository provides a collection of reusable GitHub Actions workflows designed to simplify and standardise DevOps tasks across projects.

## Check Terraform Code
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

## Destroy Terraform stacks
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

## Deploy Terraform stacks
##### terraform-plan-apply.yml

This workflow handles the deployment of Terraform stacks, with various checks and approvals integrated into the process. It includes options for region, environment, and other deployment settings, designed to ensure safe and organised stack management within a CI/CD pipeline. This workflow includes dependency sorting for stack deployment, code linting, a Terraform plan step with optional manual approval, and post-deployment quality checks.

#### Workflow Inputs

`environment_name` (optional, default: dev): Specifies the target environment for the deployment (e.g., dev, prd).

`aws_region` (optional, default: eu-west-2): AWS region for deployment.

`destructive_action_check` (optional, default: false): Boolean to prevent unintentional destructive actions in Terraform plans.

`tflint_module_scan` (optional, default: false): Boolean to enable or disable TFLint’s module scan during code checks.

`execute_terraform_plan` (optional, default: false): Determines if the workflow should execute a Terraform apply after planning.

`repo` (optional, default: ${{ github.repository }}): The organisation/repository containing the Terraform code.

`ref` (optional, default: ${{ github.ref }}): Specifies the branch or tag of the Terraform code.

`runner_label` (optional, default: ubuntu-latest): Sets the runner for executing jobs. Use "self-hosted" if you have a self-hosted runner configured.

#### Secrets

`AWS_ROLE_NAME, AWS_ACCOUNT_ID` (optional): Credentials required for access to AWS.

`AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_RESOURCE_GROUP_NAME` (optional): Azure credentials for resource management and authentication.

`TF_MODULES_SSH_DEPLOY_KEY` (optional): SSH key for cloning Terraform modules.

`REPO_SSH_DEPLOY_KEY` (optional): SSH key for checking out private repositories.

## Terraform Core
##### terraform-core.yml

This workflow is generally not intended to be called directly by users. Instead, it is integrated into broader workflows within a CI/CD pipeline to streamline Terraform setup, configuration, and deployment across multiple directories, with conditional execution, artifact handling, and destruction checks built-in.


#### Workflow Inputs

`environment_name` (optional, default: dev): Specifies the deployment environment (e.g., dev, prd).

`aws_region` (optional, default: eu-west-2): The AWS region for the deployment.

`destructive_action_check` (optional, default: false): Boolean to enable a check for destructive actions during planning.

`execute_terraform_plan` (optional, default: false): Indicates whether to apply the Terraform plan or just create it.

`terraform_action` (optional, default: apply): Specifies the Terraform action to execute (apply or destroy).

`directories` (required): List of directories for Terraform stacks.

`max_parallel` (optional, default: 1): Sets the maximum number of parallel jobs to avoid conflicts.

`repo` (optional, default: ${{ github.repository }}): Organisation/repository containing the Terraform code.

`ref` (optional, default: ${{ github.ref }}): Branch or tag for the Terraform code.

`upload_plan` (optional, default: false): If true, uploads the generated Terraform plan as an artifact.

`download_existing_plan` (optional, default: false): If true, downloads an existing plan from a previous workflow.

`runner_label` (optional, default: ubuntu-latest): Specifies the runner for job execution. Use "self-hosted" for custom runners.

#### Secrets

`AWS_ROLE_NAME, AWS_ACCOUNT_ID` (optional): AWS credentials for interaction with AWS resources.

`AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_RESOURCE_GROUP_NAME` (optional): Azure credentials for managing resources.

`GH_TOKEN` (optional): GitHub token for managing resources in GitHub.

`TF_MODULES_SSH_DEPLOY_KEY` (optional): SSH key for cloning Terraform modules.

`REPO_SSH_DEPLOY_KEY` (optional): SSH key for checking out private repositories.


## Run post deployment QA checks
##### terraform-post-deployment-qa.yml

This workflow performs post-deployment quality assurance checks on Terraform-managed resources. It includes options for security, compliance, and threat model scans to ensure that deployed resources meet security and compliance standards.

#### Workflow Inputs

`environment_name` (optional, default: dev): Specifies the environment for the QA checks.

`aws_region` (optional, default: eu-west-2): The AWS region for running checks.

`runner_label` (optional, default: ubuntu-latest): Specifies the runner for executing checks. Use "self-hosted" for custom runners.

`directories` (required): List of directories for Terraform stacks to analyse.

`max_parallel` (optional, default: 5): Sets the maximum number of parallel jobs.

`zap_api_scan` (optional, default: false): Boolean to enable OWASP ZAP API scans.

`zap_endpoint_scan` (optional, default: false): Boolean to enable OWASP ZAP endpoint scans.

`prowler_scan` (optional, default: true): Enables a Prowler scan for AWS environment security checks.

`create_threat_model` (optional, default: true): Option to generate a threat model for the deployment.

#### Secrets

`AWS_ROLE_NAME, AWS_ACCOUNT_ID` (optional): AWS credentials for accessing and scanning resources.

`AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_RESOURCE_GROUP_NAME` (optional): Azure credentials for resource management and authentication.