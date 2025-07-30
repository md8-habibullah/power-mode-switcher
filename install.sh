#!/usr/bin/env bash
set -euo pipefail

# ─── Colours & Helpers ─────────────────────────────────────────────────────────
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; RESET="\e[0m"

info()    { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[ OK ]${RESET} $*"; }
warning() { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERR ]${RESET} $*"; exit 1; }

# ─── 1. Detect distro & install deps ────────────────────────────────────────────
info "Detecting package manager…"
if   command -v apt   &>/dev/null; then PKG=apt
elif command -v pacman&>/dev/null; then PKG=pacman
elif command -v dnf   &>/dev/null; then PKG=dnf
else
  error "Unsupported distro. Manual install required."
fi
success "Found package manager: $PKG"

info "Installing power profile daemon…"
case "$PKG" in
  apt)
    sudo apt update -qq
    sudo apt install -y power-profiles-daemon ;;
  pacman)
    sudo pacman -Syu --noconfirm power-profiles-daemon ;;
  dnf)
    # Fedora ≥41 uses tuned-ppd by default
    if rpm -q tuned-ppd &>/dev/null; then
      sudo dnf install -y tuned-ppd
      sudo dnf swap -y power-profiles-daemon tuned-ppd
    else
      sudo dnf install -y power-profiles-daemon
    fi ;;
esac
success "Dependency installed"

# ─── 2. Copy files ─────────────────────────────────────────────────────────────
info "Copying files to system locations…"
sudo install -m755 src/power-mode-switch.sh /usr/local/bin/power-mode-switch.sh \
  || error "Failed to install switch script"
sudo install -m644 src/99-power-mode.rules /etc/udev/rules.d/99-power-mode.rules \
  || error "Failed to install udev rule"
sudo install -m644 src/power-mode.service /etc/systemd/system/power-mode.service \
  || error "Failed to install systemd service"
success "Files copied"

# ─── 3. Enable & reload ─────────────────────────────────────────────────────────
info "Reloading systemd & udev rules…"
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
success "Reload complete"

info "Enabling services…"
sudo systemctl enable --now power-mode.service \
  || warning "power-mode.service failed to enable"
# enable power daemon
if   systemctl list-unit-files | grep -q '^power-profiles-daemon'; then
  sudo systemctl enable --now power-profiles-daemon.service
elif systemctl list-unit-files | grep -q '^tuned-ppd'; then
  sudo systemctl enable --now tuned-ppd.service
fi
success "Services enabled"

# ─── 4. Finish ─────────────────────────────────────────────────────────────────
cat <<EOF

${GREEN}✅  Installation complete!${RESET}

▶️  To test now:
   • Plug/unplug your AC adapter
     → run: ${YELLOW}powerprofilesctl get${RESET}
     → should toggle between "balanced" and "power-saver"

   • Suspend & resume
     → same check

▶️  Manual run (any distro):
   sudo /usr/local/bin/power-mode-switch.sh

▶️  To uninstall:
   sudo systemctl disable power-mode.service \
     && sudo rm -f /etc/systemd/system/power-mode.service \
     && sudo rm -f /etc/udev/rules.d/99-power-mode.rules \
     && sudo rm -f /usr/local/bin/power-mode-switch.sh \
     && sudo systemctl daemon-reload \
     && sudo udevadm control --reload-rules \
     && echo "🗑️  Uninstalled."

EOF
