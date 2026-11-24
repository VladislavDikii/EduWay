resource "aws_security_group" "main" {
  name        = local.security_group_tags["Name"]
  description = "Configurable inbound access and all outbound traffic for EduWay"
  vpc_id      = aws_vpc.main.id
  region      = var.region

  tags = local.security_group_tags
}

resource "aws_vpc_security_group_egress_rule" "all_traffic" {
  count             = var.allow_all_traffic ? 1 : 0
  security_group_id = aws_security_group.main.id
  region            = var.region

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  count             = var.allow_https.enabled ? 1 : 0
  security_group_id = aws_security_group.main.id
  region            = var.region

  cidr_ipv4   = var.allow_https.cidr_ipv4
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count             = var.allow_ssh.enabled ? 1 : 0
  security_group_id = aws_security_group.main.id
  region            = var.region

  cidr_ipv4   = var.allow_ssh.cidr_ipv4
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  count             = var.allow_http.enabled ? 1 : 0
  security_group_id = aws_security_group.main.id
  region            = var.region

  cidr_ipv4   = var.allow_http.cidr_ipv4
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}
