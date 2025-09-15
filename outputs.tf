# VPC ID
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# Subnet ID
output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

# Security Group ID
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2_sg.id
}

# EC2 Instance ID
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

# Public IP Address
output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.main.public_ip
}

# Private IP Address
output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}

# Public DNS Name
output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.main.public_dns
}

# SSH Connection Command
output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.project_name}-key ec2-user@${aws_eip.main.public_ip}"
}

# Application URLs
output "application_urls" {
  description = "URLs to access the application"
  value = {
    http_url    = "http://${aws_eip.main.public_ip}"
    tomcat_url  = "http://${aws_eip.main.public_ip}:8080"
    app_url     = "http://${aws_eip.main.public_ip}:8080/${var.app_name}"
  }
}

# Key Pair Name
output "key_pair_name" {
  description = "Name of the AWS Key Pair"
  value       = aws_key_pair.main.key_name
}
