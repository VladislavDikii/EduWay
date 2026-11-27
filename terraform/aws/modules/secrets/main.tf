resource "aws_secretsmanager_secret" "ssh_private_key" {
  name                    = "eduway2026_ssh_private_key"
  description             = "EduWay SSH private key"
  region                  = var.region
  recovery_window_in_days = 0

  tags = local.private_key_secret_tags
}

resource "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id = aws_secretsmanager_secret.ssh_private_key.id
  region    = var.region

  secret_string = filebase64(var.ssh_private_key_file_path)
}

resource "aws_secretsmanager_secret" "ssh_public_key" {
  name                    = "eduway2026_ssh_public_key"
  description             = "EduWay SSH public key"
  region                  = var.region
  recovery_window_in_days = 0

  tags = local.public_key_secret_tags
}

resource "aws_secretsmanager_secret_version" "ssh_public_key" {
  secret_id = aws_secretsmanager_secret.ssh_public_key.id
  region    = var.region

  secret_string = filebase64(var.ssh_public_key_file_path)
}
