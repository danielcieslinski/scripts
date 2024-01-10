#!/bin/bash

# Update system and install sxhkd and bspwm
# sudo xbps-install -Syu
sudo xbps-install -y bspwm sxhkd

# Create configuration directories
mkdir -p ~/.config/bspwm
mkdir -p ~/.config/sxhkd

# Copy default configurations
cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/
cp assets/sxhkdrc ~/.config/sxhkd/

# Make the bspwm config file executable
chmod +x ~/.config/bspwm/bspwmrc

# Add bspwm to xinitrc
echo "exec bspwm" >> ~/.xinitrc

# Installing xcape
sudo xbps-install -y xcape
echo "setxkbmap -option caps:swapescape" >> ~/.xinitrc

# Install rofi
sudo xbps-install -y rofi

# Install polybar
sudo xbps-install -y polybar
echo "polybar &" >> ~/.xinitrc


# Restart the X session or inform the user to do so
echo "Installation and configuration complete. Please restart your X session to apply changes. If something goes down with audio after reload play around with wireplumber"
