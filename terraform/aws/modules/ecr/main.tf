resource "aws_ecr_repository" "main" {
  count        = length(var.ecr_repositories)
  name         = local.ecr_repo_properties[count.index].name
  region       = var.region
  force_delete = true

  tags = local.ecr_repo_properties[count.index].tags
}