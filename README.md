# Pop!_OS Developer Setup Script

This script automates the installation and configuration of a complete developer environment on a fresh Pop!_OS installation.

## 🔧 Features

- Installs essential APT packages, Flatpak, Snap, and SDK tools
- Automatically checks for existing installations and skips them
- If a package is outdated, removes and installs the latest version
- Non-blocking: skips failed installations and suggests manual intervention
- Lists all installed packages and their versions

---

## 📦 Included in the Setup

### APT Packages

- `git`, `curl`, `build-essential`, `g++`, `gcc`, `cmake`
- `openjdk-21-jdk`, `maven`, `gradle`, `unzip`, `zip`
- `gnome-tweaks`, `apt-transport-https`, `python3`, `python3-pip`, `python3-venv`
- `zsh`, `gufw`, `mysql-server`, `nodejs`, `npm`
- `php`, `composer`, `btop`, `fastfetch` (via PPA)
- `sdkman` (to manage Java, Kotlin, etc.)

### Flatpak Apps

Installed from Flathub:
- Visual Studio Code
- IntelliJ IDEA Community
- PyCharm Community
- WebStorm
- Android Studio
- VLC
- Discord
- Flatseal
- Telegram
- OBS Studio
- Obsidian
- Zoom
- qBittorrent
- ZapZap
- Warehouse
- DBeaver Community
- Thunderbird

### Snap Apps

- Todoist

### Manual/Scripted Installs

- **Google Chrome Dev (Unstable)**
- **Brave Browser**
- **Flutter SDK**
- **Laravel Installer**
- **TypeScript**
- **Kotlin** (via SDKMAN)

---

## 🖥️ System Requirements

- Pop!_OS 22.04 or newer
- Internet connection

---

## 📜 Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/emonislive/popos-developer-setup-script.git
   cd popos-developer-setup-script
   ```
2. Run the Script:
   ```bash
   chmod +x full_development_setup.sh
   ./full_development_setup.sh
   ```
### Note: Use sudo only when prompted. The script will handle privilege elevation as needed.
