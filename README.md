# Power Mode Switcher

Automatically switch GNOME power profiles between **Balanced** and **Power Saver** based on laptop power status (plugged/unplugged), including on boot and resume.

---

## Features

* **Automatic switching** on plug/unplug events via udev.
* **Apply correct profile** on system boot and resume from suspend via systemd.
* **Zero dependencies** beyond `power-profiles-daemon` (part of modern Ubuntu/GNOME).
* **Easy install/uninstall** with provided scripts.

---

## Repository Layout

```
power-mode-switcher/
├── LICENSE
├── README.md        # This file
├── install.sh       # Installation script
├── uninstall.sh     # Uninstallation script
└── src/
    ├── power-mode-switch.sh   # Main switching script
    ├── 99-power-mode.rules    # udev rule
    └── power-mode.service     # systemd service definition
```

---

## Prerequisites

* Ubuntu 24.04 / GNOME 46 (or similar with `powerprofilesctl` support).
* `bash`, `udev`, and `systemd` (default on Ubuntu).
* **Optional**: root privileges to install/uninstall.

---

## Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/<your-username>/power-mode-switcher.git
   cd power-mode-switcher
   ```

2. **Make scripts executable** (if not already):

   ```bash
   chmod +x install.sh uninstall.sh src/power-mode-switch.sh
   ```

3. **Run the installer**:

   ```bash
   ./install.sh
   ```

   This will:

   * Install `power-profiles-daemon` if missing.
   * Copy the udev rule, script, and service to system locations.
   * Enable the systemd service and reload udev rules.

4. **Test**:

   * Plug and unplug your charger; profiles should switch automatically.
   * Reboot while plugged/unplugged; correct profile applies on boot.
   * Suspend and resume; profile re-applies on wake.

---

## Usage

* **Check current profile**:

  ```bash
  powerprofilesctl get
  ```
* **Manually switch** (if desired):

  ```bash
  powerprofilesctl set balanced   # Performance/Balanced/Power Saver
  powerprofilesctl set power-saver
  ```

Your system now handles switching automatically.

---

## Uninstallation

To remove the feature completely:

```bash
cd power-mode-switcher
./uninstall.sh
```

This will:

* Disable and remove the systemd service.
* Remove the udev rule and script.
* Reload systemd and udev rules.

---

## Customization

* **Change AC adapter name**: If your power supply dir is not `ADP0`, edit `src/power-mode-switch.sh`:

  ```bash
  AC_PATH="/sys/class/power_supply/<YOUR_DEVICE>/online"
  ```

* **Enable logging**: Uncomment the logging lines in `power-mode-switch.sh` and ensure write permissions to `/var/log/power-mode.log`.

* **Profile names**: Adjust `powerprofilesctl set <profile>` calls if you have custom profiles.

---

## Troubleshooting

* **No switch on plug/unplug**:

  * Verify `udevadm monitor` shows `POWER_SUPPLY_ONLINE` changes for your device.
  * Confirm the udev rule matches your device name.

* **Service fails on boot/resume**:

  * Check status: `systemctl status power-mode.service`.
  * Inspect logs: `journalctl -u power-mode.service`.

* **Permissions**:

  * Ensure `/usr/local/bin/power-mode-switch.sh` is executable.
  * Udev rules require root; check `/etc/udev/rules.d/99-power-mode.rules` ownership.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
