locals {
  eip_tags = merge(var.tags, {
    Purpose = "ElasticIP"
    Name    = "eduway2026_eip"
  })

  record_name = "${var.app_name}.${var.domain_name}"
}
