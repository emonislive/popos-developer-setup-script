#!/bin/bash

# Ask for sudo upfront
zenity --info --title="Installer" --text="Enter your password if asked." --width=400
sudo -v

# Function to calculate download speed
calc_speed() {
    local bytes="$1"
    local elapsed="$2"
    if [ $elapsed -eq 0 ]; then elapsed=1; fi
    if [ $bytes -gt 1048576 ]; then
        echo "$(echo "scale=2;$bytes/1048576"|bc) MB/s"
    else
        echo "$(echo "scale=2;$bytes/1024"|bc) KB/s"
    fi
}

# Function to install Snap apps
install_snap() {
    local app="$1"
    local snap_name="${app%% *}"

    if snap list | grep -q "^$snap_name "; then
        echo "$snap_name is already installed" 
        sleep 1
        return
    fi

    start=$(date +%s)
    bytes_downloaded=0

    # Use stdbuf to get live output
    stdbuf -oL -eL sudo snap install $app 2>&1 | while IFS= read -r line; do
        bytes_downloaded=$((bytes_downloaded+1024))
        elapsed=$(( $(date +%s) - start ))
        speed=$(calc_speed $bytes_downloaded $elapsed)
        echo "# Installing $snap_name | Speed: $speed | Elapsed: ${elapsed}s"
    done
}

# Function to install Flatpak apps
install_flatpak() {
    local app="$1"
    if flatpak list | grep -q "$app"; then
        echo "$app is already installed"
        sleep 1
        return
    fi

    start=$(date +%s)
    bytes_downloaded=0

    stdbuf -oL -eL sudo flatpak install --system flathub $app -y 2>&1 | while IFS= read -r line; do
        bytes_downloaded=$((bytes_downloaded+1024))
        elapsed=$(( $(date +%s) - start ))
        speed=$(calc_speed $bytes_downloaded $elapsed)
        echo "# Installing $app | Speed: $speed | Elapsed: ${elapsed}s"
    done
}

# Main progress
(
# System Update
echo "# Updating system..."
sudo apt update -y
sudo apt upgrade -y

# Snap apps
SNAPS=("code --classic" "postman" "intellij-idea-community --classic" "pycharm-community --classic" "android-studio --classic" "webstorm --classic")
for app in "${SNAPS[@]}"; do
    install_snap "$app"
done

# Flatpak apps
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
FLATPAKS=("ro.go.hmlendea.DL-Desktop" "com.rtosta.zapzap" "md.obsidian.Obsidian" "io.github.flattool.Warehouse" "com.github.tchx84.Flatseal" "io.github.realmazharhussain.GdmSettings")
for app in "${FLATPAKS[@]}"; do
    install_flatpak "$app"
done

echo "# Cleanup..."
sudo apt autoremove -y
sudo apt autoclean -y

echo "# ✅ Setup Complete!"
) | zenity --progress \
    --title="System Installer" \
    --width=500 \
    --height=100 \
    --pulsate \
    --auto-close \
    --no-cancel
