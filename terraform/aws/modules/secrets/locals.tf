locals {
  private_key_secret_tags = merge(var.tags, {
    Name = "eduway2026_ssh_private_key"
  })

  public_key_secret_tags = merge(var.tags, {
    Name = "eduway2026_ssh_public_key"
  })
}
