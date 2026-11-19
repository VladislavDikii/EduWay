# EduWay Amazon ECR Repositories

This Terraform configuration creates one Amazon ECR repository for each name in
`ecr_repositories`. The current configuration creates repositories for the
backend, frontend, and database seeder images.

## Prerequisites

- Terraform installed
- AWS credentials configured for the account where the repositories should be created
- An IAM identity with permission to manage ECR repositories and access the S3
  Terraform state bucket
- The Terraform state bucket `eduway2026-tfstate-bucket` already created in
  `eu-central-1`

See [`../../README.md`](../../README.md) for instructions to create the state
bucket and configure AWS credentials.

> **Warning:** The repository resource sets `force_delete = true`. Terraform can
> delete repositories that still contain images. Review the plan carefully
> before applying changes that replace or destroy repositories.

## Configure the repositories

From this directory, copy the example variables file if you do not already have
a local `terraform.tfvars`:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set the repository names:

```hcl
ecr_repositories = [
  "eduway2026backend",
  "eduway2026frontend",
  "eduway2026dbseeder"
]
```

ECR repository names must be lowercase. `terraform.tfvars` is a local
configuration file and is excluded from version control.

The module applies these tags to each repository:

| Key | Value |
| --- | --- |
| `Project` | `EduWay2026` |
| `Purpose` | `ContainerRegistry` |
| `Environment` | `Shared` |
| `ManagedBy` | `Terraform` |
| `Name` | The repository name |

## Initialize and review

Initialize Terraform from this directory:

```sh
terraform init
```

Format and validate the configuration, then inspect the proposed changes:

```sh
terraform fmt -check
terraform validate
terraform plan
```

Check that the plan creates the expected repositories and does not unexpectedly
replace or destroy existing ones.

## Create the repositories

If the plan is correct, apply it:

```sh
terraform apply
```

Review the plan again when prompted and confirm to create the repositories.

## Push an image

After creation, get the AWS account ID and authenticate Docker to ECR:

```sh
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region eu-central-1 \
  | docker login --username AWS --password-stdin \
    "${AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com"
```

Tag a locally built image with the repository URI and push it. For example:

```sh
docker tag eduway-backend:latest \
  "${AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/eduway2026backend:latest"
docker push \
  "${AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/eduway2026backend:latest"
```

Replace the local image name and ECR repository name as needed.

## Future automation

Eventually, infrastructure provisioning and image publishing can be automated
with GitHub Actions or a similar CI/CD system. A workflow could validate and
plan Terraform changes, apply approved changes, build the backend, frontend,
and database seeder images, then push them to their ECR repositories.

The workflow should use an appropriately scoped AWS identity. Where supported,
prefer short-lived credentials through GitHub Actions OIDC over long-lived AWS
access keys stored as repository secrets. Keep infrastructure changes and image
publishing steps reviewable, and require approval before applying production
infrastructure changes.
