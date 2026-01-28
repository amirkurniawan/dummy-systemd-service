#!/bin/bash

#===============================================================================
# Dummy Service Uninstall Script
# Description: Remove the dummy systemd service
# Usage: sudo ./uninstall.sh
#
# Project: https://roadmap.sh/projects/dummy-systemd-service
#===============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}           DUMMY SERVICE UNINSTALL                     ${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run as root (sudo ./uninstall.sh)${NC}"
    exit 1
fi

#===============================================================================
# Step 1: Stop service
#===============================================================================
echo -e "${CYAN}[1/4] Stopping service...${NC}"

if systemctl is-active --quiet dummy; then
    systemctl stop dummy
    echo -e "${GREEN}✓ Service stopped${NC}"
else
    echo -e "${YELLOW}Service was not running${NC}"
fi
echo ""

#===============================================================================
# Step 2: Disable service
#===============================================================================
echo -e "${CYAN}[2/4] Disabling service...${NC}"

if systemctl is-enabled --quiet dummy 2>/dev/null; then
    systemctl disable dummy
    echo -e "${GREEN}✓ Service disabled${NC}"
else
    echo -e "${YELLOW}Service was not enabled${NC}"
fi
echo ""

#===============================================================================
# Step 3: Remove files
#===============================================================================
echo -e "${CYAN}[3/4] Removing files...${NC}"

# Remove service file
if [ -f /etc/systemd/system/dummy.service ]; then
    rm /etc/systemd/system/dummy.service
    echo -e "  Removed: /etc/systemd/system/dummy.service"
fi

# Remove script
if [ -f /usr/local/bin/dummy.sh ]; then
    rm /usr/local/bin/dummy.sh
    echo -e "  Removed: /usr/local/bin/dummy.sh"
fi

echo -e "${GREEN}✓ Files removed${NC}"
echo ""

#===============================================================================
# Step 4: Reload systemd
#===============================================================================
echo -e "${CYAN}[4/4] Reloading systemd daemon...${NC}"

systemctl daemon-reload
systemctl reset-failed

echo -e "${GREEN}✓ Systemd daemon reloaded${NC}"
echo ""

#===============================================================================
# Optional: Remove log file
#===============================================================================
if [ -f /var/log/dummy-service.log ]; then
    read -p "Remove log file /var/log/dummy-service.log? (y/n): " REMOVE_LOG
    if [ "$REMOVE_LOG" = "y" ]; then
        rm /var/log/dummy-service.log
        echo -e "${GREEN}✓ Log file removed${NC}"
    else
        echo -e "${YELLOW}Log file kept${NC}"
    fi
fi
echo ""

#===============================================================================
# Summary
#===============================================================================
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}           UNINSTALL COMPLETE! 🧹                      ${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Dummy service has been completely removed."
echo ""
echo -e "${YELLOW}To reinstall, run:${NC}"
echo -e "  sudo ./setup.sh"
echo ""
