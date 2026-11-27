locals {
  ec2_tags = merge(var.tags, {
    Purpose = "Compute"
    Name    = "eduway2026_ec2"
  })

  disk_tags = merge(var.tags, {
    Purpose = "Compute"
    Name    = "eduway2026_ec2_disk"
  })

  iam_role_tags = merge(var.tags, {
    Purpose = "ComputeAccess"
    Name    = "eduway2026_ec2_role"
  })
}
