# EduWay AWS Elastic IP and DNS Record

This Terraform configuration allocates an Elastic IP in `eu-central-1` and
creates an A record pointing to it in an existing public Route 53 hosted zone.
It does not create the hosted zone. Create the Elastic IP and DNS record before
the EC2 instance that will use the address.

## Prerequisites

- Terraform installed
- AWS credentials configured for the account where the Elastic IP should be allocated
- An IAM identity with permission to manage Elastic IPs and Route 53 records, and
  access to the S3 Terraform state bucket
- An existing public Route 53 hosted zone for a domain you control
- The Terraform state bucket `eduway2026-tfstate-bucket` already created in
  `eu-central-1`

See [`../../README.md`](../../README.md) for AWS credentials and state bucket
setup instructions.

## Configure

From this directory, copy the example variables file:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Set `domain_name` to the existing hosted zone's domain name and `app_name` to the
hostname label for the A record. The module combines them to make
`<app_name>.<domain_name>`; for example, `app_name = "app"` and
`domain_name = "example.com"` create an A record for `app.example.com`. The
resulting name must belong to the selected hosted zone. `terraform.tfvars` is
local configuration and is excluded from version control.

## Initialize and review

Run Terraform from this directory:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review the plan to confirm the hosted zone, generated DNS name, and Elastic IP.

## Create the Elastic IP and DNS record

If the plan is correct, apply it:

```sh
terraform apply
```

Terraform outputs the Elastic IP allocation ID and public IP. The EC2 module
created later should associate the instance with this allocation ID. Create this
module's resources before creating that instance.

Terraform stores this module's state at
`modules/eip/terraform.tfstate` in the shared S3 state bucket.

## Destroy the Elastic IP and DNS record

Destroying this module removes the A record and releases the Elastic IP. If an
EC2 instance is using the address, destroy or update the EC2 module first so the
address is detached before releasing it. Confirm that no other service depends
on the DNS record or address before proceeding.

From this directory, inspect the destruction plan:

```sh
terraform plan -destroy
```

If the plan lists only the DNS record and Elastic IP you intend to remove,
destroy them:

```sh
terraform destroy
```

This removes the record and releases the address but leaves the shared S3 state
bucket and the module's state file in place. Do not delete the state bucket while
other Terraform modules still use it.
