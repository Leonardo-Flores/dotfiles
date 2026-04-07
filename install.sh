#!/bin/bash
set -euo pipefail

# Dotfiles install script for Arch Linux + Hyprland.
# Idempotent: safe to re-run. Handles the case where archinstall's
# "hyprland desktop" profile has already created config files that
# would otherwise collide with stow.
#
# Usage:
#   git clone git@github.com:Leonardo-Flores/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && ./install.sh

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# --- Colors ---
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }

if [ "$(id -u)" -eq 0 ]; then
    red "Do not run install.sh as root. Run as your normal user; sudo will be invoked when needed."
    exit 1
fi

# Prime sudo once so the rest of the script doesn't keep prompting.
sudo -v
( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

# --- Pacman packages ---
PACMAN_PKGS=(
    # Base
    base-devel git sudo zsh zsh-autosuggestions zsh-syntax-highlighting

    # Hyprland + desktop
    hyprland hyprlock hypridle hyprpolkitagent
    xdg-desktop-portal-hyprland xdg-user-dirs
    waybar swaync wofi libnotify

    # Wayland Qt support (so Qt apps render natively, not via XWayland)
    qt5-wayland qt6-wayland

    # Terminal + shell tools
    kitty starship tmux zoxide neovim lazygit ripgrep fzf jq unzip btop fastfetch

    # Wallpaper + screenshots + brightness
    awww grim slurp swappy wl-clipboard cliphist brightnessctl

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
    stow nano vim power-profiles-daemon stylua python-black python-isort
)

# --- AUR packages (installed via yay) ---
AUR_PKGS=(
    google-chrome
    bun-bin
    catppuccin-gtk-theme-mocha
    bibata-cursor-theme
    ttf-ms-fonts
    sddm-git
    sddm-sugar-candy-git
    swayosd-git
    adwaita-dark
    prettierd
)

# --- Install pacman packages ---
green "==> Installing pacman packages..."
sudo pacman -Syu --needed --noconfirm "${PACMAN_PKGS[@]}"

# --- Install yay if not present ---
if ! command -v yay &>/dev/null; then
    yellow "==> Installing yay (AUR helper)..."
    rm -rf /tmp/yay-install
    git clone https://aur.archlinux.org/yay.git /tmp/yay-install
    ( cd /tmp/yay-install && makepkg -si --noconfirm )
    rm -rf /tmp/yay-install
fi

# --- Install AUR packages ---
green "==> Installing AUR packages..."
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# --- Back up conflicting files before stow ---
# archinstall's hyprland profile pre-creates ~/.config/hypr, ~/.config/waybar
# etc. Stow will refuse to overwrite real files. Move any conflicts aside so
# stow can take over cleanly.
green "==> Backing up conflicting files to $BACKUP_DIR ..."
mkdir -p "$BACKUP_DIR"
backup_if_real_file() {
    local rel="$1"
    local src="$HOME/$rel"
    if [ -e "$src" ] && [ ! -L "$src" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        mv "$src" "$BACKUP_DIR/$rel"
        yellow "  moved $rel"
    fi
}

# Walk every tracked file in the repo (excluding sddm/, system/, scripts, docs)
# and back up the matching path in $HOME if it exists as a real file.
while IFS= read -r f; do
    rel="${f#./}"
    case "$rel" in
        sddm/*|system/*|install.sh|README.md|CLAUDE.md|.git/*|.gitignore) continue ;;
    esac
    backup_if_real_file "$rel"
done < <(cd "$DOTFILES" && find . -type f -not -path './.git/*')

# Some directories (e.g. .config/hypr) may exist as plain dirs from
# archinstall. Stow handles directories fine; it only chokes on real files.

# --- Symlink dotfiles with stow ---
#
# DANGER NOTE: do NOT use `--restow` here. Stow folds directories whose
# contents are entirely stow-owned (e.g. ~/wallpapers/bank becomes a single
# symlink to $DOTFILES/wallpapers/bank). On a re-run, `--restow` walks the
# package tree by path and unlinks "$HOME/wallpapers/bank/foo.jpg", which
# resolves *through* the folded symlink and deletes the file inside
# $DOTFILES — wiping the source. This script previously did exactly that.
#
# Instead: pre-clean any existing symlinks in $HOME that point into
# $DOTFILES, then stow fresh with --no-folding so re-runs are always safe.
green "==> Pre-cleaning previous stow symlinks..."
DOTFILES_REAL="$(readlink -f "$DOTFILES")"
# Remove any symlink under $HOME that resolves into $DOTFILES. -xdev keeps
# us on the home filesystem; -depth ensures children are removed before
# their (possibly folded) parent symlinks.
find "$HOME" -xdev -depth -lname '*' 2>/dev/null | while IFS= read -r link; do
    target="$(readlink -f "$link" 2>/dev/null || true)"
    case "$target" in
        "$DOTFILES_REAL"|"$DOTFILES_REAL"/*) rm -f "$link" ;;
    esac
done

green "==> Linking dotfiles with stow (no folding)..."
cd "$DOTFILES"
stow -v --no-folding \
    --ignore='^install\.sh$' \
    --ignore='^README\.md$' \
    --ignore='^CLAUDE\.md$' \
    --ignore='^sddm$' \
    --ignore='^system$' \
    --target="$HOME" .

# --- Set zsh as default shell ---
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    yellow "==> Setting zsh as default shell..."
    sudo chsh -s "$(command -v zsh)" "$USER"
fi

# --- Enable services ---
green "==> Enabling system services..."
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now docker.service
sudo systemctl enable --now cups.service
sudo systemctl enable --now power-profiles-daemon.service
sudo systemctl enable sddm.service

# Enable hyprpolkitagent as a user service (replaces the broken
# /usr/lib/polkit-gnome/... exec-once that pointed at a missing binary).
systemctl --user enable hyprpolkitagent.service 2>/dev/null || true

# Add user to docker group so docker works without sudo.
if ! id -nG "$USER" | grep -qw docker; then
    sudo usermod -aG docker "$USER"
    yellow "  added $USER to docker group (re-login required)"
fi

# --- Configure SDDM theme ---
green "==> Configuring SDDM (sugar-candy)..."
sudo mkdir -p /etc/sddm.conf.d /usr/share/sddm/themes/sugar-candy/Backgrounds
echo -e "[Theme]\nCurrent=sugar-candy" | sudo tee /etc/sddm.conf.d/theme.conf > /dev/null
sudo cp "$DOTFILES/sddm/sugar-candy-theme.conf" /usr/share/sddm/themes/sugar-candy/theme.conf
if [ -f "$DOTFILES/sddm/Clock.qml" ]; then
    sudo cp "$DOTFILES/sddm/Clock.qml" /usr/share/sddm/themes/sugar-candy/Components/Clock.qml
fi

# --- Wallpapers ---
mkdir -p "$HOME/wallpapers/bank"
if [ ! -f "$HOME/wallpapers/current.jpg" ]; then
    # Pick the preferred default if it's there, otherwise any image, otherwise skip.
    if [ -f "$HOME/wallpapers/bank/wallhaven-g83d8d.jpg" ]; then
        cp "$HOME/wallpapers/bank/wallhaven-g83d8d.jpg" "$HOME/wallpapers/current.jpg"
    else
        first_img="$(find "$HOME/wallpapers/bank" -type f \( -name '*.jpg' -o -name '*.png' \) 2>/dev/null | head -1 || true)"
        [ -n "$first_img" ] && cp "$first_img" "$HOME/wallpapers/current.jpg"
    fi
fi
if [ -f "$HOME/wallpapers/current.jpg" ]; then
    sudo cp "$HOME/wallpapers/current.jpg" /usr/share/sddm/themes/sugar-candy/Backgrounds/wallpaper.jpg
else
    yellow "  no wallpapers found in ~/wallpapers/bank — skipping initial wallpaper"
fi

# Allow wallpaper-cycle.sh to update SDDM wallpaper without password.
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/cp * /usr/share/sddm/themes/sugar-candy/Backgrounds/wallpaper.jpg" \
    | sudo tee /etc/sudoers.d/wallpaper > /dev/null
sudo chmod 440 /etc/sudoers.d/wallpaper

# --- System reliability: hardware watchdog + kernel panic auto-reboot ---
# Fixes the "system glitches and I have to pull the power cable" failure
# mode by force-rebooting on hangs and kernel oopses.
green "==> Installing system reliability config (watchdog + panic auto-reboot)..."
sudo mkdir -p /etc/systemd/system.conf.d /etc/sysctl.d
sudo cp "$DOTFILES/system/etc/systemd/system.conf.d/00-watchdog.conf" \
    /etc/systemd/system.conf.d/00-watchdog.conf
sudo cp "$DOTFILES/system/etc/sysctl.d/99-panic-reboot.conf" \
    /etc/sysctl.d/99-panic-reboot.conf
sudo systemctl daemon-reexec || true
sudo sysctl --system >/dev/null

# --- Make scripts executable ---
[ -d "$HOME/.config/hypr" ] && find "$HOME/.config/hypr" -maxdepth 1 -name '*.sh' -exec chmod +x {} +
[ -d "$HOME/.local/bin" ] && find "$HOME/.local/bin" -maxdepth 1 -type f -exec chmod +x {} +

green "==> Done!"
green "    Backups (if any) are in: $BACKUP_DIR"
green "    Reboot and select Hyprland in SDDM."
