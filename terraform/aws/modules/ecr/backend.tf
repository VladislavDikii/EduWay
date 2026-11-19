terraform {
  backend "s3" {
    bucket = "eduway2026-tfstate-bucket"
    key    = "modules/ecr/terraform.tfstate"
    region = "eu-central-1"
  }
}