variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "server"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the monitoring services"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 30
}

variable "create_eip" {
  description = "Create and attach Elastic IP"
  type        = bool
  default     = false
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "Admin@123"
  sensitive   = true
}
