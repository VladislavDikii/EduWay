# EduWay AWS EC2 Instance

This Terraform configuration creates one EC2 instance using the latest matching
Ubuntu 24.04 AMI, an encrypted root disk, the EduWay subnet, security group, and
key pair, and associates the Elastic IP managed by the EIP module. It also
creates a custom EC2-trusted IAM role for future use. The role has no policies,
instance profile, or attachment to the EC2 instance yet. This module does not
configure user data or install application software.

## Prerequisites

- Terraform installed
- AWS credentials configured for the account where the instance should be created
- An IAM identity with permission to manage EC2 instances, EIP associations, IAM
  roles, and access the S3 Terraform state bucket
- The Terraform state bucket `eduway2026-tfstate-bucket` already created in
  `eu-central-1`

See [`../../README.md`](../../README.md) for AWS credentials and state bucket
setup instructions.

The network, keypair, and EIP modules must already have been applied. The EIP
module also requires the existing public Route 53 hosted zone used for its A
record.

## Provisioning order

The `network`, `keypair`, and `eip` modules do not depend on one another, so they can
be applied in any order or at the same time. The EC2 module depends on resources
from all three and should be applied only after they are ready:

1. Apply `network`, `keypair`, and `eip` in any order or simultaneously.
2. Apply `ec2` to create the instance and associate the EIP.

The EC2 module looks up the subnet and security group created by `network`, the
key pair created by `keypair`, and the EIP created by `eip` using their EduWay
names and tags.

## Configure

From this directory, copy the example variables file if you want to override the
defaults:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Set `ec2_instance_type` and `ec2_disk_size` as needed. The root disk is encrypted.
`terraform.tfvars` is local configuration and is excluded from version control.

## Initialize and review

Run Terraform from this directory:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review the plan to confirm the AMI, instance type, network resources, key pair,
Elastic IP association, disk size, and IAM role.

## Create the instance

If the plan is correct, apply it:

```sh
terraform apply
```

Terraform stores this module's state at
`modules/ec2/terraform.tfstate` in the shared S3 state bucket.

## Destroy the instance

Destroying this module terminates the EC2 instance, removes its EIP association,
and deletes the custom IAM role. The Elastic IP itself remains allocated, and
the EIP module's DNS record remains in place. Confirm that the instance and role
are no longer needed before proceeding.

From this directory, inspect the destruction plan:

```sh
terraform plan -destroy
```

If the plan lists only the instance, EIP association, and IAM role you intend to
remove, destroy them:

```sh
terraform destroy
```

This leaves the shared S3 state bucket and the module's state file in place. Do
not delete the state bucket while other Terraform modules still use it.
