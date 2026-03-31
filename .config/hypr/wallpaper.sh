#!/bin/sh
# Set the current wallpaper on login.
# To change wallpaper: Super+W (bound in hyprland.conf)

CURRENT="$HOME/wallpapers/current.jpg"

sleep 1  # wait for awww-daemon
[ -f "$CURRENT" ] && awww img "$CURRENT" --transition-type grow --transition-pos 0.5,0.5 --transition-duration 1
