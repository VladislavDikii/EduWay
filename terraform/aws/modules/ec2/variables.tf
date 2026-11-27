variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.small"
}

variable "ec2_disk_size" {
  type        = number
  description = "Encrypted EC2 root disk size in GiB"
  default     = 20
}
