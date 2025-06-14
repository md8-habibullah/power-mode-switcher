#!/usr/bin/env bash
# Detect AC status (ADP0) and switch GNOME power profile.

AC_PATH="/sys/class/power_supply/ADP0/online"

if [[ -f "$AC_PATH" ]]; then
  STATUS=$(<"$AC_PATH")
else
  STATUS=0
fi

if [[ "$STATUS" -eq 1 ]]; then
  powerprofilesctl set balanced
else
  powerprofilesctl set power-saver
fi

# Optional logging—uncomment to enable:
# echo "$(date): STATUS=$STATUS → $(powerprofilesctl get)" \
#   >> /var/log/power-mode.log
