#!/usr/bin/env bash
# Automated Developer Setup Script for Any User (Pop!_OS / Ubuntu / Debian)
# Date: 2025-08-14

CURRENT_USER=$(whoami)
HOME_DIR=$(eval echo "~$CURRENT_USER")

echo "========================================"
echo " Developer Environment Setup"
echo " Running as: $CURRENT_USER"
echo " Home Directory: $HOME_DIR"
echo "========================================"

# --- Update system ---
echo "[1/8] Updating system packages..."
sudo apt update -y && sudo apt upgrade -y || echo "⚠️ Warning: apt update/upgrade failed, continuing..."

# --- Install APT packages ---
install_apt_pkg() {
    if ! dpkg -s "$1" >/dev/null 2>&1; then
        echo "Installing $1..."
        sudo apt install -y "$1" || echo "⚠️ Warning: Failed to install $1, skipping..."
    else
        echo "$1 is already installed. Skipping."
    fi
}

APT_PACKAGES=(
    git curl wget build-essential
    zsh vim htop unzip
    nodejs npm python3 python3-pip
)

echo "[2/8] Installing APT packages..."
for pkg in "${APT_PACKAGES[@]}"; do
    install_apt_pkg "$pkg"
done

# --- Install Snap packages ---
install_snap_pkg() {
    if ! snap list | grep -q "^$1 "; then
        echo "Installing $1 via snap..."
        sudo snap install "$1" "$2" || echo "⚠️ Warning: Failed to install $1 via snap, skipping..."
    else
        echo "$1 is already installed via snap. Skipping."
    fi
}

SNAP_PACKAGES=(
    "code --classic"
    "postman"
    "intellij-idea-community --classic"
    "pycharm-community --classic"
    "android-studio --classic"
    "webstorm --classic"
)

echo "[3/8] Installing Snap packages..."
for snap_entry in "${SNAP_PACKAGES[@]}"; do
    snap_name=$(echo "$snap_entry" | awk '{print $1}')
    snap_flags=$(echo "$snap_entry" | cut -d' ' -f2-)
    install_snap_pkg "$snap_name" "$snap_flags"
done

# --- Install Flatpak packages ---
install_flatpak_pkg() {
    if ! flatpak list | grep -q "$1"; then
        echo "Installing $1 via flatpak..."
        flatpak install -y flathub "$1" || echo "⚠️ Warning: Failed to install $1 via flatpak, skipping..."
    else
        echo "$1 is already installed via flatpak. Skipping."
    fi
}

FLATPAK_PACKAGES=(
    "ro.go.hmlendea.DL-Desktop"
    "com.rtosta.zapzap"
    "md.obsidian.Obsidian"
    "io.github.flattool.Warehouse"
    "com.github.tchx84.Flatseal"
    "io.github.realmazharhussain.GdmSettings"
)

echo "[4/8] Installing Flatpak packages..."
for fp in "${FLATPAK_PACKAGES[@]}"; do
    install_flatpak_pkg "$fp"
done

# --- Setup Zsh & Oh My Zsh ---
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "[5/8] Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || echo "⚠️ Warning: Oh My Zsh installation failed"
    chsh -s "$(which zsh)" "$CURRENT_USER" || echo "⚠️ Warning: Failed to change default shell to Zsh"
else
    echo "Zsh is already the default shell. Skipping."
fi

# --- Configure Git ---
echo "[6/8] Setting up Git..."
git config --global user.name "Your Name" || echo "⚠️ Warning: Failed to set Git username"
git config --global user.email "you@example.com" || echo "⚠️ Warning: Failed to set Git email"

# --- Create Development Folders ---
echo "[7/8] Creating folders..."
mkdir -p "$HOME_DIR"/Projects "$HOME_DIR"/Tools || echo "⚠️ Warning: Failed to create folders"

# --- Final Cleanup ---
echo "[8/8] Cleaning up..."
sudo apt autoremove -y || echo "⚠️ Warning: autoremove failed"
sudo apt clean || echo "⚠️ Warning: apt clean failed"

echo "========================================"
echo "✅ Setup complete for $CURRENT_USER!"
echo " Log out & log in again for shell changes."
echo "========================================"
