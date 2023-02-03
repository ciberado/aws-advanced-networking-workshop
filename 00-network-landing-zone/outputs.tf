output "att_subnets" {
  description = "Attachment subnets in ingress vpc"
  value       = aws_subnet.att_subnet[*]
}