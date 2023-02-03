output "attachment_subnets" {
  description = "Attachment subnets in ingress vpc"
  value       = aws_subnet.attachment_subnet[*].id
}

output "nwf_subnets" {
  description = "Attachment subnets in ingress vpc"
  value       = aws_subnet.nfw_subnet[*].id
}

