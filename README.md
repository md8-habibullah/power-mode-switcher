```markdown
# Power Mode Switcher

Automatically switch GNOME/KDE power profiles between **balanced** and **power-saver** based on your laptop’s AC status (plugged/unplugged), and ensure the correct profile is applied on boot and after resume — on **Debian/Ubuntu**, **Arch-based**, and **Fedora/RHEL/CentOS** systems.

---

## 🚀 Features

- **Automatic switching** on plug/unplug via a udev rule  
- **Profile application** on system boot & resume via systemd  
- **Cross-distro installer** that detects your package manager and sets up everything for you  
- **Clear, colored output** and built-in error handling  
- **One-command install/uninstall**  

---

## 📂 Repository Layout

```

power-mode-switcher/
├── LICENSE
├── README.md            # You are here
├── install.sh           # Cross-distro installer
├── uninstall.sh         # Clean-up script
└── src/
├── power-mode-switch.sh   # Core switching logic
├── 99-power-mode.rules    # udev rule
└── power-mode.service     # systemd unit

````

---

## ⚙️ Prerequisites

- **Bash**, **systemd**, **udev** (default on all target distros)  
- **Root privileges** (or via `sudo`) to install files and enable services  
- A **modern GNOME/KDE** environment with `powerprofilesctl` support (or Fedora’s `tuned-ppd`)  

---

## 📥 Installation

1. **Clone & enter** the repo:
   ```bash
   git clone https://github.com/md8-habibullah/power-mode-switcher.git
   cd power-mode-switcher
````

2. **Ensure executables**:

   ```bash
   chmod +x install.sh uninstall.sh src/power-mode-switch.sh
   ```

3. **Run the installer**:

   ```bash
   ./install.sh
   ```

   You’ll see colored `[INFO]`, `[ OK ]` and `[ERR ]` messages. The script will:

   * Detect your package manager (`apt`, `pacman`, or `dnf`)
   * Install `power-profiles-daemon` (or `tuned-ppd` on Fedora ≥ 41)
   * Copy the switch script, udev rule, and systemd service into place
   * Reload systemd & udev and enable all relevant services

---

## 🔍 How It Works

1. **On plug/unplug**
   The udev rule (`99-power-mode.rules`) watches `/sys/class/power_supply/*/online` events and runs `power-mode-switch.sh`.

2. **On boot & resume**
   The systemd unit (`power-mode.service`) is hooked into normal boot (`multi-user.target`) and suspend/resume (`suspend.target`).

3. **Switch logic**
   `power-mode-switch.sh` detects the correct AC device (e.g. `ADP0`, `AC`, `ACAD`) and:

   ```bash
   if online=1 → powerprofilesctl set balanced
   else         → powerprofilesctl set power-saver
   ```

---

## ✅ Testing & Usage

### 1. Check current profile

* **Debian/Ubuntu/Arch** (using `power-profiles-daemon`):

  ```bash
  powerprofilesctl get
  ```
* **Fedora/CentOS/RHEL** (if using `tuned-ppd`):

  ```bash
  tuned-adm active
  ```

### 2. Manual switch

```bash
# Balanced/performance-like
powerprofilesctl set balanced  
# Max power savings
powerprofilesctl set power-saver  
# Or via tuned
tuned-adm profile balanced
tuned-adm profile powersave
```

### 3. Simulate events

* **Plug/unplug** your charger → then re-run `powerprofilesctl get`
* **Suspend/resume**:

  ```bash
  systemctl suspend && sleep 5 && echo "Resumed!"
  powerprofilesctl get
  ```

### 4. One-line alias (optional)

Add to `~/.bashrc` / `~/.zshrc`:

```bash
alias pget='powerprofilesctl get 2>/dev/null || tuned-adm active'
```

Then simply run:

```bash
pget
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