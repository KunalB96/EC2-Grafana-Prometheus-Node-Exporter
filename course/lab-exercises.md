# Lab Exercises: Hands-On Practice

This document contains practical exercises to reinforce your understanding of the Grafana, Prometheus, and Node Exporter stack.

---

## Exercise 1: Basic Setup Verification

### Objective
Verify that all services are running correctly and collecting data.

### Tasks

1. **Check Service Status**
   ```bash
   # Check all services are running
   systemctl status prometheus
   systemctl status node_exporter
   systemctl status grafana-server
   ```

2. **Verify Prometheus Targets**
   - Access Prometheus UI at `http://<your-ip>:9090`
   - Navigate to Status → Targets
   - Confirm both prometheus and node_exporter show as "UP"

3. **Test Metrics Collection**
   ```bash
   # Test direct metrics access
   curl http://localhost:9100/metrics | grep node_cpu
   ```

4. **Basic Prometheus Query**
   - In Prometheus UI, execute this query:
   ```promql
   up
   ```
   - You should see all targets with value 1

### Expected Results
- All services running without errors
- Both targets showing UP status
- Metrics accessible via curl
- Query returns expected results

---

## Exercise 2: Custom Queries

### Objective
Practice writing PromQL queries to extract meaningful metrics.

### Tasks

1. **CPU Utilization Query**
   ```promql
   100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
   ```

2. **Memory Usage Query**
   ```promql
   (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
   ```

3. **Disk I/O Query**
   ```promql
   rate(node_disk_read_bytes_total[5m]) + rate(node_disk_written_bytes_total[5m])
   ```

4. **Network Traffic Query**
   ```promql
   rate(node_network_receive_bytes_total{device!="lo"}[5m])
   ```

5. **Custom Queries to Try**
   - Find the top 5 processes by CPU usage
   - Calculate disk usage percentage
   - Show network interface statistics
   - Display system load averages

### Challenge
Create a query that shows CPU usage per core:
```promql
100 - (avg by (cpu) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

---

## Exercise 3: Dashboard Creation

### Objective
Build a custom dashboard from scratch with various visualization types.

### Tasks

1. **Create New Dashboard**
   - Go to Grafana → Dashboards → New → New Dashboard
   - Name it "System Performance Dashboard"

2. **Add Single Stat Panel - System Uptime**
   - **Query**: `node_time_seconds - node_boot_time_seconds`
   - **Visualization**: Stat
   - **Unit**: Duration (seconds)
   - **Title**: "System Uptime"

3. **Add Graph Panel - CPU Usage Over Time**
   - **Query**: CPU utilization query from Exercise 2
   - **Visualization**: Time series
   - **Title**: "CPU Usage %"
   - **Y-axis**: 0-100

4. **Add Gauge Panel - Memory Usage**
   - **Query**: Memory usage query from Exercise 2
   - **Visualization**: Gauge
   - **Title**: "Memory Usage"
   - **Thresholds**: Green (0-60), Yellow (60-80), Red (80-100)

5. **Add Table Panel - Disk Usage by Mount Point**
   - **Query**: 
   ```promql
   100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)
   ```
   - **Visualization**: Table
   - **Title**: "Disk Usage by Filesystem"

6. **Add Bar Chart - Load Averages**
   - **Queries**: 
   ```promql
   node_load1
   node_load5  
   node_load15
   ```
   - **Visualization**: Bar chart
   - **Title**: "System Load Averages"

### Challenge
Add a heatmap showing CPU usage distribution over time.

---

## Exercise 4: Alert Configuration

### Objective
Set up alerting for critical system conditions.

### Tasks

1. **Create Alert Rules File**
   ```bash
   sudo nano /etc/prometheus/alert_rules.yml
   ```

2. **Add High CPU Alert**
   ```yaml
   - alert: HighCPUUsage
     expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
     for: 2m
     labels:
       severity: warning
     annotations:
       summary: "High CPU usage on {{ $labels.instance }}"
       description: "CPU usage has been above 85% for more than 2 minutes"
   ```

3. **Add Low Disk Space Alert**
   ```yaml
   - alert: LowDiskSpace
     expr: 100 - ((node_filesystem_avail_bytes{mountpoint="/"} * 100) / node_filesystem_size_bytes{mountpoint="/"}) > 90
     for: 5m
     labels:
       severity: critical
     annotations:
       summary: "Low disk space on {{ $labels.instance }}"
       description: "Disk usage is above 90%"
   ```

4. **Update Prometheus Config**
   - Add rule_files section to prometheus.yml
   - Restart Prometheus service

5. **Verify Alerts**
   - Check Prometheus UI → Alerts
   - Confirm rules are loaded

### Challenge
Create an alert for high memory usage with different severity levels.

---

## Exercise 5: Advanced Monitoring

### Objective
Implement more sophisticated monitoring scenarios.

### Tasks

1. **Monitor Multiple Services**
   - Add another Node Exporter on a different port
   - Configure Prometheus to scrape both instances
   - Create queries to compare metrics between instances

2. **Custom Labels and Relabeling**
   ```yaml
   scrape_configs:
     - job_name: 'node_exporter_prod'
       static_configs:
         - targets: ['localhost:9100']
           labels:
             environment: 'production'
             team: 'infrastructure'
   ```

3. **Recording Rules**
   Create recording rules for frequently used queries:
   ```yaml
   - record: instance:cpu_usage:rate5m
     expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
   ```

4. **Dashboard Variables**
   - Create a template variable for instance selection
   - Make dashboard panels dynamic based on selected instance

### Advanced Challenge
Set up Prometheus federation to collect metrics from multiple Prometheus instances.

---

## Exercise 6: Performance Optimization

### Objective
Optimize the monitoring stack for better performance.

### Tasks

1. **Tune Scrape Intervals**
   - Modify scrape intervals based on metric importance
   - Test impact on data granularity

2. **Configure Retention Policies**
   ```bash
   # Add to Prometheus service file
   --storage.tsdb.retention.time=15d
   --storage.tsdb.retention.size=10GB
   ```

3. **Optimize Dashboard Queries**
   - Use recording rules for complex calculations
   - Adjust time ranges and intervals

4. **Monitor Resource Usage**
   - Track Prometheus memory and CPU usage
   - Monitor Grafana performance

### Performance Testing
1. Generate load on the system
2. Observe how metrics change
3. Test alert response times
4. Measure query performance

---

## Exercise 7: Troubleshooting Scenarios

### Objective
Practice diagnosing and fixing common issues.

### Scenario 1: Node Exporter Down
- Stop Node Exporter service
- Identify the issue using Prometheus
- Fix and verify recovery

### Scenario 2: Missing Metrics
- Misconfigure Prometheus scrape config
- Diagnose why metrics aren't appearing
- Correct the configuration

### Scenario 3: Dashboard Not Loading
- Simulate Grafana-Prometheus connection issues
- Use logs to identify problems
- Restore functionality

### Scenario 4: High Resource Usage
- Identify what's consuming resources
- Optimize configurations
- Monitor improvements

---

## Exercise 8: Integration and Automation

### Objective
Integrate monitoring with other tools and automate tasks.

### Tasks

1. **API Automation**
   ```bash
   # Get metrics via API
   curl 'http://localhost:9090/api/v1/query?query=up'
   
   # Export dashboard via Grafana API
   curl -H "Authorization: Bearer <token>" \
     http://localhost:3000/api/dashboards/uid/<uid>
   ```

2. **Backup Automation**
   Create scripts to backup:
   - Prometheus data
   - Grafana dashboards and configurations
   - Alert rules

3. **Health Check Script**
   ```bash
   #!/bin/bash
   # Check if all services are healthy
   services=("prometheus" "node_exporter" "grafana-server")
   for service in "${services[@]}"; do
     systemctl is-active --quiet $service && echo "$service is running" || echo "$service is down"
   done
   ```

4. **Automated Alerting**
   - Configure email notifications
   - Set up Slack integration
   - Test alert delivery

---

## Exercise 9: Security Hardening

### Objective
Implement security best practices for the monitoring stack.

### Tasks

1. **Authentication Setup**
   - Configure Grafana LDAP/OAuth
   - Set up user roles and permissions
   - Enable audit logging

2. **Network Security**
   ```bash
   # Configure firewall rules
   sudo firewall-cmd --permanent --add-port=3000/tcp --source=YOUR_IP
   sudo firewall-cmd --permanent --add-port=9090/tcp --source=YOUR_IP
   sudo firewall-cmd --reload
   ```

3. **HTTPS Configuration**
   - Set up SSL certificates
   - Configure reverse proxy (Nginx/Apache)
   - Redirect HTTP to HTTPS

4. **Access Control**
   - Limit Prometheus web access
   - Configure Grafana viewer/editor roles
   - Implement API key management

---

## Exercise 10: Real-World Scenario

### Objective
Simulate a complete monitoring deployment for a web application.

### Scenario Setup
You're monitoring a web application with:
- Web servers (Nginx)
- Application servers (Node.js/Python)
- Database (MySQL/PostgreSQL)
- Load balancer

### Tasks

1. **Plan Monitoring Strategy**
   - Identify key metrics to monitor
   - Define SLIs (Service Level Indicators)
   - Set SLO (Service Level Objectives) targets

2. **Implement Comprehensive Monitoring**
   - Set up additional exporters (nginx_exporter, mysql_exporter)
   - Create application-specific dashboards
   - Configure business-critical alerts

3. **Create Runbooks**
   - Document response procedures for alerts
   - Create troubleshooting guides
   - Define escalation procedures

4. **Test Incident Response**
   - Simulate various failure scenarios
   - Practice using monitoring data for diagnosis
   - Validate alert notifications

---

## Self-Assessment Checklist

After completing the exercises, verify you can:

### Basic Skills
- [ ] Install and configure Prometheus, Grafana, and Node Exporter
- [ ] Write basic PromQL queries
- [ ] Create simple dashboards and panels
- [ ] Set up basic alerts

### Intermediate Skills
- [ ] Write complex PromQL queries with functions and aggregations
- [ ] Create advanced dashboard with variables and templates
- [ ] Configure recording rules and alert rules
- [ ] Troubleshoot common monitoring issues

### Advanced Skills
- [ ] Optimize performance of monitoring stack
- [ ] Implement security best practices
- [ ] Automate monitoring tasks with APIs and scripts
- [ ] Design monitoring strategy for complex applications

---

## Additional Practice Ideas

1. **Monitor Different Applications**
   - Set up monitoring for web servers, databases, message queues
   - Practice with different exporters and integrations

2. **Experiment with Visualization**
   - Try different panel types and configurations
   - Create custom dashboards for specific use cases

3. **Performance Testing**
   - Load test your monitoring stack
   - Measure and optimize query performance

4. **Community Engagement**
   - Contribute to open-source monitoring projects
   - Share your dashboards with the community

Remember: The best way to learn monitoring is through hands-on practice with real systems and scenarios! 🚀