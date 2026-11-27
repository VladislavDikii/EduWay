locals {
  secret_tags = merge(var.tags, {
    Name = "eduway2026_ssh_keypair"
  })
}
