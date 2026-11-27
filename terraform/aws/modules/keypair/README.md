# EduWay AWS EC2 Key Pair

This Terraform configuration registers the SSH public key stored in AWS
Secrets Manager as an Amazon EC2 key pair named `eduway2026_keypair` in
`eu-central-1`. It locates the secret by its unique `Name` tag value
`eduway2026_ssh_public_key`, reads its current version, and base64-decodes the
secret value. The private-key secret is not looked up or read by this module.

## Prerequisites

- Terraform installed
- AWS credentials configured for the account where the key pair should be created
- An IAM identity with permission to manage EC2 key pairs, list Secrets Manager
  secrets, retrieve the public-key secret version, and access the S3 Terraform
  state bucket
- The Secrets Manager module in [`../secrets/`](../secrets/) applied, with the
  public-key secret tagged `Name = "eduway2026_ssh_public_key"`
- The Terraform state bucket `eduway2026-tfstate-bucket` already created in
  `eu-central-1`

If the secret uses a customer-managed KMS key, the IAM identity also needs
`kms:Decrypt` permission for that key.

See [`../../README.md`](../../README.md) for AWS credentials and state bucket
setup instructions.

## Listing consistency

The secret lookup uses the Secrets Manager `ListSecrets` API through the
`aws_secretsmanager_secrets` data source. AWS documents that this API is
eventually consistent and might not reflect recent changes for up to five
minutes. After creating or retagging the secret, wait until it appears in the
lookup before applying this module. A missing match or multiple matches causes
Terraform to fail instead of selecting an arbitrary secret.

## Initialize and review

Run Terraform from this directory:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review the plan to confirm the key pair name and AWS account.

## Create the key pair

If the plan is correct, apply it:

```sh
terraform apply
```

Terraform stores this module's state at
`modules/keypair/terraform.tfstate` in the shared S3 state bucket. The retrieved
public key is recorded in this state; the private key is not fetched by this
module.

## Destroy the key pair

Destroying this module removes the key pair from AWS. It does not delete the
secret or terminate EC2 instances launched with this key pair. Removing the key
pair from AWS can prevent launching new instances with it.

Inspect the destruction plan first:

```sh
terraform plan -destroy
```

If the plan lists only the key pair you intend to remove, destroy it:

```sh
terraform destroy
```

This leaves the shared S3 state bucket and the module's state file in place.
Do not delete the state bucket while other Terraform modules still use it.
