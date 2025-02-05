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

`TF_PLAN_ENCRYPTION_PASSPHRASE`: The passphrase used to encrypt the TF plan artefact.