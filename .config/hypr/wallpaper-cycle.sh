#!/bin/sh
# Cycle to a random wallpaper with a nice transition

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CACHE="$HOME/.cache/current-wallpaper"

wallpaper=$(find "$WALLPAPER_DIR" -type f \( -name '*.png' -o -name '*.jpg' \) | shuf -n 1)

cp "$wallpaper" "$CACHE"
awww img "$wallpaper" --transition-type grow --transition-pos 0.5,0.5 --transition-duration 1
