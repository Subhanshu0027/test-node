# AWS Provider Configuration
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "access_key" {
  description = "AWS access key for authentication"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS secret key for authentication"
  type        = string
  sensitive   = true
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

# Subnet CIDR Blocks
variable "subnet_1_cidr" {
  description = "CIDR block for the first subnet"
  type        = string
}

variable "subnet_2_cidr" {
  description = "CIDR block for the second subnet"
  type        = string
}

# EC2 Instance Configuration
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

# Key Pair and Security
variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "public_key" {
  description = "Public key for SSH access"
  type        = string
}

# GitHub Repository URL
variable "github_repo_url" {
  description = "GitHub repository URL to clone"
  type        = string
}
# Docker Image Name
variable "docker_image_name" {
  description = "The name of the Docker image"
  type        = string
}

# Docker Container Name
variable "docker_container_name" {
  description = "The name of the Docker container"
  type        = string
}

# Docker Port
variable "docker_port" {
  description = "The port to expose on the Docker container"
  type        = string
}
# Certbot Configuration
variable "cert_email" {
  description = "Email for Certbot registration"
  type        = string
}

variable "domain_name" {
  description = "The domain name for which to obtain an SSL certificate"
  type        = string
}
