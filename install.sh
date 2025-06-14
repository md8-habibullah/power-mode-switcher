#!/usr/bin/env bash
set -e

# 1) Install prerequisites
sudo apt update
sudo apt install -y power-profiles-daemon

# 2) Copy files
sudo cp src/power-mode-switch.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/power-mode-switch.sh

sudo cp src/99-power-mode.rules /etc/udev/rules.d/
sudo cp src/power-mode.service /etc/systemd/system/

# 3) Enable service & reload rules
sudo systemctl daemon-reload
sudo systemctl enable power-mode.service
sudo udevadm control --reload-rules

echo "✅ Installed. Test by plugging/unplugging, rebooting, and suspending."
