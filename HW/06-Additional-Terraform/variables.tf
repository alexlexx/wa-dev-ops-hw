variable "project_name" {
  description = "Project name"
  type = string

  validation {
    condition = length(var.project_name) > 5
    error_message = "Project name must be longer than 5 characters"
  }
}

variable "environment_name" {
  description = "Environment name"
  type = string

  validation {
    condition = contains(["dev", "uat", "prod"], var.environment_name)
    error_message = "Environment name must be one of the next: dev, uat, prod"
  }
}

variable "instance_type" {
  description = "AWS instance type"
  type = string

  validation {
    condition = can(regex("^t[0-9]+\\.[a-z]+$", var.instance_type))
    error_message = "Instance type must be a valid t type"
  }
}

variable "monitoring" {
  description = "Monitoring"
  type = bool

  validation {
    condition = var.monitoring == true
    error_message = "Monitoring must be true"
  }
}

variable "root_block_device_size" {
  description = "Size of the root block device"
  type = number

  validation {
    condition = var.root_block_device_size >= 10 && var.root_block_device_size < 30
    error_message = "Root block device size must be between 10 and 30 GB"
  }
}

variable "ebs_size" {
  description = "Size of the EBS volume"
  type = number

  validation {
    condition = var.ebs_size >= 10 && var.ebs_size < 30
    error_message = "EBS size must be between 10 and 30 GB"
  }
}

variable "application_port" {
  description = "Application port"
  type = number

  validation {
    condition = var.application_port >= 1 && var.application_port <= 65535
    error_message = "Application port must be in the range 1-65535."
  }
}

variable "environment_owner" {
  description = "Environment owner email"
  type = string

  validation {
    condition = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.environment_owner))
    error_message = "Environment owner must be a valid email address"
  }
}

variable "ami_id" {
  description = "ID of the AMI"
  type = string

  validation {
    condition = can(regex("^ami-[a-z0-9]+$", var.ami_id))
    error_message = "AMI ID must be a valid AWS AMI ID."
  }
}

variable "aws_region" {
  description = "Default AWS region"
  type = string
  default = "eu-central-1"
}
