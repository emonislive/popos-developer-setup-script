#!/bin/bash

set -e

# Colors for better readability
green='\e[1;32m'
red='\e[1;31m'
nc='\e[0m'

# === Ensure Snap is installed ===
echo -e "${green}Checking Snap installation...${nc}"
if ! command -v snap &>/dev/null; then
    echo "Snap not found. Installing..."
    sudo apt install -y snapd || echo -e "${red}Snap could not be installed. Try manually.${nc}"
else
    echo "Snap is already installed."
fi

# === Add universe repository ===
echo -e "${green}Adding universe repository...${nc}"
sudo add-apt-repository universe -y || echo -e "${red}Failed to add universe repo.${nc}"

# === Update package lists ===
echo -e "${green}Updating package lists...${nc}"
sudo apt update || echo -e "${red}Failed to update package lists.${nc}"

# === Install APT Packages ===
APT_PACKAGES=(
  git curl build-essential g++ gcc cmake openjdk-21-jdk maven gradle unzip zip auto-cpufreq gnome-tweaks apt-transport-https python3 python3-pip python3-venv zsh gufw mysql-server nodejs npm php php-cli php-curl php-mysql php-mbstring php-xml php-bcmath php-zip unzip composer btop neofetch ubuntu-restricted-extras fastfetch
)
echo -e "${green}Installing APT packages...${nc}"
for pkg in "${APT_PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    echo "$pkg is already installed."
  else
    sudo apt install -y "$pkg" || echo -e "${red}$pkg couldn't be installed. Try manually.${nc}"
  fi
done

# === Install .NET SDK (C#) ===
echo -e "${green}Installing .NET SDK for C# development...${nc}"
if ! dpkg -s dotnet-sdk-7.0 &>/dev/null; then
  wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
  sudo dpkg -i /tmp/packages-microsoft-prod.deb
  rm /tmp/packages-microsoft-prod.deb
  sudo apt update
  sudo apt install -y dotnet-sdk-7.0 || echo -e "${red}.NET SDK installation failed.${nc}"
else
  echo ".NET SDK already installed."
fi

# === BATTERY OPTIMIZATION: TLP + auto-cpufreq ===
echo -e "${green}Installing and enabling TLP and auto-cpufreq...${nc}"
sudo apt install -y tlp tlp-rdw || echo -e "${red}Failed to install TLP.${nc}"
sudo systemctl enable tlp --now
sudo auto-cpufreq --install || echo -e "${red}auto-cpufreq install failed or already installed.${nc}"

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
  echo -e "${green}Installing Oh My Zsh...${nc}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# === SDKMAN FOR JAVA, KOTLIN ===
echo -e "${green}Installing SDKMAN and Java 21 LTS & Kotlin...${nc}"
if [ ! -d "$HOME/.sdkman" ]; then
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  sdk install java 21.0.2-tem
  sdk default java 21.0.2-tem
  sdk install kotlin
else
  echo "SDKMAN already installed."
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# === INSTALL RUST (rustup) ===
echo -e "${green}Installing Rust (rustup)...${nc}"
if ! command -v rustc &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  echo "Rust is already installed."
fi

# === INSTALL GO ===
echo -e "${green}Installing Go programming language...${nc}"
GO_VERSION="1.21.1"
INSTALLED_GO_VERSION=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
if [ "$INSTALLED_GO_VERSION" != "$GO_VERSION" ]; then
  wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go${GO_VERSION}.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go${GO_VERSION}.linux-amd64.tar.gz
  rm /tmp/go${GO_VERSION}.linux-amd64.tar.gz
  if ! grep -q 'export PATH=$PATH:/usr/local/go/bin' ~/.profile; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
  fi
  export PATH=$PATH:/usr/local/go/bin
else
  echo "Go $GO_VERSION is already installed."
fi

# === INSTALL ZIG ===
echo -e "${green}Installing Zig programming language...${nc}"
ZIG_VERSION="0.11.0"
INSTALLED_ZIG_VERSION=$(zig version 2>/dev/null || echo "")
if [ "$INSTALLED_ZIG_VERSION" != "$ZIG_VERSION" ]; then
  wget https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz -O /tmp/zig-linux-x86_64-${ZIG_VERSION}.tar.xz
  sudo rm -rf /opt/zig-linux-x86_64-*
  sudo tar -xf /tmp/zig-linux-x86_64-${ZIG_VERSION}.tar.xz -C /opt
  rm /tmp/zig-linux-x86_64-${ZIG_VERSION}.tar.xz
  if ! grep -q "export PATH=\$PATH:/opt/zig-linux-x86_64-${ZIG_VERSION}" ~/.profile; then
    echo "export PATH=\$PATH:/opt/zig-linux-x86_64-${ZIG_VERSION}" >> ~/.profile
  fi
  export PATH=$PATH:/opt/zig-linux-x86_64-${ZIG_VERSION}
else
  echo "Zig $ZIG_VERSION is already installed."
fi

# === INSTALL MONGODB ===
echo -e "${green}Installing MongoDB...${nc}"
if ! dpkg -s mongodb-org &>/dev/null; then
  wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
  sudo apt update
  sudo apt install -y mongodb-org || echo -e "${red}MongoDB installation failed.${nc}"
  sudo systemctl enable mongod --now
else
  echo "MongoDB is already installed."
fi

# === INSTALL POSTGRESQL ===
echo -e "${green}Installing PostgreSQL...${nc}"
if ! dpkg -s postgresql &>/dev/null; then
  sudo apt install -y postgresql postgresql-contrib || echo -e "${red}PostgreSQL installation failed.${nc}"
  sudo systemctl enable postgresql --now
else
  echo "PostgreSQL is already installed."
fi

# === INSTALL MINICONDA ===
echo -e "${green}Installing Miniconda...${nc}"
CONDA_DIR="$HOME/miniconda3"
if [ ! -d "$CONDA_DIR" ]; then
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
  bash /tmp/miniconda.sh -b -p "$CONDA_DIR"
  rm /tmp/miniconda.sh
  echo "export PATH=\"$CONDA_DIR/bin:\$PATH\"" >> ~/.profile
  export PATH="$CONDA_DIR/bin:$PATH"
else
  echo "Miniconda is already installed."
fi

# === FLATPAK + FLATHUB SETUP ===
echo -e "${green}Installing Flatpak and adding Flathub repo...${nc}"
if ! command -v flatpak &>/dev/null; then
  sudo apt install -y flatpak gnome-software-plugin-flatpak || echo -e "${red}Flatpak installation failed.${nc}"
fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

# === INSTALL FLATPAK APPS ===
echo -e "${green}Installing Flatpak apps...${nc}"
FLATPAK_APPS=(
  com.visualstudio.code
  com.jetbrains.IntelliJ-IDEA-Community
  com.jetbrains.PyCharm-Community
  com.jetbrains.WebStorm
  com.google.AndroidStudio
  org.videolan.VLC
  com.discordapp.Discord
  com.github.tchx84.Flatseal
  org.telegram.desktop
  com.obsproject.Studio
  md.obsidian.Obsidian
  us.zoom.Zoom
  org.qbittorrent.qBittorrent
  com.github.tchx84.ZapZap
  org.warehouse.Warehouse
  io.dbeaver.DBeaverCommunity
  org.mozilla.Thunderbird
)
for app in "${FLATPAK_APPS[@]}"; do
  if flatpak list | grep -q "$app"; then
    echo "$app is already installed via Flatpak."
  else
    flatpak install -y flathub "$app" || echo -e "${red}$app couldn't be installed. Try manually.${nc}"
  fi
  echo "Flatpak app $app processed."
done

# === INSTALL SNAP APPS ===
echo -e "${green}Installing Snap apps...${nc}"
SNAP_APPS=(
  todoist
  flutter
)
for app in "${SNAP_APPS[@]}"; do
  if snap list | grep -q "$app"; then
    echo "$app is already installed via Snap."
  else
    sudo snap install "$app" || echo -e "${red}$app couldn't be installed. Try manually.${nc}"
  fi
  echo "Snap app $app processed."
done

# === INSTALL TypeScript ===
echo -e "${green}Installing TypeScript...${nc}"
if command -v tsc &>/dev/null; then
  echo "TypeScript is already installed."
else
  sudo npm install -g typescript || echo -e "${red}TypeScript couldn't be installed. Try manually.${nc}"
fi

# === INSTALL GOOGLE CHROME DEV (UNSTABLE) ===
echo -e "${green}Installing Google Chrome Dev (unstable)...${nc}"
if command -v google-chrome-unstable &>/dev/null; then
  echo "Google Chrome Dev is already installed."
else
  wget https://dl.google.com/linux/direct/google-chrome-unstable_current_amd64.deb -O /tmp/google-chrome-unstable_current_amd64.deb || echo -e "${red}Failed to download Google Chrome Dev.${nc}"
  sudo apt install -y /tmp/google-chrome-unstable_current_amd64.deb || echo -e "${red}Failed to install Google Chrome Dev.${nc}"
  rm /tmp/google-chrome-unstable_current_amd64.deb
fi

# === INSTALL BRAVE BROWSER ===
echo -e "${green}Installing Brave browser...${nc}"
if ! command -v brave-browser &>/dev/null; then
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave.com/static-assets/downloads/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install -y brave-browser || echo -e "${red}Brave installation failed.${nc}"
else
  echo "Brave browser is already installed."
fi

# === INSTALL COMPOSER & LARAVEL ===
echo -e "${green}Installing Laravel installer globally via Composer...${nc}"
if command -v composer &>/dev/null; then
  if ! composer global show | grep -q laravel/installer; then
    composer global require laravel/installer || echo -e "${red}Laravel installer installation failed.${nc}"
  else
    echo "Laravel installer is already installed globally."
  fi
else
  echo -e "${red}Composer not found; Laravel installer cannot be installed.${nc}"
fi

# === List of Installed Apps and Versions ===
echo -e "${green}\n==== List of Installed Apps with Versions ====\n${nc}"

echo -e "APT Packages:"
for pkg in "${APT_PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    ver=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null)
    echo " - $pkg: $ver"
  else
    echo " - $pkg: not installed"
  fi
done

echo -e "\nFlatpak Apps:"
for app in "${FLATPAK_APPS[@]}"; do
  if flatpak list | grep -q "$app"; then
    ver=$(flatpak info "$app" 2>/dev/null | grep Version | awk '{print $2}')
    echo " - $app: $ver"
  else
    echo " - $app: not installed"
  fi
done

echo -e "\nSnap Apps:"
for app in "${SNAP_APPS[@]}"; do
  if snap list | grep -q "$app"; then
    ver=$(snap list "$app" 2>/dev/null | awk 'NR==2{print $2}')
    echo " - $app: $ver"
  else
    echo " - $app: not installed"
  fi
done

echo -e "\nAdditional tools with versions:"

if command -v google-chrome-unstable &>/dev/null; then
  echo " - Google Chrome Dev: $(google-chrome-unstable --version 2>/dev/null)"
fi
if command -v brave-browser &>/dev/null; then
  echo " - Brave Browser: $(brave-browser --version 2>/dev/null)"
fi
if command -v java &>/dev/null; then
  echo " - Java (JDK): $(java -version 2>&1 | head -n 1)"
fi
if command -v dotnet &>/dev/null; then
  echo " - .NET SDK: $(dotnet --version)"
fi
if command -v kotlin &>/dev/null; then
  echo " - Kotlin: $(kotlin -version 2>&1 | head -n 1)"
fi
if command -v rustc &>/dev/null; then
  echo " - Rust: $(rustc --version)"
fi
if command -v go &>/dev/null; then
  echo " - Go: $(go version)"
fi
if command -v zig &>/dev/null; then
  echo " - Zig: $(zig version)"
fi
if command -v php &>/dev/null; then
  echo " - PHP: $(php -v | head -n 1)"
fi
if command -v composer &>/dev/null; then
  echo " - Composer: $(composer --version)"
fi
if command -v laravel &>/dev/null; then
  echo " - Laravel Installer: $(laravel --version)"
fi
if command -v npm &>/dev/null; then
  echo " - npm: $(npm --version)"
fi
if command -v tsc &>/dev/null; then
  echo " - TypeScript: $(tsc --version)"
fi
if command -v fastfetch &>/dev/null; then
  echo " - fastfetch: $(fastfetch --version)"
fi
if command -v btop &>/dev/null; then
  echo " - btop: $(btop --version)"
fi
if command -v podman &>/dev/null; then
  echo " - Podman: $(podman --version)"
fi
if systemctl is-active --quiet mongod; then
  echo " - MongoDB: $(mongod --version | head -n 1)"
fi
if systemctl is-active --quiet postgresql; then
  echo " - PostgreSQL: $(psql --version)"
fi
if systemctl is-active --quiet mysql; then
  echo " - MySQL: $(mysql --version)"
fi
if snap list flutter &>/dev/null; then
  FLUTTER_VER=$(flutter --version 2>/dev/null | head -n 1)
  echo " - Flutter SDK (Snap): $FLUTTER_VER"
elif command -v flutter &>/dev/null; then
  FLUTTER_VER=$(flutter --version 2>/dev/null | head -n 1)
  echo " - Flutter SDK (CLI): $FLUTTER_VER"
fi

echo -e "\n${green}Setup completed successfully! Please restart your terminal or reboot for all changes to take effect.${nc}"
