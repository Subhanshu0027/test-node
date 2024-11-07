# output.tf

# VPC ID Output
output "vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main_vpc.id
}

# Internet Gateway ID Output
output "internet_gateway_id" {
  description = "The ID of the main Internet Gateway."
  value       = aws_internet_gateway.main_igw.id
}

# Public Subnets Output
output "public_subnet_1_id" {
  description = "The ID of the first public subnet."
  value       = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  description = "The ID of the second public subnet."
  value       = aws_subnet.public_subnet_2.id
}

# Route Tables Output
output "public_route_table_1_id" {
  description = "The ID of the first public route table."
  value       = aws_route_table.public_route_table_1.id
}

output "public_route_table_2_id" {
  description = "The ID of the second public route table."
  value       = aws_route_table.public_route_table_2.id
}

# EC2 Instance Details
output "web_instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.web_instance.id
}

output "web_instance_public_ip" {
  description = "The public IP of the EC2 instance."
  value       = aws_instance.web_instance.public_ip
}

# Elastic IP Output
output "web_instance_eip" {
  description = "The Elastic IP associated with the web instance."
  value       = aws_eip.web_instance_eip.public_ip
}

# Security Group ID Output
output "instance_sg_id" {
  description = "The ID of the security group for the EC2 instance."
  value       = aws_security_group.instance_sg.id
}
