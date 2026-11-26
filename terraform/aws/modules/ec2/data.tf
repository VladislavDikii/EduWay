data "aws_ami" "ubuntu" {
  most_recent = true
  region      = var.region
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_subnet" "main" {
  region = var.region

  filter {
    name   = "tag:Name"
    values = ["eduway2026_subnet"]
  }
}

data "aws_security_group" "main" {
  name   = "eduway2026_sg"
  region = var.region
}

data "aws_key_pair" "main" {
  key_name = "eduway2026_keypair"
  region   = var.region
}

data "aws_eip" "main" {
  region = var.region

  filter {
    name   = "tag:Name"
    values = ["eduway2026_eip"]
  }
}
