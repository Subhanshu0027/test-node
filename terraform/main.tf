terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.72.1"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.secret_key
  secret_key = var.access_key
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-igw"
  }
}

# Route Tables
resource "aws_route_table" "public_route_table_1" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name = "public-route-table-1"
  }
}

resource "aws_route_table" "public_route_table_2" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name = "public-route-table-2"
  }
}

# Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Associate Subnets with Route Tables
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table_1.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table_2.id
}

# Security Group
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main_vpc.id

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker Application Access (Port 3000)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg"
  }
}

# Create Elastic IP
resource "aws_eip" "web_instance_eip" {
  vpc = true

  tags = {
    Name = "web-instance-eip"
  }
}

# EC2 Instance (without attaching EIP yet)
resource "aws_instance" "web_instance" {
  ami                   = var.ami_id
  instance_type         = var.instance_type
  subnet_id             = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  key_name              = var.key_name

  # User data script to configure the instance
  user_data = <<-EOF
    #!/bin/bash
    # Update and install dependencies
    sudo apt-get update -y
    sudo apt-get install docker.io -y
    sudo apt-get install nginx -y

    # Start and enable Docker and Nginx
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot

    # Clone the GitHub repository
    git clone ${var.github_repo_url} /home/ubuntu/app

    # Change directory to the cloned repo
    cd /home/ubuntu/app

    # Build Docker image from Dockerfile
    sudo docker build -t ${var.docker_image_name} . 

    # Run Docker container from the built image with dynamic container name and port
    sudo docker run -d -p ${var.docker_port}:${var.docker_port} --name ${var.docker_container_name} ${var.docker_image_name}

    # Configure Nginx (this will use the Elastic IP)
    sudo rm -rf /etc/nginx/sites-available/default
    sudo rm -rf /etc/nginx/sites-enabled/default
    sudo sed -i 's/{instance_ip}/'${aws_eip.web_instance_eip.public_ip}'/g' /home/ubuntu/app/nginx_config.conf
    sudo mv /home/ubuntu/app/nginx_config.conf /etc/nginx/sites-available/nginx_config.conf
    sudo ln -s /etc/nginx/sites-available/nginx_config.conf /etc/nginx/sites-enabled/

    # Restart Nginx to apply the new configuration
    sudo certbot --nginx --non-interactive --agree-tos --email ${var.cert_email} -d ${var.domain_name}
    sudo systemctl restart nginx
  EOF

  tags = {
    Name = "web-instance"
  }

  # EC2 instance should only be created after the EIP is available
  depends_on = [aws_eip.web_instance_eip]
}

# Now associate the Elastic IP with the EC2 instance
resource "aws_eip_association" "eip_association" {
  instance_id   = aws_instance.web_instance.id
  allocation_id = aws_eip.web_instance_eip.id

  # This ensures the EIP is attached after the instance is created
  depends_on = [aws_instance.web_instance]
}
