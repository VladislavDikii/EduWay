locals {
  keypair_tags = merge(var.tags, {
    Purpose = "KeyPair"
    Name    = "eduway2026_keypair"
  })

  ssh_public_key = base64decode(data.aws_secretsmanager_secret_version.ssh_public_key.secret_string)
}
