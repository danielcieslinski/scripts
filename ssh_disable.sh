#!/bin/bash

# Script to disable root SSH login on Void Linux

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Path to the SSHD config file
SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup the current SSHD config file
cp $SSHD_CONFIG "${SSHD_CONFIG}.bak"

# Disable root login via SSH
sed -i '/^PermitRootLogin/s/yes/no/' $SSHD_CONFIG

# Restart SSH service to apply changes
sv restart sshd

echo "Root login via SSH has been disabled."

