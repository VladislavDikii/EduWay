resource "aws_secretsmanager_secret" "ssh_keypair" {
  name                    = "eduway2026_ssh_keypair"
  description             = "EduWay SSH key pair"
  region                  = var.region
  recovery_window_in_days = 0

  tags = local.secret_tags
}

resource "aws_secretsmanager_secret_version" "ssh_keypair" {
  secret_id = aws_secretsmanager_secret.ssh_keypair.id
  region    = var.region

  secret_string = jsonencode({
    private_key = filebase64(var.ssh_private_key_file_path)
    public_key  = filebase64(var.ssh_public_key_file_path)
  })
}
