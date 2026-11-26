output "allocation_id" {
  description = "Allocation ID of the Elastic IP, for associating it with an EC2 instance"
  value       = aws_eip.main.id
}

output "public_ip" {
  description = "Public IPv4 address of the Elastic IP"
  value       = aws_eip.main.public_ip
}
