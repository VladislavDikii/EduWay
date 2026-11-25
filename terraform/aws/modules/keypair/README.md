# EduWay AWS EC2 Key Pair

This Terraform configuration registers an existing public SSH key as an Amazon
EC2 key pair named `eduway2026_keypair` in `eu-central-1`. It does not generate
or upload a private key; keep the matching private key secure and available to
the users or systems that need it.

## Prerequisites

- Terraform installed
- AWS credentials configured for the account where the key pair should be created
- An IAM identity with permission to manage EC2 key pairs and access the S3
  Terraform state bucket
- An existing public SSH key file
- The Terraform state bucket `eduway2026-tfstate-bucket` already created in
  `eu-central-1`

See [`../../README.md`](../../README.md) for AWS credentials and state bucket
setup instructions.

## Generate an SSH key pair

If you do not already have an SSH key pair, generate one:

```sh
ssh-keygen -b 2048 -t rsa -f eduway2026_id_rsa -N ""
```

This creates the private key `eduway2026_id_rsa` and public key
`eduway2026_id_rsa.pub`. Keep the private key secure and do not commit it to
version control. Set `public_key_path` in `terraform.tfvars` to
`eduway2026_id_rsa.pub`.

## Configure

From this directory, copy the example variables file:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Set `public_key_path` to the path of your public key file. The path is read by
Terraform on the machine where you run it. Do not point this variable at a
private key.

## Initialize and review

Run Terraform from this directory:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review the plan to confirm the key pair name and account before applying.

## Create the key pair

If the plan is correct, apply it:

```sh
terraform apply
```

Terraform stores this module's state at
`modules/keypair/terraform.tfstate` in the shared S3 state bucket.

## Destroy the key pair

Destroying this module removes the key pair from AWS. It does not delete the
local private key file or terminate EC2 instances that were launched with this
key pair. Removing the key pair from AWS can prevent launching new instances
with it, so confirm it is no longer needed before proceeding.

From this directory, inspect the destruction plan:

```sh
terraform plan -destroy
```

If the plan lists only the key pair you intend to remove, destroy it:

```sh
terraform destroy
```

This removes the AWS key pair but leaves the shared S3 state bucket and the
module's state file in place. Do not delete the state bucket while other
Terraform modules still use it.

## Future automation

Key pair provisioning should eventually be automated with GitHub Actions or a
similar CI/CD system. The workflow should generate the SSH key pair
automatically, register the public key with EC2, and store the private key
directly in AWS Secrets Manager. It should not print the private key, expose it
to workflow users, or place it in Terraform state, logs, or build artifacts.

The workflow should use an appropriately scoped AWS identity, with Secrets
Manager access limited to the services or operators that need the private key.
Where supported, prefer short-lived credentials through GitHub Actions OIDC over
long-lived AWS access keys stored as repository secrets. Keep provisioning
reviewable, protect key rotation and deletion, and require approval before
production changes.
