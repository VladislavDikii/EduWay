variable "domain_name" {
  type        = string
  description = "Name of the existing public Route 53 hosted zone"
  nullable    = false
}

variable "app_name" {
  type        = string
  description = "Combined with domain_name, creates fully qualified DNS name for the A record pointing to the Elastic IP"
  nullable    = false
}
