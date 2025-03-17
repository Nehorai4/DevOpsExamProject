terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Generate an SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/builder_key.pem"
  file_permission = "0600"
}

# Create an AWS key pair
resource "aws_key_pair" "builder_key" {
  key_name   = "builder-key-nehorai"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Create a security group
resource "aws_security_group" "builder_sg" {
  name        = "builder-sg-new"
  description = "Security group for builder EC2 instance"
  vpc_id      = "vpc-044604d0bfb707142"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get the default subnet from the specified VPC
data "aws_subnet" "default" {
  vpc_id            = "vpc-044604d0bfb707142"
  default_for_az    = true
  availability_zone = "us-east-1a"
}

# Create an EC2 instance
resource "aws_instance" "builder" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.builder_key.key_name
  vpc_security_group_ids = [aws_security_group.builder_sg.id]
  subnet_id     = data.aws_subnet.default.id

  tags = {
    Name = "builder"
  }
}

# Outputs
output "instance_public_ip" {
  value       = aws_instance.builder.public_ip
  description = "Public IP of the builder EC2 instance"
}

output "ssh_private_key_path" {
  value       = local_file.private_key.filename
  description = "Path to the generated private SSH key"
  sensitive   = true
}

output "ssh_key_name" {
  value       = aws_key_pair.builder_key.key_name
  description = "Name of the AWS SSH key pair"
}

output "security_group_id" {
  value       = aws_security_group.builder_sg.id
  description = "ID of the security group"
}