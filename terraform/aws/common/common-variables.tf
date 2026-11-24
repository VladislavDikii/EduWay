variable "tags" {
  type        = any
  description = "Tags"
  default = {
    Project     = "EduWay2026"
    Purpose     = "ContainerRegistry"
    Environment = "Shared"
    ManagedBy   = "Terraform"
  }
}

variable "region" {
  type        = string
  description = "Default region"
  default     = "eu-central-1"
}