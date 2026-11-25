locals {
  keypair_tags = merge(var.tags, {
    Purpose = "KeyPair"
    Name    = "eduway2026_keypair"
  })
}
