# Power Mode Switcher

Automatically switch power profiles between **Balanced** and **Power Saver** based on laptop power status (plugged/unplugged), including on boot and resume — now with **cross‑distro support**!

## 📂 Repository Layout
```
power-mode-switcher/
├── LICENSE
├── README.md            # This file
├── install.sh           # Cross‑distro installation script
├── uninstall.sh         # Uninstallation script
└── src/
├── power-mode-switch.sh   # Main switching script
├── 99-power-mode.rules    # udev rule
└── power-mode.service     # systemd service definition
```
---

## ⚙️ Supported Distributions

- **Debian / Ubuntu / Zorin** (APT)
- **Arch / Manjaro / EndeavourOS** (Pacman)
- **Fedora / RHEL / CentOS** (DNF / tuned‑ppd)

---

## 🛠️ Prerequisites

- A modern GNOME or KDE desktop with **`powerprofilesctl`** support  
- **`bash`**, **`udev`**, **`systemd`** (default on all supported distros)  
- **Root** or sudo privileges to install/uninstall  

---

## 🚀 Installation

1. **Clone & enter repo**  
   ```bash
   git clone https://github.com/md8-habibullah/power-mode-switcher.git
   cd power-mode-switcher
   ```

2. **Make scripts executable**

   ```bash
   chmod +x install.sh uninstall.sh src/power-mode-switch.sh
   ```

3. **Run the installer**

   ```bash
   ./install.sh
   ```

   You’ll see **coloured**, step‑by‑step output:

   * Detects your package manager (`apt`, `pacman`, or `dnf`)
   * Installs **`power-profiles-daemon`** (or swaps in **`tuned‑ppd`** on Fedora ≥ 41)
   * Copies the switch script, udev rule, and systemd unit into place
   * Reloads systemd & udev, then **enables** all services

---

## 🔍 Testing & Manual Use

1. **Automatic switching**

   * **Plug** or **unplug** your AC adapter → runs automatically
   * **Suspend** & **resume** → runs on wake

2. **Check current profile**

   ```bash
   powerprofilesctl get
   ```

   (on Fedora/RHEL with tuned‑ppd you can also run `tuned-adm active`)

3. **Manual invocation**

   ```bash
   sudo /usr/local/bin/power-mode-switch.sh
   ```

---

## 🛠 Uninstallation

In the repo directory:

```bash
./uninstall.sh
```

This will:

1. Disable & remove the `power-mode.service` unit
2. Remove `/etc/udev/rules.d/99-power-mode.rules`
3. Remove `/usr/local/bin/power-mode-switch.sh`
4. Reload systemd & udev rules

---

## 🔧 Customization

* **AC device name**
  If your AC path differs, edit in `src/power-mode-switch.sh`:

  ```bash
  for P in /sys/class/power_supply/ADP* /sys/class/power_supply/AC* /sys/class/power_supply/ACAD*; do
    …
  done
  ```

* **Enable logging**
  Uncomment in `power-mode-switch.sh`:

  ```bash
  # echo "$(date +'%F %T'): AC=$STATUS → $(powerprofilesctl get)" >> /var/log/power-mode.log
  ```

  Ensure `/var/log/power-mode.log` is writable by root.

* **Custom profiles**
  Replace `balanced`/`power-saver` with any profile name supported by your system.

---

## 🆘 Troubleshooting

* **No switching on plug/unplug**

  ```bash
  udevadm monitor --udev
  ```

  Verify `POWER_SUPPLY_ONLINE` events and that your rule matches the device.

* **Service errors on boot/resume**

  ```bash
  journalctl -u power-mode.service -b
  systemctl status power-mode.service
  ```

* **Permissions**
  Ensure `/usr/local/bin/power-mode-switch.sh` is `chmod +x` and owned by root.


---

> *Supports Debian/Ubuntu, Zorin, Mint, Arch, Manjaro, EndeavourOS, Fedora, CentOS, RHEL and any system with systemd & udev.*
> *Created by Md. Habibullah (md8-habibullah)*