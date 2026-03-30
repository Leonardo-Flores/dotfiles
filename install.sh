#!/bin/bash
set -e

# Dotfiles install script for Arch Linux + Hyprland
# Usage: git clone git@github.com:Leonardo-Flores/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install.sh

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# --- Colors ---
green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red() { printf '\033[0;31m%s\033[0m\n' "$*"; }

# --- Pacman packages ---
PACMAN_PKGS=(
    # Base
    base-devel git sudo zsh zsh-autosuggestions zsh-syntax-highlighting

    # Hyprland + desktop
    hyprland hyprlock hypridle hyprpolkitagent
    xdg-desktop-portal-hyprland
    waybar swaync wofi

    # Terminal + shell tools
    kitty starship tmux zoxide neovim lazygit ripgrep jq unzip btop fastfetch

    # Wallpaper + screenshots
    awww grim slurp swappy wl-clipboard cliphist

    # Audio
    pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber
    alsa-utils libpulse pavucontrol
    gst-plugin-pipewire

    # Bluetooth
    bluez bluez-utils blueman

    # Networking
    networkmanager network-manager-applet

    # Theming + fonts
    ttf-jetbrains-mono-nerd noto-fonts-emoji papirus-icon-theme
    qt5ct qt6ct qt5-graphicaleffects qt5-quickcontrols2
    lxappearance nwg-look

    # File manager + printing
    thunar cups cups-pdf ghostscript gsfonts

    # Dev tools
    nodejs npm docker docker-compose

    # Other
    stow nano vim power-profiles-daemon
)

# --- AUR packages (installed via yay) ---
AUR_PKGS=(
    yay
    google-chrome
    bun-bin
    catppuccin-gtk-theme-mocha
    bibata-cursor-theme
    ttf-ms-fonts
    sddm-git
    sddm-catppuccin-git
    sddm-sugar-candy-git
    swayosd-git
    adwaita-dark
)

# --- Install pacman packages ---
green "Installing pacman packages..."
sudo pacman -Syu --needed --noconfirm "${PACMAN_PKGS[@]}"

# --- Install yay if not present ---
if ! command -v yay &>/dev/null; then
    yellow "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay-install
    (cd /tmp/yay-install && makepkg -si --noconfirm)
    rm -rf /tmp/yay-install
fi

# --- Install AUR packages ---
green "Installing AUR packages..."
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# --- Symlink dotfiles with stow ---
green "Linking dotfiles..."
cd "$DOTFILES"
stow -v --target="$HOME" .

# --- Set zsh as default shell ---
if [ "$SHELL" != "$(which zsh)" ]; then
    yellow "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

# --- Enable services ---
green "Enabling services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable --now docker
sudo systemctl enable --now cups
sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable sddm

# --- Make scripts executable ---
chmod +x "$HOME/.config/hypr/wallpaper.sh"
chmod +x "$HOME/.config/hypr/wallpaper-cycle.sh"
chmod +x "$HOME/.local/bin/"*

green "Done! Reboot and select Hyprland in SDDM."
