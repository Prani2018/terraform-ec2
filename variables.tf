# AWS Region
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# Project Name
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-ec2"
}

# Environment
variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VPC CIDR
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Public Subnet CIDR
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition = contains([
      "t3.micro", "t3.small", "t3.medium", "t3.large",
      "t2.micro", "t2.small", "t2.medium", "t2.large",
      "m5.large", "m5.xlarge", "m5.2xlarge"
    ], var.instance_type)
    error_message = "Instance type must be a valid EC2 instance type."
  }
}

# Volume Size
variable "volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 20
}

# Public Key for SSH access
variable "public_key" {
  description = "Public key for SSH access to EC2 instance"
  type        = string
  # You need to provide this value
}

# Private Key for provisioning (optional)
variable "private_key" {
  description = "Private key for SSH access (for provisioning)"
  type        = string
  default     = ""
  sensitive   = true
}

# Git Repository URL
variable "git_repo_url" {
  description = "URL of the Git repository to clone"
  type        = string
  default     = "https://github.com/Prani2018/terraformec2.git"
}

# Application Name
variable "app_name" {
  description = "simple-web-app"
  type        = string
  default     = "simple-web-app"
}

# Allowed SSH CIDR blocks
variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
