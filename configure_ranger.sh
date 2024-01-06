#!/bin/bash

# Function to check if the last command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed to execute."
        exit 1
    fi
}

# Generate default Ranger config
echo "Generating default Ranger configuration..."
ranger --copy-config=all
check_success "Ranger configuration generation"

# Install Pillow for image previews
echo "Installing Pillow for image previews..."
sudo xbps-install -y python3-Pillow
check_success "Pillow installation"

# Modify Ranger config
RANGER_CONFIG="$HOME/.config/ranger/rc.conf"

echo "Configuring Ranger..."

# Define the settings to be added or updated
declare -a settings=(
    "set preview_images true"
    "set preview_images_method kitty"
    "set viewmode miller"
    "set column_ratios 1,3,4"
    "set hidden_filter ^\\.|\.(?:pyc|pyo|bak|swp)\$|^lost\+found\$|^__(py)?cache__$"
    "set show_hidden false"
    "set confirm_on_delete multiple"
    "set use_preview_script true"
    "set automatically_count_files true"
    "set open_all_images true"
    "set vcs_aware false"
    "set vcs_backend_git enabled"
    "set vcs_backend_hg disabled"
    "set vcs_backend_bzr disabled"
    "set vcs_backend_svn disabled"
    "set vcs_msg_length 50"
)

# Comment out existing lines with these settings
for setting in "${settings[@]}"; do
    grep -q "^$setting" "$RANGER_CONFIG" && sed -i "s/^$setting/#$setting/" "$RANGER_CONFIG"
done

# Append new settings
{
    for setting in "${settings[@]}"; do
        echo "$setting"
    done
} >> "$RANGER_CONFIG"

echo "Ranger configuration complete."

