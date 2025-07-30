#!/usr/bin/env bash
set -euo pipefail

# Try common power_supply names for AC
STATUS=""
for P in /sys/class/power_supply/ADP* /sys/class/power_supply/AC* /sys/class/power_supply/ACAD*; do
  [[ -f "$P/online" ]] && { STATUS=$(<"$P/online"); break; }
done

# Default to "on battery" if nothing found
: "${STATUS:=0}"

if [[ "$STATUS" -eq 1 ]]; then
  powerprofilesctl set balanced
else
  powerprofilesctl set power-saver
fi
