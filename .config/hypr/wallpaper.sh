#!/bin/sh
# Set a random wallpaper from the collection on login.
# To change wallpaper manually: Super+W (bound in hyprland.conf)

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CACHE="$HOME/.cache/current-wallpaper"

sleep 1  # wait for swww-daemon

# Pick a random wallpaper
wallpaper=$(find "$WALLPAPER_DIR" -type f \( -name '*.png' -o -name '*.jpg' \) | shuf -n 1)

cp "$wallpaper" "$CACHE"
awww img "$wallpaper" --transition-type grow --transition-pos 0.5,0.5 --transition-duration 1
