#!/usr/bin/env bash
set -e

# 1) Disable and remove service
sudo systemctl disable power-mode.service || true
sudo rm -f /etc/systemd/system/power-mode.service

# 2) Remove udev rule and script
sudo rm -f /etc/udev/rules.d/99-power-mode.rules
sudo rm -f /usr/local/bin/power-mode-switch.sh

# 3) Reload
sudo systemctl daemon-reload
sudo udevadm control --reload-rules

echo "🗑️ Uninstalled. All files removed and services disabled."
