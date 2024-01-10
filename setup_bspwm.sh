#!/bin/bash

# Function to append a line to a file only if the line doesn't already exist
append_if_not_exist() {
    local file=$1
    local line=$2
    grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

# Check for root privileges
# if [ "$(id -u)" != "0" ]; then
#    echo "Please run this script with sudo to ensure proper permissions."
#    exit 1
# fi

# Update system and install required packages
# sudo xbps-install -Syu
sudo xbps-install -y bspwm sxhkd xcape rofi polybar

# Backup and copy configurations if directories exist and are not empty
for ddir in bspwm sxhkd; do
    if [ -d "$HOME/.config/$ddir" ] && [ "$(ls -A $HOME/.config/$ddir)" ]; then
        cp -r "$HOME/.config/$ddir" "$HOME/.config/${ddir}.backup" || { echo "Failed to backup $ddir config directory"; exit 1; }
    fi
done

# Create configuration directories
mkdir -p ~/.config/bspwm || { echo "Failed to create bspwm config directory"; exit 1; }
mkdir -p ~/.config/sxhkd || { echo "Failed to create sxhkd config directory"; exit 1; }

# Copy new configurations
cp -r assets/bspwm ~/.config/bspwm/
cp -r assets/sxhkd/ ~/.config/sxhkd/

# Make the bspwm config file executable
chmod +x ~/.config/bspwm/bspwmrc

# Append to .xinitrc with checks
XINITRC="$HOME/.xinitrc"
append_if_not_exist "$XINITRC" "setxkbmap -option caps:swapescape &"
append_if_not_exist "$XINITRC" "polybar &"
append_if_not_exist "$XINITRC" "wireplumber &"
append_if_not_exist "$XINITRC" "exec bspwm"



echo "Installation and configuration complete. Please restart your X session to apply changes."
echo "Note: If you experience audio issues after reloading, you may need to adjust wireplumber settings."
