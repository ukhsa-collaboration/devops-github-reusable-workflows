## Terraform Plan Apply
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
