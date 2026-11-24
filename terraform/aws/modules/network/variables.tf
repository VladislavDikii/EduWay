variable "vpc_cidr_block" {
  type        = string
  description = "IPv4 CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet" {
  type = object({
    cidr = string
    name = string
    az   = string
  })
  description = "CIDR block, name, and availability zone for the public subnet"
  default = {
    cidr = "10.0.0.0/24"
    name = "eduway2026_subnet"
    az   = "eu-central-1a"
  }
}

variable "allow_all_traffic" {
  type        = bool
  description = "Whether to allow all outbound IPv4 traffic"
  default     = true
}

variable "allow_https" {
  type = object({
    enabled   = bool
    cidr_ipv4 = string
  })
  description = "Whether to allow HTTPS inbound and from which IPv4 CIDR"
  default = {
    enabled   = true
    cidr_ipv4 = "0.0.0.0/0"
  }
}

variable "allow_ssh" {
  type = object({
    enabled   = bool
    cidr_ipv4 = string
  })
  description = "Whether to allow SSH inbound and from which IPv4 CIDR"
  default = {
    enabled   = false
    cidr_ipv4 = "0.0.0.0/0"
  }
}

variable "allow_http" {
  type = object({
    enabled   = bool
    cidr_ipv4 = string
  })
  description = "Whether to allow HTTP inbound and from which IPv4 CIDR"
  default = {
    enabled   = false
    cidr_ipv4 = "0.0.0.0/0"
  }
}
