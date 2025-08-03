#!/bin/bash

set -e

echo "Starting full Pop!_OS dev setup with Kotlin, C#, Conda, MongoDB, PostgreSQL, JetBrains IDEs, TLP, and extras..."

# === SYSTEM UPDATE & ESSENTIAL TOOLS ===
echo "Updating system and installing essential packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl build-essential g++ gcc cmake openjdk-17-jdk maven gradle unzip zip auto-cpufreq gnome-tweaks apt-transport-https python3 python3-pip python3-venv zsh gufw mysql-server nodejs npm wget gnupg lsb-release software-properties-common

# === INSTALL .NET SDK (C#) ===
echo "Installing .NET SDK for C# development..."
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb
rm /tmp/packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-7.0

# === BATTERY OPTIMIZATION: TLP + auto-cpufreq ===
echo "Installing and enabling TLP and auto-cpufreq for power management..."
sudo apt install -y tlp tlp-rdw
sudo systemctl enable tlp --now
sudo auto-cpufreq --install || echo "auto-cpufreq install failed or already installed."

# === SET ZSH AS DEFAULT SHELL ===
if ! grep -q "$(which zsh)" /etc/shells; then
  echo "Adding zsh to /etc/shells"
  echo "$(which zsh)" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Changing default shell to zsh for user $USER"
  chsh -s "$(which zsh)"
fi

# === INSTALL OH-MY-ZSH ===
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# === SDKMAN FOR JAVA, KOTLIN ===
echo "Installing SDKMAN and Java 21 LTS & Kotlin..."
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.2-tem
sdk default java 21.0.2-tem
sdk install kotlin

# === INSTALL RUST (rustup) ===
echo "Installing Rust (rustup)..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# === INSTALL GO ===
echo "Installing Go programming language..."
GO_VERSION="1.21.1"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go${GO_VERSION}.linux-amd64.tar.gz
rm /tmp/go${GO_VERSION}.linux-amd64.tar.gz
if ! grep -q 'export PATH=$PATH:/usr/local/go/bin' ~/.profile; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
fi
export PATH=$PATH:/usr/local/go/bin

# === INSTALL ZIG ===
echo "Installing Zig programming language..."
ZIG_VERSION="0.11.0"
wget https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz -O /tmp/zig-linux-x86_64-${ZIG_VERSION}.tar.xz
sudo tar -xf /tmp/zig-linux-x86_64-${ZIG_VERSION}.tar.xz -C /opt
rm /tmp/zig-linux-x86_64-${ZIG_VERSION}.tar.xz
if ! grep -q 'export PATH=$PATH:/opt/zig-linux-x86_64-0.11.0' ~/.profile; then
  echo 'export PATH=$PATH:/opt/zig-linux-x86_64-0.11.0' >> ~/.profile
fi
export PATH=$PATH:/opt/zig-linux-x86_64-0.11.0

# === INSTALL DOCKER + DOCKER-COMPOSE + PODMAN ===
echo "Installing Docker, Docker Compose, and Podman..."
sudo apt install -y docker.io docker-compose podman
sudo systemctl enable docker --now
sudo usermod -aG docker $USER

# === INSTALL MONGODB ===
echo "Installing MongoDB..."
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl enable mongod --now

# === INSTALL POSTGRESQL ===
echo "Installing PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql --now

# === INSTALL MINICONDA ===
echo "Installing Miniconda..."
CONDA_DIR="$HOME/miniconda3"
if [ ! -d "$CONDA_DIR" ]; then
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
  bash /tmp/miniconda.sh -b -p "$CONDA_DIR"
  rm /tmp/miniconda.sh
  echo "export PATH=\"$CONDA_DIR/bin:\$PATH\"" >> ~/.profile
  export PATH="$CONDA_DIR/bin:$PATH"
else
  echo "Miniconda already installed."
fi

# === FLATPAK + FLATHUB SETUP ===
echo "Installing Flatpak and adding Flathub repo..."
sudo apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# === INSTALL FLATPAK APPS ===
echo "Installing Flatpak apps..."
flatpak install -y flathub com.visualstudio.code \
                      com.jetbrains.IntelliJ-IDEA-Community \
                      com.jetbrains.PyCharm-Community \
                      com.jetbrains.WebStorm \
                      com.google.AndroidStudio \
                      io.github.freemind1977.AniDL-GUI \
                      org.videolan.VLC \
                      com.discordapp.Discord \
                      com.github.tchx84.Flatseal \
                      org.telegram.desktop \
                      com.obsproject.Studio \
                      md.obsidian.Obsidian \
                      us.zoom.Zoom \
                      org.qbittorrent.qBittorrent \
                      com.github.tchx84.ZapZap \
                      org.warehouse.Warehouse \
                      io.dbeaver.DBeaverCommunity

# === INSTALL GOOGLE CHROME DEV (UNSTABLE) ===
echo "Installing Google Chrome Dev (unstable)..."
wget https://dl.google.com/linux/direct/google-chrome-unstable_current_amd64.deb -O /tmp/google-chrome-unstable_current_amd64.deb
sudo apt install -y /tmp/google-chrome-unstable_current_amd64.deb
rm /tmp/google-chrome-unstable_current_amd64.deb

# === INSTALL BRAVE BROWSER ===
echo "Installing Brave browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave.com/static-assets/downloads/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install -y brave-browser

# === INSTALL FASTFETCH (modern neofetch alternative) ===
echo "Installing fastfetch..."
sudo apt install -y fastfetch

# === FULL FLUTTER SETUP ===
echo "Installing Flutter SDK..."
sudo snap install flutter --classic
flutter precache
flutter doctor

echo "Setup complete! Please restart your terminal or run 'source ~/.profile' to apply PATH changes."
echo "System info:"
fastfetch

echo "Important: You must reboot your system for Docker group changes, shell changes, and database services to take effect."
