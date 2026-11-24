locals {
  network_tags = merge(var.tags, {
    Purpose = "Network"
  })

  vpc_tags = merge(local.network_tags, {
    Name = "eduway2026_vpc"
  })

  subnet_tags = merge(local.network_tags, {
    Name = var.subnet.name
  })

  internet_gateway_tags = merge(local.network_tags, {
    Name = "eduway2026_igw"
  })

  route_table_tags = merge(local.network_tags, {
    Name = "eduway2026_rtable"
  })

  security_group_tags = merge(local.network_tags, {
    Name = "eduway2026_sg"
  })
}
