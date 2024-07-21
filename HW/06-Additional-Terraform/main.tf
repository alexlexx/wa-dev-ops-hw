# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Locals
locals {
  name_prefix = "${var.project_name}-${var.environment_name}"
}

# VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name =local.name_prefix
  }
}

# Internet Gateway
resource "aws_internet_gateway" "example_gateway" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = local.name_prefix
  }
}

# Subnet
resource "aws_subnet" "example_subnet" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = local.name_prefix
  }
}

# Security Group
resource "aws_security_group" "example_security_group" {
  name   = "${local.name_prefix}_security_group"
  vpc_id = aws_vpc.example_vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.name_prefix
  }
}

# Route Table
resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_gateway.id
  }

  tags = {
    Name = local.name_prefix
  }
}

# Route table association
resource "aws_route_table_association" "example_rta" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

# AWS_AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.example_subnet.id
  security_groups = [aws_security_group.example_security_group.id]
  monitoring = var.monitoring

  metadata_options {
    http_endpoint = "enabled"
  }

  user_data = file("user_data/install_nginx.sh")

  root_block_device {
    volume_size = var.root_block_device_size
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.ebs_size
  }

  tags = {
    Name = local.name_prefix
    Owner = var.environment_owner
  }

  lifecycle {
    create_before_destroy = true

    postcondition {
      condition     = can(regex("^${local.name_prefix}$", self.tags["Name"]))
      error_message = "Instance name does not follow the naming convention with prefix '${local.name_prefix}'"
    }

    postcondition {
      condition     = var.monitoring == true
      error_message = "Monitoring must be enabled."
    }

    postcondition {
      condition     = self.tags["Owner"] != ""
      error_message = "Instance must have an 'Owner' tag."
    }
  }
}

check "nginx_success_check" {
  data "http" "nginx_check" {
    url = "http://${aws_instance.app_server.public_ip}"
  }

  assert {
    condition = data.http.nginx_check.status_code == 200
    error_message = "Nginx did not return HTTP 200"
  }
}
