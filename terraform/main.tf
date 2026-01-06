terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "monitoring_sg" {
  name        = "${var.project_name}-monitoring-sg"
  description = "Security group for Grafana, Prometheus, and Node Exporter"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-monitoring-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# SSH Access Rule
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  description       = "SSH access"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.monitoring_sg.id
}

# Grafana Access Rule
resource "aws_security_group_rule" "grafana" {
  type              = "ingress"
  description       = "Grafana web interface"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.monitoring_sg.id
}

# Prometheus Access Rule
resource "aws_security_group_rule" "prometheus" {
  type              = "ingress"
  description       = "Prometheus web UI and API"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.monitoring_sg.id
}

# Node Exporter Access Rule
resource "aws_security_group_rule" "node_exporter" {
  type              = "ingress"
  description       = "Node Exporter metrics endpoint"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.monitoring_sg.id
}

# Outbound Traffic Rule
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monitoring_sg.id
}

# EC2 Instance
resource "aws_instance" "monitoring_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.monitoring_key.key_name
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  user_data = templatefile("${path.module}/user_data.sh", {
    grafana_admin_password = var.grafana_admin_password
  })

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-monitoring-server"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP (optional)
resource "aws_eip" "monitoring_eip" {
  count    = var.create_eip ? 1 : 0
  instance = aws_instance.monitoring_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-monitoring-eip"
  }
}
