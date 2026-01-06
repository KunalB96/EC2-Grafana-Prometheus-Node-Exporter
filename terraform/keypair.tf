# Generate RSA private key
resource "tls_private_key" "monitoring_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair
resource "aws_key_pair" "monitoring_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.monitoring_key.public_key_openssh

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.monitoring_key.private_key_pem
  filename        = "${path.module}/key.pem"
  file_permission = "0400"
}
