# Terraform Configuration for Grafana, Prometheus, and Node Exporter

This Terraform configuration deploys an EC2 instance with Grafana, Prometheus, and Node Exporter pre-installed and configured.

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- An existing VPC and Subnet
- An EC2 Key Pair for SSH access

## Quick Start

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your values:**
   - Set your `key_name` (EC2 key pair)
   - Set your `vpc_id`
   - Set your `subnet_id`
   - Adjust other variables as needed

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the execution plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **Get the outputs:**
   ```bash
   terraform output
   ```

## What Gets Deployed

- **EC2 Instance**: t3.medium instance with Amazon Linux 2023
- **Security Group**: Allows inbound traffic on ports 22, 3000, 9090, 9100
- **Grafana**: v12.2.1 on port 3000
- **Prometheus**: v2.54.1 on port 9090
- **Node Exporter**: v1.10.2 on port 9100
- **Optional**: Elastic IP for static public IP address

## Accessing the Services

After deployment, Terraform will output the URLs:

- **Grafana**: `http://<PUBLIC_IP>:3000`
  - Username: `admin`
  - Password: (value from `grafana_admin_password` variable)

- **Prometheus**: `http://<PUBLIC_IP>:9090`

- **Node Exporter Metrics**: `http://<PUBLIC_IP>:9100/metrics`

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region to deploy | `us-east-1` |
| `project_name` | Project name for resource naming | `monitoring` |
| `instance_type` | EC2 instance type | `t3.medium` |
| `key_name` | EC2 Key Pair name | **Required** |
| `vpc_id` | VPC ID | **Required** |
| `subnet_id` | Subnet ID | **Required** |
| `allowed_cidr_blocks` | CIDR blocks for access | `["0.0.0.0/0"]` |
| `root_volume_size` | Root volume size in GB | `20` |
| `create_eip` | Create Elastic IP | `false` |
| `grafana_admin_password` | Grafana admin password | `Admin@123` |

## Security Considerations

1. **Restrict Access**: Change `allowed_cidr_blocks` to your specific IP range instead of `0.0.0.0/0`
2. **Change Default Password**: Update `grafana_admin_password` to a strong password
3. **Use HTTPS**: Consider setting up SSL/TLS certificates for production use
4. **Key Management**: Keep your EC2 key pair secure and never commit it to version control

## Monitoring Setup

The configuration automatically:
- Configures Prometheus to scrape metrics from Node Exporter
- Starts all services and enables them to run on boot
- Sets up proper user permissions and systemd services

## Connecting Grafana to Prometheus

1. Log in to Grafana
2. Go to Configuration → Data Sources
3. Click "Add data source"
4. Select "Prometheus"
5. Set URL to: `http://localhost:9090`
6. Click "Save & Test"

## Cleanup

To destroy all resources created by Terraform:

```bash
terraform destroy
```

## Troubleshooting

### Check service status via SSH:

```bash
ssh -i your-key.pem ec2-user@<PUBLIC_IP>
sudo systemctl status grafana-server
sudo systemctl status prometheus
sudo systemctl status node_exporter
```

### View logs:

```bash
sudo journalctl -u grafana-server -f
sudo journalctl -u prometheus -f
sudo journalctl -u node_exporter -f
```

## Cost Estimation

- t3.medium instance: ~$0.0416/hour (~$30/month)
- 20 GB EBS volume: ~$2/month
- Data transfer: varies based on usage

## License

This configuration is provided as-is for educational and deployment purposes.
