# Complete Tutorial: Grafana + Prometheus + Node Exporter

A comprehensive guide to setting up a complete monitoring stack with Grafana, Prometheus, and Node Exporter.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Architecture Overview](#architecture-overview)
3. [Prerequisites](#prerequisites)
4. [Part 1: Installing Prometheus](#part-1-installing-prometheus)
5. [Part 2: Installing Node Exporter](#part-2-installing-node-exporter)
6. [Part 3: Configuring Prometheus to Scrape Node Exporter](#part-3-configuring-prometheus-to-scrape-node-exporter)
7. [Part 4: Installing Grafana](#part-4-installing-grafana)
8. [Part 5: Connecting Grafana to Prometheus](#part-5-connecting-grafana-to-prometheus)
9. [Part 6: Creating Dashboards](#part-6-creating-dashboards)
10. [Part 7: Setting Up Alerts](#part-7-setting-up-alerts)
11. [Troubleshooting](#troubleshooting)
12. [Best Practices](#best-practices)

---

## Introduction

### What is this Stack?

This monitoring stack consists of three main components:

- **Prometheus**: A time-series database that collects and stores metrics
- **Node Exporter**: An agent that exports system metrics (CPU, memory, disk, network)
- **Grafana**: A visualization and dashboard platform

### Why Use This Stack?

- **Open Source**: All components are free and open source
- **Scalable**: Can monitor from single servers to large distributed systems
- **Flexible**: Supports custom metrics and integrations
- **Industry Standard**: Used by thousands of organizations worldwide

---

## Architecture Overview

```
┌─────────────┐
│   Grafana   │ ← User accesses dashboards
│  (Port 3000)│
└──────┬──────┘
       │ Queries metrics
       ↓
┌─────────────┐
│ Prometheus  │ ← Stores time-series data
│ (Port 9090) │
└──────┬──────┘
       │ Scrapes metrics every 15s
       ↓
┌─────────────┐
│Node Exporter│ ← Exposes system metrics
│ (Port 9100) │
└─────────────┘
```

**Data Flow:**
1. Node Exporter exposes system metrics on `/metrics` endpoint
2. Prometheus scrapes these metrics at regular intervals
3. Prometheus stores the metrics in its time-series database
4. Grafana queries Prometheus to visualize the data
5. Users view the visualizations on Grafana dashboards

---

## Prerequisites

### System Requirements

- **Operating System**: Amazon Linux 2023, CentOS, Ubuntu, or RHEL
- **RAM**: Minimum 2 GB (4 GB recommended)
- **CPU**: 2 cores recommended
- **Disk Space**: 20 GB minimum
- **Ports**: 3000 (Grafana), 9090 (Prometheus), 9100 (Node Exporter)

### Required Packages

```bash
sudo yum update -y
sudo yum install wget tar make -y
```

---

## Part 1: Installing Prometheus

### Step 1.1: Download Prometheus

```bash
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz
```

### Step 1.2: Extract the Archive

```bash
tar -xvf prometheus-2.54.1.linux-amd64.tar.gz
sudo mv prometheus-2.54.1.linux-amd64 /opt/prometheus
```

### Step 1.3: Create Prometheus User

```bash
sudo useradd --no-create-home --shell /bin/false prometheus
```

**Why create a dedicated user?**
- Security: Runs with minimal privileges
- Isolation: Separates Prometheus from other services
- Best practice for production environments

### Step 1.4: Copy Binaries

```bash
sudo cp /opt/prometheus/prometheus /usr/local/bin/
sudo cp /opt/prometheus/promtool /usr/local/bin/
```

### Step 1.5: Create Configuration Directories

```bash
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus
```

### Step 1.6: Copy Configuration File

```bash
sudo cp /opt/prometheus/prometheus.yml /etc/prometheus/
```

### Step 1.7: Set Ownership

```bash
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
```

### Step 1.8: Create Systemd Service

```bash
sudo nano /etc/systemd/system/prometheus.service
```

**Add the following content:**

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
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

**Understanding the Service File:**
- `User=prometheus`: Runs as the prometheus user
- `--config.file`: Path to configuration file
- `--storage.tsdb.path`: Where to store time-series data
- `WantedBy=multi-user.target`: Starts on boot

### Step 1.9: Start Prometheus

```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus
```

### Step 1.10: Verify Installation

```bash
# Check if Prometheus is running
curl http://localhost:9090

# Access Prometheus UI
# Open browser: http://<your-server-ip>:9090
```

---

## Part 2: Installing Node Exporter

### Step 2.1: Download Node Exporter

```bash
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
```

### Step 2.2: Extract and Install

```bash
tar xvf node_exporter-1.10.2.linux-amd64.tar.gz
sudo cp node_exporter-1.10.2.linux-amd64/node_exporter /usr/local/bin/
```

### Step 2.3: Create Node Exporter User

```bash
sudo useradd node_exporter --no-create-home --shell /bin/false
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

### Step 2.4: Create Systemd Service

```bash
sudo nano /etc/systemd/system/node_exporter.service
```

**Add the following content:**

```ini
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

### Step 2.5: Start Node Exporter

```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

### Step 2.6: Verify Node Exporter

```bash
# Check metrics endpoint
curl http://localhost:9100/metrics

# You should see metrics like:
# node_cpu_seconds_total
# node_memory_MemAvailable_bytes
# node_filesystem_avail_bytes
```

**What Metrics Does Node Exporter Provide?**
- **CPU**: Usage, load averages
- **Memory**: Total, available, cached
- **Disk**: Usage, I/O statistics
- **Network**: Bytes sent/received, errors
- **System**: Uptime, processes, file descriptors

---

## Part 3: Configuring Prometheus to Scrape Node Exporter

### Step 3.1: Edit Prometheus Configuration

```bash
sudo nano /etc/prometheus/prometheus.yml
```

### Step 3.2: Add Node Exporter as a Target

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
```

**Configuration Explained:**
- `scrape_interval: 15s`: Collect metrics every 15 seconds
- `job_name`: Label to identify the metrics source
- `targets`: List of endpoints to scrape

### Step 3.3: Restart Prometheus

```bash
sudo systemctl restart prometheus
```

### Step 3.4: Verify Target is Up

1. Open Prometheus UI: `http://<your-server-ip>:9090`
2. Go to **Status** → **Targets**
3. You should see both `prometheus` and `node_exporter` with status **UP**

### Step 3.5: Query Node Exporter Metrics

In Prometheus UI, try these queries:

```promql
# CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage percentage
100 * (1 - ((node_memory_MemAvailable_bytes) / (node_memory_MemTotal_bytes)))

# Disk usage percentage
100 - ((node_filesystem_avail_bytes{mountpoint="/"} * 100) / node_filesystem_size_bytes{mountpoint="/"})

# Network traffic
rate(node_network_receive_bytes_total[5m])
```

---

## Part 4: Installing Grafana

### Step 4.1: Install Grafana

```bash
sudo yum install -y https://dl.grafana.com/grafana-enterprise/release/12.2.1/grafana-enterprise_12.2.1_18655849634_linux_amd64.rpm
```

### Step 4.2: Start Grafana

```bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server
```

### Step 4.3: Access Grafana

1. Open browser: `http://<your-server-ip>:3000`
2. Default credentials:
   - **Username**: `admin`
   - **Password**: `admin`
3. You'll be prompted to change the password

### Step 4.4: Change Admin Password (Optional via CLI)

```bash
# Using API
curl -X PUT -H "Content-Type: application/json" \
  -d '{"oldPassword":"admin","newPassword":"Admin@123","confirmNew":"Admin@123"}' \
  http://admin:admin@localhost:3000/api/user/password
```

---

## Part 5: Connecting Grafana to Prometheus

### Step 5.1: Add Prometheus Data Source

1. Log in to Grafana
2. Click on **☰** (hamburger menu) → **Connections** → **Data sources**
3. Click **Add data source**
4. Select **Prometheus**

### Step 5.2: Configure Data Source

Fill in the following:

- **Name**: `Prometheus`
- **URL**: `http://localhost:9090`
- **Access**: `Server (default)`

### Step 5.3: Test and Save

1. Scroll down and click **Save & Test**
2. You should see: "Successfully queried the Prometheus API"

**Troubleshooting Connection Issues:**
- Ensure Prometheus is running: `systemctl status prometheus`
- Check Prometheus is accessible: `curl http://localhost:9090`
- Verify firewall rules if using remote Prometheus

---

## Part 6: Creating Dashboards

### Option 1: Import Pre-built Dashboard

#### Step 6.1: Import Node Exporter Dashboard

1. In Grafana, click **☰** → **Dashboards**
2. Click **New** → **Import**
3. Enter dashboard ID: **1860** (Node Exporter Full)
4. Click **Load**
5. Select Prometheus data source
6. Click **Import**

**Popular Dashboard IDs:**
- **1860**: Node Exporter Full
- **11074**: Node Exporter for Prometheus Dashboard
- **405**: Node Exporter Server Metrics

### Option 2: Create Custom Dashboard

#### Step 6.2: Create New Dashboard

1. Click **☰** → **Dashboards** → **New** → **New Dashboard**
2. Click **Add visualization**
3. Select **Prometheus** data source

#### Step 6.3: Add CPU Usage Panel

**Panel Configuration:**
- **Title**: CPU Usage
- **Query**: 
  ```promql
  100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
  ```
- **Legend**: `{{instance}} CPU Usage`
- **Unit**: Percent (0-100)
- **Visualization**: Time series

#### Step 6.4: Add Memory Usage Panel

Click **Add panel**

**Panel Configuration:**
- **Title**: Memory Usage
- **Query**: 
  ```promql
  100 * (1 - ((node_memory_MemAvailable_bytes) / (node_memory_MemTotal_bytes)))
  ```
- **Legend**: `Memory Usage %`
- **Unit**: Percent (0-100)
- **Visualization**: Time series

#### Step 6.5: Add Disk Usage Panel

Click **Add panel**

**Panel Configuration:**
- **Title**: Disk Usage
- **Query**: 
  ```promql
  100 - ((node_filesystem_avail_bytes{mountpoint="/"} * 100) / node_filesystem_size_bytes{mountpoint="/"})
  ```
- **Legend**: `Disk Usage %`
- **Unit**: Percent (0-100)
- **Visualization**: Gauge

#### Step 6.6: Add Network Traffic Panel

Click **Add panel**

**Panel Configuration:**
- **Title**: Network Traffic
- **Queries**: 
  ```promql
  # Receive
  rate(node_network_receive_bytes_total{device!="lo"}[5m])
  
  # Transmit
  rate(node_network_transmit_bytes_total{device!="lo"}[5m])
  ```
- **Legend**: `{{device}} - {{__name__}}`
- **Unit**: bytes/sec
- **Visualization**: Time series

#### Step 6.7: Save Dashboard

1. Click **Save** (disk icon)
2. Enter dashboard name: "Node Exporter Metrics"
3. Click **Save**

---

## Part 7: Setting Up Alerts

### Step 7.1: Configure Alert Rules in Prometheus

```bash
sudo nano /etc/prometheus/alert_rules.yml
```

**Add the following rules:**

```yaml
groups:
  - name: node_alerts
    interval: 30s
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 30
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 30% (current value: {{ $value }}%)"

      - alert: HighMemoryUsage
        expr: 100 * (1 - ((node_memory_MemAvailable_bytes) / (node_memory_MemTotal_bytes))) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 80% (current value: {{ $value }}%)"

      - alert: DiskSpaceLow
        expr: 100 - ((node_filesystem_avail_bytes{mountpoint="/"} * 100) / node_filesystem_size_bytes{mountpoint="/"}) > 80
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space is low"
          description: "Disk usage is above 80% (current value: {{ $value }}%)"

      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Instance is down"
          description: "{{ $labels.instance }} is down"
```

### Step 7.2: Update Prometheus Configuration

```bash
sudo nano /etc/prometheus/prometheus.yml
```

**Add rule files section:**

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
```

### Step 7.3: Restart Prometheus

```bash
sudo systemctl restart prometheus
```

### Step 7.4: Verify Alerts

1. Open Prometheus UI: `http://<your-server-ip>:9090`
2. Go to **Alerts**
3. You should see all configured alerts

### Step 7.5: Configure Grafana Alerts

1. In Grafana, go to **Alerting** → **Alert rules**
2. Click **Create alert rule**
3. Configure based on your needs
4. Set up notification channels (Email, Slack, PagerDuty, etc.)

---

## Troubleshooting

### Prometheus Not Starting

**Check logs:**
```bash
sudo journalctl -u prometheus -f
```

**Common issues:**
- Configuration syntax error: `promtool check config /etc/prometheus/prometheus.yml`
- Permissions: Check ownership of files
- Port already in use: `sudo lsof -i :9090`

### Node Exporter Not Showing Metrics

**Verify Node Exporter is running:**
```bash
sudo systemctl status node_exporter
curl http://localhost:9100/metrics
```

**Check Prometheus targets:**
- Go to Prometheus UI → Status → Targets
- Ensure node_exporter shows as UP

### Grafana Can't Connect to Prometheus

**Test connection:**
```bash
curl http://localhost:9090/api/v1/query?query=up
```

**Check Grafana logs:**
```bash
sudo journalctl -u grafana-server -f
```

### No Data in Dashboards

**Verify data is being scraped:**
1. Go to Prometheus UI
2. Run query: `up{job="node_exporter"}`
3. Should return value of 1

**Check time range:**
- Ensure dashboard time range includes recent data
- Prometheus only stores data from when it started scraping

---

## Best Practices

### 1. Security

**Change default passwords:**
```bash
# Grafana
sudo grafana-cli admin reset-admin-password <new-password>
```

**Use firewall rules:**
```bash
# Only allow access from specific IPs
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="YOUR_IP" port port="3000" protocol="tcp" accept'
sudo firewall-cmd --reload
```

**Enable HTTPS:**
- Use reverse proxy (Nginx, Apache)
- Configure SSL certificates (Let's Encrypt)

### 2. Performance

**Adjust retention:**
```bash
# Edit Prometheus service file
sudo nano /etc/systemd/system/prometheus.service

# Add retention flags:
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --storage.tsdb.retention.time=30d \
  --storage.tsdb.retention.size=50GB
```

**Optimize scrape intervals:**
- Use longer intervals for less critical metrics
- Use shorter intervals for critical metrics

### 3. Monitoring

**Monitor the monitors:**
- Create alerts for Prometheus and Grafana health
- Monitor disk space for Prometheus data directory
- Set up backup for Grafana dashboards

### 4. Organization

**Label your metrics:**
```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
        labels:
          environment: 'production'
          datacenter: 'us-east-1'
```

**Use folders for dashboards:**
- Create folders by environment (prod, staging, dev)
- Create folders by team or service

### 5. Backup

**Backup Grafana:**
```bash
# Backup Grafana database
sudo cp /var/lib/grafana/grafana.db /backup/grafana.db.$(date +%Y%m%d)

# Export dashboards via API
curl -H "Authorization: Bearer <API_KEY>" \
  http://localhost:3000/api/search?type=dash-db | \
  jq -r '.[].uid' | \
  xargs -I {} curl -H "Authorization: Bearer <API_KEY>" \
  http://localhost:3000/api/dashboards/uid/{} > dashboard_{}.json
```

**Backup Prometheus:**
```bash
# Take snapshot (requires --web.enable-admin-api flag)
curl -XPOST http://localhost:9090/api/v1/admin/tsdb/snapshot

# Copy data directory
sudo rsync -av /var/lib/prometheus/ /backup/prometheus/
```

---

## Useful Commands

### Service Management

```bash
# Restart all services
sudo systemctl restart prometheus node_exporter grafana-server

# Check status
sudo systemctl status prometheus
sudo systemctl status node_exporter
sudo systemctl status grafana-server

# View logs
sudo journalctl -u prometheus -f
sudo journalctl -u node_exporter -f
sudo journalctl -u grafana-server -f
```

### Prometheus Queries

```promql
# System uptime
node_time_seconds - node_boot_time_seconds

# Load average
node_load1
node_load5
node_load15

# Number of CPU cores
count(node_cpu_seconds_total{mode="idle"}) by (instance)

# Total memory
node_memory_MemTotal_bytes

# Available memory
node_memory_MemAvailable_bytes

# Disk read bytes
rate(node_disk_read_bytes_total[5m])

# Disk write bytes
rate(node_disk_written_bytes_total[5m])

# Network errors
rate(node_network_receive_errs_total[5m])
```

---

## Additional Resources

### Documentation

- **Prometheus**: https://prometheus.io/docs/
- **Grafana**: https://grafana.com/docs/
- **Node Exporter**: https://github.com/prometheus/node_exporter

### Community Dashboards

- **Grafana Dashboard Library**: https://grafana.com/grafana/dashboards/
- **Awesome Prometheus**: https://github.com/roaldnefs/awesome-prometheus

### Training

- **Prometheus Training**: https://training.promlabs.com/
- **Grafana Tutorials**: https://grafana.com/tutorials/

---

## Conclusion

You now have a complete monitoring stack running with:
- ✅ Prometheus collecting and storing metrics
- ✅ Node Exporter exposing system metrics
- ✅ Grafana visualizing the data
- ✅ Alerts configured for critical conditions

### Next Steps

1. **Add more exporters**: Database, web server, application metrics
2. **Create custom metrics**: Instrument your applications
3. **Set up advanced alerting**: Configure notification channels
4. **Scale horizontally**: Add more nodes to monitor
5. **Implement high availability**: Set up Prometheus federation

Happy Monitoring! 🚀📊
