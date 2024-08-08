# Local Workflow with DevContainers and Act

This guide explains how to set up and use DevContainers and Act for initiating a local GitHub Actions workflow.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1. **VS Code IDE**: Install [Visual Studio Code](https://code.visualstudio.com/).

2. **DevContainers Extension**: Install the required prerequisites for DevContainers as well as the [DevContainers extension](https://code.visualstudio.com/docs/devcontainers/containers#_installation) in VS Code.

3. **GitHub PAT**: Create a [Personal Access Token (PAT)](https://github.com/settings/tokens) with the following scopes:
   - `read:packages`
   - `repo`

4. Don't forget to **configure SSO** to the UKHSA-Internal organisation for your GitHub token!

5. **Cloud Service Provider Credentials**: Ensure you have the appropriate credentials with access to your remote development environment.

### If you're not using DevContainers

1. You'll need a way to run containers on your local machine. Containers will be started as part of the workflows initiated by Act.

2. Install Act on your local machine by following their [installation instructions](https://nektosact.com/installation/index.html).

## Usage

Follow these steps to set up and run the [local workflow](terraform-local-workflow.yml) using DevContainers and Act:

1. **Authenticate to the GitHub Container Registry**:
   - Currently, there's an image within a private registry in GHCR. You'll need to authenticate locally before the workflows can pull the image.
   - `echo $GITHUB_PAT | docker login ghcr.io -u <github-user-name> --password-stdin`

2. **Create DevContainer configuration**:
   - From the template repository, you can copy the minimum required [DevContainer configuration](https://github.com/UKHSA-Internal/devops-terraform-template/blob/main/.devcontainer) and create the same contents within your repository. 

3. **Create Act configuration files**:
   - From the [template repository](https://github.com/UKHSA-Internal/devops-terraform-template/blob/main), you can copy the required Act configuration files:
     - `.actrc`
     - `.github/act/.input`
     - `.github/act/.secret.template`
     - and the appropriate `.gitignore` changes:
     ```sh
     # Act secrets
     .secret
     .github/act/.secret
     ```

4. **Configure Inputs**:
   - The `.github/act/.input` file is configurable dependent on what elements of the workflow you want to run. Every field is optional and reflect the same steps that are invoked in the remote workflows. 

   | Input          | Values                | Description |
   |----------------|-----------------------|-------------|
   | stack          | a singular stack name | Leave empty if you want to run the workflow against all Terraform stacks. |
   | run_formatting | true \| false         | To run the `terrform format` step or not. |
   | run_tflint     | true \| false         | To run the `tflint` step or not. |
   | run_light_sast | true \| false         | To run light SAST scans or not. |
   | run_deep_sast  | true \| false         | To run deep SAST scans or not. **Requires `plan` to be `true`**. |
   | plan           | true \| false         | To run the `terrform plan` step or not. |

5. **Configure Secrets**:
   - Only the `GITHUB_PAT` is required for minimal workflow testing. The cloud service provider credentials are required if you want to connect to the remote environment to run a plan and deep analysis.
   - Copy the `.github/act/.secret.template` file to `.github/act/.secret`.
   - Populate the `.github/act/.secret` file with the following values:

   | Secret                | Values                     | Description |
   |-----------------------|----------------------------|-------------|
   | GITHUB_PAT           | Your GitHub PAT           | This is a mandatory secret as dependent repositories are private. |
   | AWS_ACCESS_KEY_ID*     | Your AWS Access Key       | The AWS Access Key for your personal IAM user. |
   | AWS_SECRET_ACCESS_KEY* | Your AWS Secret Key       | The associated AWS Secret Key for your personal IAM user. |
   | AWS_ACCOUNT_ID*        | The AWS account ID        | The account that you want to deploy / plan against. This contains the statefile bucket and the resources. |
   | AWS_ROLE_NAME*         | local-workflow-role       | This is the default name of the role to be provisioned with minimal permissions to permit running `terraform plan` as part of the local worklow. |
   | AZURE_CLIENT_ID*       | Your Service Principal ID | This Service Principal must only have permission to run `terraform plan`.  |
   | AZURE_TENANT_ID*       | The Azure Tenant ID       | The Tenant ID where your Service Principal and subscription are located. |
   | AZURE_SUBSCRIPTION_ID* | Your Subscription ID      | The subscription that you want to deploy / plan against. This contains the statefile store and the resources. |

   *Optional secrets, for if you want to connect to your remote environment.

6. **Create local workflow**:
   - From the template repository, you can copy the [local workflow configuration](https://github.com/UKHSA-Internal/devops-terraform-template/blob/main/.github/workflows/local_terraform_workflow.yml) into your repository.

7. **Open the folder in VS Code**:
   - Open the command pallete (`View > Command Palette`) > and run `Dev Containers: Open Folder in Container`. Select the appropriate git repository parent folder which contains the `.devcontainer/devcontainer.json` configuration. 

8. **Open a new terminal session**:
   - Once the DevContainer has initialized, open a new terminal session within VS Code; `Terminal > New Terminal`. This will be a new terminal session within your Dev Container. 

9. **Run the Workflow**:
   - Within your new terminal, execute the following command to run the workflow using Act:
     ```sh
     act -W .github/workflows/local_terraform_workflow.yml
     ```

### If you're running into difficulties, reset and try again!

If you encounter issues when running your workflow in the DevContainer, try the following steps to reset the environment and start fresh:

1. **Stop all running containers on your machine**
   - **Warning**; this is quite drastic for general use, but ensures a clean environment.
   - **Command**: `docker stop $(docker ps -q)`

2. **Clear Docker Cache**:
   - **Command**: `docker system prune -a -f --volumes`
   - This command removes all unused Docker data, including:
     - Containers
     - Images
     - Build Cache
     - Volumes

3. **Restart the DevContainer**:
   - Open the command palette in VS Code and run `Dev Containers: Reopen in Container`.
   - Restarting the DevContainer can resolve issues related to the development environment not initializing correctly or not reflecting recent changes. This command reopens your project within the DevContainer, effectively resetting the environment.