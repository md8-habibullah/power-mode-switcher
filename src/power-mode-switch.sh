#!/usr/bin/env bash
set -euo pipefail

LOG="/var/log/power-mode-switch.log"
log() { /usr/bin/logger -t power-mode-switch "$*"; printf '%s %s\n' "$(date -Iseconds)" "$*" >>"$LOG"; }

# Run commands as root (sudo if needed)
run_cmd() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

# Find an AC/mains power_supply and return its "online" value (0 or 1)
get_ac_online() {
  # Prefer devices whose type says "Mains" (case-insensitive)
  for s in /sys/class/power_supply/*; do
    [ -e "$s" ] || continue
    if [ -f "$s/type" ] && grep -qi '^mains' "$s/type" 2>/dev/null; then
      if [ -f "$s/online" ]; then
        cat "$s/online" 2>/dev/null || true
        return
      fi
    fi
  done

  # Fallback: first supply with an "online" file
  for s in /sys/class/power_supply/*; do
    [ -e "$s" ] || continue
    if [ -f "$s/online" ]; then
      cat "$s/online" 2>/dev/null || true
      return
    fi
  done

  # If nothing found, return non-zero
  return 1
}

# Detect backend
if command -v powerprofilesctl >/dev/null 2>&1; then
  BACKEND=pwctl
  CMD_SET="$(command -v powerprofilesctl) set"
  CMD_GET="$(command -v powerprofilesctl) get"
elif command -v tuned-adm >/dev/null 2>&1; then
  BACKEND=tuned
  CMD_SET="$(command -v tuned-adm) profile"
  CMD_GET="$(command -v tuned-adm) active"
else
  log "No supported backend found (no powerprofilesctl or tuned-adm). Exiting."
  exit 1
fi

log "Detected backend: $BACKEND"

online="$(get_ac_online || echo "unknown")"
log "AC online raw => '$online'"

# decide target profile names depending on backend
if [ "$online" = "1" ]; then
  # AC plugged -> balanced/performance
  if [ "$BACKEND" = "pwctl" ]; then
    TARGET="balanced"
  else
    # tuned usually has a 'balanced' profile
    TARGET="balanced"
  fi
else
  # AC unplugged -> powersave
  if [ "$BACKEND" = "pwctl" ]; then
    TARGET="power-saver"
  else
    # tuned uses 'powersave' (no hyphen)
    TARGET="powersave"
  fi
fi

log "Setting profile -> $TARGET"

# Run the set command
# For powerprofilesctl the syntax is: powerprofilesctl set <profile>
# For tuned: tuned-adm profile <profile>
set_cmd=( )
if [ "$BACKEND" = "pwctl" ]; then
  set_cmd=( $(command -v powerprofilesctl) set "$TARGET" )
else
  set_cmd=( $(command -v tuned-adm) profile "$TARGET" )
fi

# Execute and capture output
if run_cmd "${set_cmd[@]}" >/dev/null 2>&1; then
  log "Profile set to $TARGET successfully."
else
  log "Failed to set profile using: ${set_cmd[*]}"
  # Write debug info
  log "Backend get output: $($CMD_GET 2>&1 || true)"
  exit 1
fi

