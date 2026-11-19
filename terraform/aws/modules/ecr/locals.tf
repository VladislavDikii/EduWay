locals {
  ecr_repo_properties = flatten([
    for repo_name in var.ecr_repositories : {
      "name" = repo_name
      "tags" = merge(var.tags, {
        "Name" = repo_name
      })
    }
  ])
}