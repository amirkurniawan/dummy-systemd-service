#!/bin/bash

#===============================================================================
# Dummy Service Script
# Description: Simulates a background application that runs continuously
# Location: /usr/local/bin/dummy.sh
#
# Project: https://roadmap.sh/projects/dummy-systemd-service
#===============================================================================

LOG_FILE="/var/log/dummy-service.log"

# Create log file if not exists
touch "$LOG_FILE"

# Log startup
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Dummy service STARTED (PID: $$)" >> "$LOG_FILE"

# Trap SIGTERM for graceful shutdown
cleanup() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Dummy service STOPPED (received shutdown signal)" >> "$LOG_FILE"
    exit 0
}
trap cleanup SIGTERM SIGINT

# Counter for tracking iterations
COUNT=0

# Main loop - runs forever
while true; do
    COUNT=$((COUNT + 1))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Dummy service is running... (iteration: $COUNT)" >> "$LOG_FILE"
    sleep 10
done
