## Docker Build with Optional Tests
##### container-image-build.yml

This GitHub Actions reusable workflow builds and optionally tests Docker images, supporting Azure Container Registry (ACR) and Amazon Elastic Container Registry (ECR) with caching for faster builds. It also supports multi-platform builds and integrates unit tests into the pipeline.


#### Features

- Multi-Platform Builds: Configure target platforms (e.g., linux/arm64).
- Registry Support: Push images to ACR or ECR with authentication via OIDC.
- Unit Tests: Optionally run unit tests on the built image before pushing.
- Build Caching: Leverage GitHub Actions cache and BuildKit for optimized build times.
- Custom Dockerfile & Build Context: Flexibly define Dockerfile paths and build contexts.

#### Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| run_tests | Enable or disable unit tests (true/false). | No | false |
| test_command | Command to run unit tests. | No | (empty) |
| dockerfile_path | Path to the Dockerfile. | No | ./Dockerfile |
| context | Docker build context. | No | . |
| image_name | Name of the Docker image. | Yes | 
| tags | Tags for the Docker image. | No | latest |
| build_args | Build arguments for Docker. | No | (empty) |
| aws_region | AWS region for ECR. | No | eu-west-2 |
| docker_platforms | Comma-separated list of platforms for multi-platform builds (e.g., linux/amd64,linux/arm64). | No | linux/arm64 |
| repo | Repository containing the Terraform code (org/repo format). | No | ${{ github.repository }} |
| ref | Branch of the Terraform code. | No | ${{ github.ref }} |

#### Secrets
| Name | Description | Required |
| AWS_ROLE_NAME | AWS role name for OIDC authentication. | No |
| AWS_ACCOUNT_ID | AWS account ID for ECR. | No |
| AZURE_SUBSCRIPTION_ID | Azure subscription ID. | No |
| AZURE_TENANT_ID | Azure tenant ID. | No |
| AZURE_CLIENT_ID | Azure client ID. | No |
| AZURE_RESOURCE_GROUP_NAME | Azure resource group name (optional). | No |

#### Example Usage

##### Build and Push to ACR

```yaml
jobs:
  docker-build:
    uses: ukhsa-collaboration/ukhsa-collaboration/.github/workflows/container-image-build.yml@main
    with:
      image_name: "my-image"
      tags: "v1.0.0"
      dockerfile_path: "./Dockerfile"
      context: "./"
    secrets:
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

##### Build, Test, and Push to ECR

```yaml
jobs:
  docker-build:
    uses: ukhsa-collaboration/ukhsa-collaboration/.github/workflows/container-image-build.yml@main
    with:
      run_tests: "true"
      test_command: "pytest"
      image_name: "my-image"
      tags: "v1.0.0"
      docker_platforms: "linux/amd64,linux/arm64"
      aws_region: "us-east-1"
    secrets:
      AWS_ROLE_NAME: ${{ secrets.AWS_ROLE_NAME }}
      AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
```

##### Local Build and Tests Without Pushing

```yaml
jobs:
  docker-build:
    uses: ukhsa-collaboration/ukhsa-collaboration/.github/workflows/container-image-build.yml@main
    with:
      run_tests: "true"
      test_command: "npm test"
      image_name: "test-image"
      tags: "local-test"
      docker_platforms: "linux/arm64"
```

#### Notes

Ensure the necessary secrets are configured for the target registry.
Use run_tests and test_command to enable unit tests before pushing the image. The `DOCKER_IMAGE` environment variable is available during tests and has a value of the image tag.
Set docker_platforms to target specific architectures. This is `linux/amd64` by default.

For questions or contributions, feel free to create an issue or pull request in the repository.