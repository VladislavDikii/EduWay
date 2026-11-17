# Terraform - AWS Infrastructure

## Terraform state bucket

Before using the AWS CLI, export your AWS credentials and default region:

```sh
export AWS_ACCESS_KEY_ID="<your-access-key-id>"
export AWS_SECRET_ACCESS_KEY="<your-secret-access-key>"
export AWS_DEFAULT_REGION="eu-central-1"
```

Create the S3 bucket in `eu-central-1`:

```sh
aws s3api create-bucket \
  --bucket eduway2026-tfstate-bucket \
  --region eu-central-1 \
  --create-bucket-configuration LocationConstraint=eu-central-1 \
  --tagging 'TagSet=[{Key=Project,Value=EduWay2026},{Key=Purpose,Value=TerraformState},{Key=Environment,Value=Shared},{Key=ManagedBy,Value=Terraform}]'
```

Apply tags:
```sh
aws s3api put-bucket-tagging \
  --bucket eduway2026-tfstate-bucket \
  --region eu-central-1 \
  --tagging 'TagSet=[{Key=Project,Value=EduWay2026},{Key=Purpose,Value=TerraformState},{Key=Environment,Value=Shared},{Key=ManagedBy,Value=Terraform}]'
```

> **Warning:** Do not delete this bucket until the entire infrastructure has been destroyed. Terraform needs the state stored in the bucket to manage and destroy that infrastructure.

To delete the bucket after destroying the infrastructure, first remove its objects, then delete the bucket:

```sh
aws s3 rm s3://eduway2026-tfstate-bucket --recursive --region eu-central-1
aws s3api delete-bucket \
  --bucket eduway2026-tfstate-bucket \
  --region eu-central-1
```

Deleting the objects permanently removes any Terraform state stored in the bucket.