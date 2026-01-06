# Quick Reference Guide

A concise reference for common commands, queries, and configurations for Grafana, Prometheus, and Node Exporter.

---

## 🚀 Quick Start Commands

### Service Management
```bash
# Start all services
sudo systemctl start prometheus node_exporter grafana-server

# Stop all services
sudo systemctl stop prometheus node_exporter grafana-server

# Restart all services
sudo systemctl restart prometheus node_exporter grafana-server

# Enable auto-start on boot
sudo systemctl enable prometheus node_exporter grafana-server

# Check service status
sudo systemctl status prometheus
sudo systemctl status node_exporter  
sudo systemctl status grafana-server
```

### View Logs
```bash
# Real-time logs
sudo journalctl -u prometheus -f
sudo journalctl -u node_exporter -f
sudo journalctl -u grafana-server -f

# Last 50 lines
sudo journalctl -u prometheus -n 50
```

### Configuration Validation
```bash
# Check Prometheus config
promtool check config /etc/prometheus/prometheus.yml

# Check alert rules
promtool check rules /etc/prometheus/alert_rules.yml

# Test Prometheus query
curl 'http://localhost:9090/api/v1/query?query=up'
```

---

## 📊 Essential PromQL Queries

### System Metrics

```promql
# CPU usage percentage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage percentage
100 * (1 - ((node_memory_MemAvailable_bytes) / (node_memory_MemTotal_bytes)))

# Disk usage percentage
100 - ((node_filesystem_avail_bytes{mountpoint="/"} * 100) / node_filesystem_size_bytes{mountpoint="/"})

# System uptime in days
(node_time_seconds - node_boot_time_seconds) / 86400

# Load averages
node_load1
node_load5
node_load15

# Available memory in GB
node_memory_MemAvailable_bytes / 1024^3

# Total memory in GB
node_memory_MemTotal_bytes / 1024^3
```

### Network Metrics

```promql
# Network bytes received per second
rate(node_network_receive_bytes_total{device!="lo"}[5m])

# Network bytes transmitted per second
rate(node_network_transmit_bytes_total{device!="lo"}[5m])

# Network packets dropped
rate(node_network_receive_drop_total[5m])

# Network errors
rate(node_network_receive_errs_total[5m])
```

### Disk Metrics

```promql
# Disk read bytes per second
rate(node_disk_read_bytes_total[5m])

# Disk write bytes per second  
rate(node_disk_written_bytes_total[5m])

# Disk read operations per second
rate(node_disk_reads_completed_total[5m])

# Disk write operations per second
rate(node_disk_writes_completed_total[5m])

# Disk utilization percentage
rate(node_disk_io_time_seconds_total[5m]) * 100
```

### Advanced Queries

```promql
# Top 5 filesystems by usage
topk(5, 100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes))

# CPU usage per core
100 - (avg by (cpu) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Prediction: disk full in hours (linear prediction)
predict_linear(node_filesystem_avail_bytes{mountpoint="/"}[1h], 3600)

# Memory usage trend (increase per hour)
rate(node_memory_MemAvailable_bytes[1h]) * 3600
```

---

## 📁 Configuration Files

### Prometheus Configuration (`/etc/prometheus/prometheus.yml`)

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
        labels:
          env: 'production'
          datacenter: 'dc1'
          
  - job_name: 'node_exporter_staging'
    scrape_interval: 30s
    static_configs:
      - targets: ['staging-server:9100']
        labels:
          env: 'staging'
```

### Alert Rules (`/etc/prometheus/alert_rules.yml`)

```yaml
groups:
  - name: system_alerts
    interval: 30s
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} is down"
          description: "{{ $labels.instance }} has been down for more than 1 minute"

      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is {{ $value }}% for more than 5 minutes"

      - alert: HighMemoryUsage
        expr: 100 * (1 - ((node_memory_MemAvailable_bytes) / (node_memory_MemTotal_bytes))) > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is {{ $value }}%"

      - alert: DiskSpaceLow
        expr: 100 - ((node_filesystem_avail_bytes{mountpoint="/"} * 100) / node_filesystem_size_bytes{mountpoint="/"}) > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Disk usage is {{ $value }}%"

      - alert: HighLoadAverage
        expr: node_load5 > 2
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High load average on {{ $labels.instance }}"
          description: "Load average is {{ $value }}"
```

### Systemd Service Files

**Prometheus Service (`/etc/systemd/system/prometheus.service`)**
```ini
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --storage.tsdb.retention.time=30d \
  --storage.tsdb.retention.size=50GB \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.enable-admin-api

[Install]
WantedBy=multi-user.target
```

**Node Exporter Service (`/etc/systemd/system/node_exporter.service`)**
```ini
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
  --collector.systemd \
  --collector.processes

[Install]
WantedBy=multi-user.target
```

---

## 🔧 Grafana Configuration

### Data Source Configuration (Prometheus)
```json
{
  "name": "Prometheus",
  "type": "prometheus",
  "url": "http://localhost:9090",
  "access": "proxy",
  "isDefault": true
}
```

### Dashboard JSON Structure (Basic)
```json
{
  "dashboard": {
    "title": "Node Exporter Dashboard",
    "tags": ["prometheus", "node-exporter"],
    "timezone": "browser",
    "refresh": "30s",
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "panels": [
      {
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
          }
        ]
      }
    ]
  }
}
```

---

## 📈 Common Dashboard Panels

### Single Stat Panels
```json
{
  "title": "System Uptime",
  "type": "stat",
  "targets": [{
    "expr": "node_time_seconds - node_boot_time_seconds"
  }],
  "fieldConfig": {
    "defaults": {
      "unit": "dtdurations"
    }
  }
}
```

### Graph Panels
```json
{
  "title": "CPU Usage Over Time", 
  "type": "timeseries",
  "targets": [{
    "expr": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
    "legendFormat": "CPU Usage %"
  }],
  "fieldConfig": {
    "defaults": {
      "unit": "percent",
      "min": 0,
      "max": 100
    }
  }
}
```

### Gauge Panels
```json
{
  "title": "Memory Usage",
  "type": "gauge", 
  "targets": [{
    "expr": "100 * (1 - ((node_memory_MemAvailable_bytes) / (node_memory_MemTotal_bytes)))"
  }],
  "fieldConfig": {
    "defaults": {
      "unit": "percent",
      "thresholds": {
        "steps": [
          {"color": "green", "value": 0},
          {"color": "yellow", "value": 70},
          {"color": "red", "value": 90}
        ]
      }
    }
  }
}
```

---

## 🔍 Troubleshooting Commands

### Check Port Usage
```bash
# Check if ports are in use
sudo netstat -tlnp | grep :9090  # Prometheus
sudo netstat -tlnp | grep :9100  # Node Exporter  
sudo netstat -tlnp | grep :3000  # Grafana

# Alternative using ss
ss -tlnp | grep :9090
```

### Check Connectivity
```bash
# Test local connections
curl -I http://localhost:9090
curl -I http://localhost:9100/metrics
curl -I http://localhost:3000

# Test from remote
curl -I http://<server-ip>:9090
```

### File Permissions Check
```bash
# Check ownership
ls -la /etc/prometheus/
ls -la /var/lib/prometheus/
ls -la /usr/local/bin/prometheus

# Fix permissions if needed
sudo chown -R prometheus:prometheus /etc/prometheus/
sudo chown -R prometheus:prometheus /var/lib/prometheus/
```

### Process Information
```bash
# Check running processes
ps aux | grep prometheus
ps aux | grep node_exporter
ps aux | grep grafana

# Check resource usage
top -p $(pgrep prometheus)
```

---

## 🌐 API Endpoints

### Prometheus API
```bash
# Query current values
curl 'http://localhost:9090/api/v1/query?query=up'

# Query range
curl 'http://localhost:9090/api/v1/query_range?query=up&start=2023-01-01T00:00:00Z&end=2023-01-01T01:00:00Z&step=15s'

# Get targets
curl 'http://localhost:9090/api/v1/targets'

# Get configuration
curl 'http://localhost:9090/api/v1/status/config'

# Get runtime info
curl 'http://localhost:9090/api/v1/status/runtimeinfo'
```

### Grafana API
```bash
# Get all dashboards (requires API key)
curl -H "Authorization: Bearer <api-key>" http://localhost:3000/api/search

# Export dashboard
curl -H "Authorization: Bearer <api-key>" \
  http://localhost:3000/api/dashboards/uid/<dashboard-uid>

# Create dashboard
curl -X POST -H "Authorization: Bearer <api-key>" \
  -H "Content-Type: application/json" \
  -d @dashboard.json \
  http://localhost:3000/api/dashboards/db
```

---

## 📦 Installation Commands

### CentOS/RHEL/Amazon Linux
```bash
# Update system
sudo yum update -y
sudo yum install wget tar -y

# Download and install (replace with latest versions)
wget https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
sudo yum install -y https://dl.grafana.com/grafana-enterprise/release/12.2.1/grafana-enterprise_12.2.1_18655849634_linux_amd64.rpm
```

### Ubuntu/Debian
```bash
# Update system
sudo apt update
sudo apt install wget curl -y

# Download binaries (same URLs as above)
# Install Grafana
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana
```

---

## 🔐 Security Commands

### Firewall Configuration
```bash
# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=9090/tcp  
sudo firewall-cmd --permanent --add-port=9100/tcp
sudo firewall-cmd --reload

# Ubuntu
sudo ufw allow 3000/tcp
sudo ufw allow 9090/tcp
sudo ufw allow 9100/tcp
```

### User Management
```bash
# Create service users
sudo useradd --no-create-home --shell /bin/false prometheus
sudo useradd --no-create-home --shell /bin/false node_exporter

# Change Grafana admin password
sudo grafana-cli admin reset-admin-password <new-password>
```

---

## 📊 Useful Metrics to Monitor

### Golden Signals
- **Latency**: Response time of requests
- **Traffic**: Rate of requests  
- **Errors**: Rate of failed requests
- **Saturation**: Resource utilization

### System Health
- CPU usage, load average
- Memory usage, swap usage
- Disk usage, I/O rates
- Network traffic, error rates
- Process counts, file descriptors

### Application Metrics
- Request rate, response time
- Error rates by type
- Database connection pools
- Queue depths, message rates

---

## 🚨 Alert Thresholds (Recommendations)

| Metric | Warning | Critical |
|--------|---------|----------|
| CPU Usage | > 80% | > 95% |
| Memory Usage | > 80% | > 95% |
| Disk Usage | > 80% | > 90% |
| Load Average | > CPU cores | > 2x CPU cores |
| Disk I/O Wait | > 20% | > 40% |
| Network Errors | > 1% | > 5% |

---

This reference guide should help you quickly find the commands, queries, and configurations you need for day-to-day monitoring operations! 🚀