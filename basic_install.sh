#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to check if the last command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1 failed to execute.${NC}"
        exit 1
    fi
}

# Update xbps itself first
echo "Updating XBPS..."
sudo xbps-install -u xbps
check_success "XBPS update"

# Ask the user if they want to update the entire system
echo
read -p "Do you want to update the entire system? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Updating system..."
    sudo xbps-install -Syu
    check_success "System update"
else
    echo -e "${GREEN}Skipping full system update.${NC}"
fi

# Install necessary packages
echo "Installing Kitty, Ranger,Vim, Git and Fish-shell..."
sudo xbps-install -y kitty ranger vim git fish-shell
check_success "Package installation"

# Set fish as the default shell
echo "Setting Fish as the default shell..."
if ! chsh -s /usr/bin/fish; then
    echo -e "${RED}Warning: Failed to set Fish as the default shell. You might need to do this manually.${NC}"
else
    echo -e "${GREEN}Fish shell set as default.${NC}"
fi

# Add fish function, aliases, and vi_keys to the config file
FISH_CONFIG="$HOME/.config/fish/config.fish"

echo "Configuring Fish shell..."
mkdir -p $(dirname "$FISH_CONFIG")

# Check if the script section already exists
if ! grep -q "# Script-Added Config Start" "$FISH_CONFIG"; then
    {
        echo "# Script-Added Config Start"
        echo "function r --description 'Run ranger and change to the selected directory'"
        echo "    ranger --choosedir=/tmp/ranger_goto \$argv"
        echo "    test -f /tmp/ranger_goto && cd (cat /tmp/ranger_goto)"
        echo "end"
        echo "alias q='sudo xbps-query -Rs'"
        echo "alias i='sudo xbps-install'"
        echo "fish_vi_key_bindings"
        echo "# Script-Added Config End"
    } >> "$FISH_CONFIG"
    echo -e "${GREEN}Fish configuration updated.${NC}"
else
    echo -e "${GREEN}Fish configuration already contains script-added commands.${NC}"
fi

echo -e "${GREEN}Setup complete. Please log out and log back in for the default shell change to take effect.${NC}"
