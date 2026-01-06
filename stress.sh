#!/bin/bash

echo "===== CPU Utilization Booster ====="
echo "This script will increase CPU usage beyond 80%"
echo "Press CTRL + C to stop."

# Detect number of CPU cores
CORES=$(nproc)
echo "Detected CPU Cores: $CORES"

# Start load on all cores
for i in $(seq 1 $CORES); do
  while true; do :; done &
done

echo "CPU load started on all $CORES cores..."
echo "Run 'top' or 'htop' to verify CPU usage."
echo "To stop, run: killall bash"
