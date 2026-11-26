# Terraform — AWS Infrastructure

This directory contains shared AWS infrastructure guidance and Terraform
modules. Each module is managed independently from its own directory.

## AWS credentials

Before using the AWS CLI or Terraform, configure credentials for the AWS
account where you want to create resources:

```sh
export AWS_ACCESS_KEY_ID="<your-access-key-id>"
export AWS_SECRET_ACCESS_KEY="<your-secret-access-key>"
export AWS_DEFAULT_REGION="eu-central-1"
```

## Terraform state bucket

The Terraform modules store remote state in the S3 bucket
`eduway2026-tfstate-bucket` in `eu-central-1`. Create the bucket before
initializing a module that uses it:

```sh
aws s3api create-bucket \
  --bucket eduway2026-tfstate-bucket \
  --region eu-central-1 \
  --create-bucket-configuration LocationConstraint=eu-central-1 \
  --tagging 'TagSet=[{Key=Project,Value=EduWay2026},{Key=Purpose,Value=TerraformState},{Key=Environment,Value=Shared},{Key=ManagedBy,Value=Terraform}]'
```

Apply the tags:

```sh
aws s3api put-bucket-tagging \
  --bucket eduway2026-tfstate-bucket \
  --region eu-central-1 \
  --tagging 'TagSet=[{Key=Project,Value=EduWay2026},{Key=Purpose,Value=TerraformState},{Key=Environment,Value=Shared},{Key=ManagedBy,Value=Terraform}]'
```

> **Warning:** Do not delete this bucket until all infrastructure managed with
> its state has been destroyed. Terraform needs the stored state to manage and
> destroy that infrastructure.

After destroying the infrastructure, delete the bucket by first removing its
objects and then deleting the bucket:

```sh
aws s3 rm s3://eduway2026-tfstate-bucket --recursive --region eu-central-1
aws s3api delete-bucket \
  --bucket eduway2026-tfstate-bucket \
  --region eu-central-1
```

Deleting the objects permanently removes any Terraform state stored in the
bucket.

## Terraform modules

Terraform modules are located under [`modules/`](modules/). Initialize and run
Terraform from the directory of the module you want to use. Each module's
README contains its configuration and usage instructions.

### ECR repositories

[`modules/ecr/`](modules/ecr/) creates Amazon ECR repositories for EduWay
container images, including the backend, frontend, and database seeder
repositories.

See [`modules/ecr/README.md`](modules/ecr/README.md) for prerequisites,
configuration, provisioning, and instructions for pushing images.

### Network

[`modules/network/`](modules/network/) provisions a VPC, subnet, internet
gateway, route table, and configurable security group for EduWay.

See [`modules/network/README.md`](modules/network/README.md) for configuration
and usage instructions.

### EC2 key pair

[`modules/keypair/`](modules/keypair/) registers an existing public SSH key as an
Amazon EC2 key pair for EduWay.

See [`modules/keypair/README.md`](modules/keypair/README.md) for prerequisites,
configuration, provisioning, and destruction instructions.

### Elastic IP and DNS record

[`modules/eip/`](modules/eip/) allocates an Elastic IP and creates a configurable
A record in an existing public Route 53 hosted zone.

See [`modules/eip/README.md`](modules/eip/README.md) for configuration,
provisioning, DNS setup, and destruction instructions.

As additional modules are added under `modules/`, add a section here describing
each module and linking to its README.
