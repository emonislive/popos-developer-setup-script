# Pop!_OS Full Developer Setup Script

This is an all-in-one setup script designed to quickly configure a comprehensive development environment on Pop!_OS (and other Ubuntu-based distros). It installs popular programming languages, tools, IDEs, databases, container platforms, and utilities to help you start coding right away.


## What It Supports

This setup is ideal for:

- **Full-Stack Web Development**
  - Node.js, npm, Java (Spring Boot), Kotlin, Python (Django/Flask), Go, Rust
  - PostgreSQL, MySQL, MongoDB
  - Docker, Podman, Docker Compose

- **Mobile App Development**
  - Android Studio
  - Flutter (via Snap)
  - Java, Kotlin SDKs

- **Desktop App Development**
  - C#, .NET 7 SDK
  - Python GUI frameworks
  - Electron (via Node.js)

- **System & Low-Level Development**
  - GCC/G++, Make (`build-essential`)
  - Zig, Rust, C, C++
  - Fastfetch for system info

- **Machine Learning / Data Science**
  - Python, pip, venv, Miniconda (latest)
  - Jupyter support (via Conda)
  - PostgreSQL, MongoDB integration

- **Linux & CLI Tools**
  - Oh My Zsh terminal experience
  - Gufw Firewall, auto-cpufreq, TLP
  - Git, Curl, Docker CLI, Fastfetch

- **General IDE Use**
  - VS Code, IntelliJ IDEA, PyCharm, WebStorm
  - Obsidian (Markdown notes), Zoom, OBS, Discord



## Features & Versions Installed

- **Essential tools:**  
  - Git  
  - Curl  
  - `build-essential` (includes GCC, G++, Make)  
  - Zsh (set as default shell)  
  - Gufw firewall  

- **Languages & SDKs:**  
  - Java 21 LTS (via SDKMAN)  
  - Kotlin (latest via SDKMAN)  
  - C# (.NET SDK 7.0)  
  - Rust (via rustup)  
  - Go 1.21.1  
  - Zig 0.11.0  
  - Python 3.x + pip + venv + Miniconda  
  - Node.js and npm  

- **Databases:**  
  - MySQL Server  
  - MongoDB 6.0  
  - PostgreSQL (latest stable)  

- **Containers & DevOps:**  
  - Docker 20+  
  - Docker Compose  
  - Podman  

- **Web Browsers:**  
  - Google Chrome Dev  
  - Brave Browser  

- **IDEs & Editors (via Flatpak):**  
  - Visual Studio Code  
  - IntelliJ IDEA Community  
  - PyCharm Community  
  - WebStorm  
  - Android Studio  

- **Popular Flatpak Apps:**  
  - VLC  
  - Discord  
  - Telegram  
  - OBS Studio  
  - Obsidian  
  - Zoom  
  - qBittorrent  
  - AniDL GUI  

- **Other Tools:**  
  - Flutter SDK (via Snap)  
  - Fastfetch (modern Neofetch)  
  - Oh My Zsh (terminal setup)  
  - TLP (power optimization)  
  - auto-cpufreq (CPU power tuning)  

## Requirements

- Pop!_OS 22.04 or Ubuntu 22.04-based distro  
- sudo privileges  
- Active internet connection 

## Usage

1. Download or clone this repository:
   ```bash
   git clone https://github.com/emonislive/popos-developer-setup-script.git
   cd popos-developer-setup-script
   ```
2. Make the script executable:
   ```bash
   chmod +x full_development_setup.sh
   ```
3. Run the script:
   ```bash
   ./full_development_setup.sh
   ```
4. Restart your computer after completion to apply all changes.
   ```bash
   sudo reboot now
   ```

## Notes

- The script may take some time depending on your internet and hardware.
- Some components like Miniconda and Flutter use separate installers/snaps.
- The script will set Zsh as your default shell and install Oh My Zsh automatically.
- Docker group changes require a system reboot to take full effect.
  
