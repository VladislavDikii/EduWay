# EduWay AWS SSH Key Secrets

This Terraform configuration creates separate AWS Secrets Manager secrets for
an existing SSH private and public key. The secret names and unique `Name` tag
values are `eduway2026_ssh_private_key` and `eduway2026_ssh_public_key`. Each
secret version contains the base64-encoded contents of its corresponding key
file. Base64 encoding is not encryption.

Both secrets receive the EduWay project tags. This module uses local Terraform
state and has no remote backend configuration.

## Prerequisites

- Terraform installed
- AWS credentials configured for the account where the secret should be created
- An IAM identity with permission to create, update, describe, and delete
  Secrets Manager secrets and versions
- An existing SSH key pair whose files are available on the machine running
  Terraform

## Generate an SSH key pair

If needed, generate a key pair from this directory:

```sh
ssh-keygen -t rsa -b 2048 -f eduway2026_id_rsa -N ""
```

This creates `eduway2026_id_rsa` and `eduway2026_id_rsa.pub`. Do not commit
either key file.

## Configure

Copy the example variables file:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Set `ssh_private_key_file_path` and `ssh_public_key_file_path` to the key files.
Paths are read by Terraform on the machine running it. Relative paths are
resolved from the module directory when commands are run there.

## Initialize and review

Run Terraform from this directory:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review the plan before applying.

## Create or update the secret

Apply the reviewed configuration:

```sh
terraform apply
```

Terraform stores local state in `terraform.tfstate` in this directory. That
state contains the private key value in base64-encoded form, which is easily
reversible and does not protect the key. Protect the state and any saved plan
files. The repository `.gitignore` excludes Terraform state and local
`terraform.tfvars` files.

## Delete the secret

This module sets `recovery_window_in_days = 0`, so deleting the secret removes
it immediately without a recovery window. This is intended for the EduWay
sandbox's repeated create/destroy workflow.

Inspect the destruction plan first:

```sh
terraform plan -destroy
```

If it lists only the secret and secret version you intend to remove, destroy
them:

```sh
terraform destroy
```

## Read a key from another Terraform configuration

An IAM identity that can read the public-key secret can retrieve only that
secret's current version with the `aws_secretsmanager_secret_version` data
source. Decode the value with `base64decode()`:

```hcl
data "aws_secretsmanager_secret_version" "ssh_public_key" {
  secret_id = "eduway2026_ssh_public_key"
}

locals {
  public_key = base64decode(data.aws_secretsmanager_secret_version.ssh_public_key.secret_string)
}
```

Reading a secret through this data source puts its value in the consumer
configuration's Terraform state. A configuration that needs the private key
must explicitly read `eduway2026_ssh_private_key`; the keypair module reads only
the public-key secret.
