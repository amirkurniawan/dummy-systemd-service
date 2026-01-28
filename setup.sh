#!/bin/bash

#===============================================================================
# Dummy Service Setup Script
# Description: Install and configure the dummy systemd service
# Usage: sudo ./setup.sh
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
echo -e "${CYAN}${BOLD}           DUMMY SYSTEMD SERVICE SETUP                 ${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run as root (sudo ./setup.sh)${NC}"
    exit 1
fi

#===============================================================================
# Step 1: Copy script to /usr/local/bin
#===============================================================================
echo -e "${CYAN}[1/4] Installing dummy.sh script...${NC}"

cp dummy.sh /usr/local/bin/dummy.sh
chmod +x /usr/local/bin/dummy.sh

echo -e "${GREEN}✓ Script installed to /usr/local/bin/dummy.sh${NC}"
echo ""

#===============================================================================
# Step 2: Copy service file to systemd
#===============================================================================
echo -e "${CYAN}[2/4] Installing systemd service...${NC}"

cp dummy.service /etc/systemd/system/dummy.service
chmod 644 /etc/systemd/system/dummy.service

echo -e "${GREEN}✓ Service file installed to /etc/systemd/system/dummy.service${NC}"
echo ""

#===============================================================================
# Step 3: Reload systemd daemon
#===============================================================================
echo -e "${CYAN}[3/4] Reloading systemd daemon...${NC}"

systemctl daemon-reload

echo -e "${GREEN}✓ Systemd daemon reloaded${NC}"
echo ""

#===============================================================================
# Step 4: Enable and start service
#===============================================================================
echo -e "${CYAN}[4/4] Enabling and starting service...${NC}"

systemctl enable dummy
systemctl start dummy

# Wait a moment for service to start
sleep 2

# Check status
if systemctl is-active --quiet dummy; then
    echo -e "${GREEN}✓ Service is running${NC}"
else
    echo -e "${RED}✗ Service failed to start${NC}"
    systemctl status dummy
    exit 1
fi
echo ""

#===============================================================================
# Summary
#===============================================================================
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}           SETUP COMPLETE! 🎉                          ${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Service Status:${NC}"
systemctl status dummy --no-pager | head -5
echo ""
echo -e "  ${BOLD}Useful Commands:${NC}"
echo -e "    • Start:    sudo systemctl start dummy"
echo -e "    • Stop:     sudo systemctl stop dummy"
echo -e "    • Restart:  sudo systemctl restart dummy"
echo -e "    • Status:   sudo systemctl status dummy"
echo -e "    • Enable:   sudo systemctl enable dummy"
echo -e "    • Disable:  sudo systemctl disable dummy"
echo ""
echo -e "  ${BOLD}View Logs:${NC}"
echo -e "    • Journalctl: sudo journalctl -u dummy -f"
echo -e "    • Log file:   sudo tail -f /var/log/dummy-service.log"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
