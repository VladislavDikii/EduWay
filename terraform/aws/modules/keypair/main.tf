resource "aws_key_pair" "main" {
  key_name   = local.keypair_tags["Name"]
  public_key = local.ssh_public_key
  region     = var.region

  tags = local.keypair_tags
}
