#!/bin/bash

#!/bin/bash

# URL to the Void Linux download page
DOWNLOAD_PAGE_URL="https://repo-default.voidlinux.org/live/current/"

# Fetch the latest XFCE ISO link
echo "Fetching the latest version of Void Linux with XFCE..."
LATEST_ISO_LINK=$(wget -qO- "$DOWNLOAD_PAGE_URL" | grep -oP 'href="\Kvoid-live-x86_64-\d{8}-xfce.iso(?=")' | head -1)
ISO_URL="${DOWNLOAD_PAGE_URL}${LATEST_ISO_LINK}"
OUTPUT_ISO="/tmp/void-linux-xfce.iso"

if [ -z "$LATEST_ISO_LINK" ]; then
    echo "Failed to find the latest Void Linux XFCE ISO. Exiting."
    exit 1
fi

echo "Latest Void Linux XFCE ISO: $LATEST_ISO_LINK"

# Check if the ISO is already downloaded
if [ -f "$OUTPUT_ISO" ]; then
    read -p "The latest ISO is already downloaded. Do you want to redownload it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using the existing ISO file."
    else
        wget -O "$OUTPUT_ISO" "$ISO_URL"
    fi
else
    # Download the Void Linux ISO
    wget -O "$OUTPUT_ISO" "$ISO_URL"
fi

# Download the checksum file
echo "Downloading the checksum file..."
CHECKSUM_FILE_URL="${DOWNLOAD_PAGE_URL}sha256sum.txt"
wget -O "/tmp/sha256sum.txt" "$CHECKSUM_FILE_URL"

# Extract the checksum for the downloaded ISO
ISO_CHECKSUM=$(grep "$LATEST_ISO_LINK" /tmp/sha256sum.txt | awk -F ' = ' '{print $2}')

# Print the checksum from the sha256sum.txt file
echo "Checksum from sha256sum.txt: $ISO_CHECKSUM"

# Verify the ISO checksum
echo "Verifying the ISO checksum..."
CALCULATED_CHECKSUM=$(sha256sum "$OUTPUT_ISO" | awk '{ print $1 }')

# Print the calculated checksum
echo "Calculated checksum of the downloaded ISO: $CALCULATED_CHECKSUM"

if [ "$ISO_CHECKSUM" != "$CALCULATED_CHECKSUM" ]; then
    echo "Checksum verification failed. The ISO file may be corrupted. Exiting."
    exit 1
fi

echo "Checksum verification successful."

# List USB drives
echo "Available USB drives:"
lsblk -d -n -l -o NAME,SIZE,MODEL | grep -e sd -e nvme
echo "Please enter the device name of your USB drive (e.g., sdb):"
read USB_DRIVE

# Confirm the selected drive
USB_DRIVE="/dev/$USB_DRIVE"
read -p "You have selected '$USB_DRIVE'. Are you sure? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborted by user."
    exit 1
fi

# Write the ISO to the USB drive
echo "Writing ISO to USB drive $USB_DRIVE..."
sudo dd if="$OUTPUT_ISO" of="$USB_DRIVE" bs=4M status=progress

# Eject the USB drive safely
echo "Ejecting the USB drive..."
sudo sync
sudo eject "$USB_DRIVE"

echo "Void Linux with XFCE is now bootable from your USB drive."
