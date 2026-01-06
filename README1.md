# Prometheus + Node Exporter + Grafana Monitoring Setup

This repository documents a **complete end-to-end setup** of **Prometheus, Node Exporter, and Grafana** on an EC2/Linux server, including **CPU monitoring, alerting, dashboards, and backups**.

---

## 📌 Architecture Overview

EC2 Instance
├── Node Exporter (Port 9100)
├── Prometheus (Port 9090)
└── Grafana (Port 3000)

yaml
Copy code

- **Node Exporter** exposes system metrics
- **Prometheus** scrapes metrics and evaluates alerts
- **Grafana** visualizes metrics and dashboards

---

## 🧰 Prerequisites

- Linux server (Amazon Linux / RHEL / CentOS)
- Ports open in Security Group:
  - `9090` – Prometheus
  - `9100` – Node Exporter
  - `3000` – Grafana
- Root or sudo access

---

## 🚀 1. Install Node Exporter

```bash
sudo useradd --no-create-home --shell /bin/false node_exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvf node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
Create systemd service
bash
Copy code
sudo vi /etc/systemd/system/node_exporter.service
ini
Copy code
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
bash
Copy code
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
Verify:

bash
Copy code
curl localhost:9100/metrics
📊 2. Install Prometheus
bash
Copy code
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus /var/lib/prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.49.1/prometheus-2.49.1.linux-amd64.tar.gz
tar xvf prometheus-2.49.1.linux-amd64.tar.gz
sudo cp prometheus-2.49.1.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.49.1.linux-amd64/promtool /usr/local/bin/
Prometheus configuration
bash
Copy code
sudo vi /etc/prometheus/prometheus.yml
yaml
Copy code
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "/etc/prometheus/alert-rules.yml"

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"]
Prometheus systemd service
bash
Copy code
sudo vi /etc/systemd/system/prometheus.service
ini
Copy code
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
bash
Copy code
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
Verify:

cpp
Copy code
http://<EC2-IP>:9090
Status → Targets
🚨 3. Configure CPU Alert in Prometheus
bash
Copy code
sudo vi /etc/prometheus/alert-rules.yml
yaml
Copy code
groups:
- name: cpu-alerts
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 20
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: High CPU usage detected
      description: CPU usage is above threshold
Restart Prometheus:

bash
Copy code
sudo systemctl restart prometheus
Check:

nginx
Copy code
Status → Alerts
📈 4. Install Grafana
bash
Copy code
sudo yum install -y https://dl.grafana.com/oss/release/grafana-10.2.3-1.x86_64.rpm
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
Access:

pgsql
Copy code
http://<EC2-IP>:3000
Login: admin / admin
📊 5. Create Grafana Dashboard (Manual)
Settings → Data Sources → Add Prometheus

URL: http://localhost:9090

Dashboards → New → Add Panel

Query:

promql
Copy code
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
Visualization: Time series / Gauge

Set thresholds (e.g., 80%)

🔥 6. Generate CPU Load (Testing)
bash
Copy code
sudo yum install -y stress
stress --cpu 1 --timeout 300
Prometheus alert → INACTIVE → PENDING → FIRING

Grafana dashboard shows spike

💾 7. Prometheus Backup (CLI)
bash
Copy code
tar -czvf prometheus-backup-$(date +%F).tar.gz /var/lib/prometheus
🧠 Key Learnings
rate() requires sufficient scrape data

Default scrape interval is 1 minute if not defined

Alerts transition: INACTIVE → PENDING → FIRING

Correct PromQL aggregation is critical for CPU metrics

✅ Outcome
✔ Node metrics collected
✔ CPU load visualized
✔ Alerts triggered successfully
✔ Grafana dashboards created

📌 Author
Kunal Bhavasar
DevOps | Monitoring | AWS | Linux

⭐ If you found this helpful, feel free to star the repo!

yaml
Copy code

---

If you want, I can also:
- Add **Alertmanager section**
- Add **screenshots section**
- Create **README with diagrams**
- Convert this to **MkDocs / GitBook**

Just tell me 👍
