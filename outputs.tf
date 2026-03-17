output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for az in var.azs : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for az in var.azs : aws_subnet.private[az].id]
}

output "nat_gateway_ids" {
  description = "Map of NAT Gateway IDs by Availability Zone"
  value       = { for az, nat in aws_nat_gateway.main : az => nat.id }
}

output "public_subnet_cidr_blocks" {
  description = "List of public subnet CIDR blocks"
  value       = [for az in var.azs : aws_subnet.public[az].cidr_block]
}

output "private_subnet_cidr_blocks" {
  description = "List of private subnet CIDR blocks"
  value       = [for az in var.azs : aws_subnet.private[az].cidr_block]
}
