#!/bin/sh
# Cycle to a random wallpaper — updates desktop, lock screen, and SDDM

BANK="$HOME/wallpapers/bank"
CURRENT="$HOME/wallpapers/current.jpg"
SDDM_BG="/usr/share/sddm/themes/sugar-candy/Backgrounds/wallpaper.jpg"

wallpaper=$(find "$BANK" -type f \( -name '*.png' -o -name '*.jpg' \) | shuf -n 1)

cp "$wallpaper" "$CURRENT"
sudo cp "$CURRENT" "$SDDM_BG"
awww img "$CURRENT" --transition-type grow --transition-pos 0.5,0.5 --transition-duration 1
