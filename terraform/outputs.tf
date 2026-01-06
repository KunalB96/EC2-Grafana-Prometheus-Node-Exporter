output "key_pair_name" {
  description = "Name of the EC2 key pair"
  value       = aws_key_pair.monitoring_key.key_name
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.monitoring_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = var.create_eip ? aws_eip.monitoring_eip[0].public_ip : aws_instance.monitoring_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.monitoring_server.private_ip
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://${var.create_eip ? aws_eip.monitoring_eip[0].public_ip : aws_instance.monitoring_server.public_ip}:3000"
}

output "prometheus_url" {
  description = "Prometheus UI URL"
  value       = "http://${var.create_eip ? aws_eip.monitoring_eip[0].public_ip : aws_instance.monitoring_server.public_ip}:9090"
}

output "node_exporter_url" {
  description = "Node Exporter metrics URL"
  value       = "http://${var.create_eip ? aws_eip.monitoring_eip[0].public_ip : aws_instance.monitoring_server.public_ip}:9100/metrics"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.monitoring_sg.id
}

output "security_group_rules" {
  description = "Security group rules summary"
  value = {
    ssh           = "Port 22 - SSH Access"
    grafana       = "Port 3000 - Grafana Web Interface"
    prometheus    = "Port 9090 - Prometheus UI & API"
    node_exporter = "Port 9100 - Node Exporter Metrics"
  }
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${var.create_eip ? aws_eip.monitoring_eip[0].public_ip : aws_instance.monitoring_server.public_ip}"
}
