data "aws_secretsmanager_secrets" "ssh_public_key" {
  region = var.region

  filter {
    name   = "tag-key"
    values = ["Name"]
  }

  filter {
    name   = "tag-value"
    values = ["eduway2026_ssh_public_key"]
  }
}

data "aws_secretsmanager_secret_version" "ssh_public_key" {
  secret_id = one(data.aws_secretsmanager_secrets.ssh_public_key.arns)
  region    = var.region
}
