#!/bin/bash

# Function to append a line to a file only if the line doesn't already exist
append_if_not_exist() {
    local file=$1
    local line=$2
    grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

# Update system and install required packages
sudo xbps-install -y bspwm sxhkd xcape rofi polybar

# Backup and copy configurations if directories exist and are not empty
for dir in bspwm sxhkd; do
    if [ -d "$HOME/.config/$dir" ] && [ "$(ls -A $HOME/.config/$dir)" ]; then
        cp -r "$HOME/.config/$dir" "$HOME/.config/${dir}.backup" || { echo "Failed to backup $dir config directory"; exit 1; }
    fi
done

# Create configuration directories
mkdir -p ~/.config/bspwm || { echo "Failed to create bspwm config directory"; exit 1; }
mkdir -p ~/.config/sxhkd || { echo "Failed to create sxhkd config directory"; exit 1; }

# Copy new configurations
cp assets/bspwm/bspwmrc ~/.config/bspwm/
cp assets/sxhkd/sxhkdrc ~/.config/sxhkd/

# Make the bspwm config file executable
chmod +x ~/.config/bspwm/bspwmrc

# Append commands to bspwmrc
BSPWMRC="$HOME/.config/bspwm/bspwmrc"
append_if_not_exist "$BSPWMRC" "setxkbmap -option caps:swapescape &"
append_if_not_exist "$BSPWMRC" "polybar &"
append_if_not_exist "$BSPWMRC" "wireplumber &"

echo "Installation and configuration complete. Please restart your X session to apply changes."
echo "Note: If you don't use display manager, make sure to put this setup in .xinitrc rather then bspwmrc and remember then to add exec bspwm in the end"
