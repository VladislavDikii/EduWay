# EduWay AWS Network

This Terraform configuration creates a VPC, one public subnet, an internet
gateway, a default route to the internet, and a security group. The defaults
use `eu-central-1`, allow HTTPS from IPv4 clients, disable inbound SSH and HTTP,
and allow all outbound IPv4 traffic.

## Prerequisites

- Terraform installed
- AWS credentials configured for the account where the network should be created
- An IAM identity with permission to manage VPC networking resources and access
  the S3 Terraform state bucket
- The Terraform state bucket `eduway2026-tfstate-bucket` already created in
  `eu-central-1`

See [`../../README.md`](../../README.md) for AWS credentials and state bucket
setup instructions.

## Configure

From this directory, copy the example variables file if you want to override the
defaults:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Set the CIDR ranges to match the clients that need access. SSH and HTTP remain
disabled unless their `enabled` values are changed to `true`. The default VPC
CIDR, subnet CIDR, subnet name, and availability zone can also be changed in
`terraform.tfvars`.

## Initialize and review

Run Terraform from this directory:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review the plan to confirm the VPC address space, subnet, route, and security
group rules before applying.

## Create the network

If the plan is correct, apply it:

```sh
terraform apply
```

Terraform stores this module's state at
`modules/network/terraform.tfstate` in the shared S3 state bucket.

## Destroy the network

Destroying this module removes the VPC, subnet, internet gateway, route table,
and security group it manages. Confirm that no running services or other
infrastructure depend on these resources before proceeding.

From this directory, inspect the destruction plan:

```sh
terraform plan -destroy
```

If the plan lists only resources you intend to remove, destroy them:

```sh
terraform destroy
```

This removes the network resources but leaves the shared S3 state bucket and
the module's state file in place. Do not delete the state bucket while other
Terraform modules still use it.

## Future automation

Infrastructure provisioning could eventually be automated with GitHub Actions
or a similar CI/CD system. A workflow could run Terraform formatting and
validation checks, create a plan for review, and apply approved network changes.

The workflow should use an appropriately scoped AWS identity. Where supported,
prefer short-lived credentials through GitHub Actions OIDC over long-lived AWS
access keys stored as repository secrets. Keep infrastructure changes
reviewable and require approval before applying production changes.
