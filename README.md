# Dotfiles

Arch Linux + Hyprland rice with Catppuccin Mocha theme. One script to go from a fresh Arch install to a fully configured desktop.


## What's Included

| Component | Tool | Config |
|---|---|---|
| Window Manager | Hyprland | `.config/hypr/hyprland.conf` |
| Status Bar | Waybar | `.config/waybar/` |
| Terminal | Kitty | `.config/kitty/kitty.conf` |
| Shell | Zsh + Starship | `.zshrc`, `.config/starship.toml` |
| Editor | Neovim (Lazy) | `.config/nvim/` |
| Launcher | Wofi | `.config/wofi/` |
| Notifications | SwayNC | `.config/swaync/` |
| Lock Screen | Hyprlock | `.config/hypr/hyprlock.conf` |
| Idle Daemon | Hypridle | `.config/hypr/hypridle.conf` |
| Login Manager | SDDM (Catppuccin) | `sddm/` |
| Multiplexer | Tmux | `.tmux.conf` |
| Fetch | Fastfetch | `.config/fastfetch/config.jsonc` |
| Wallpapers | awww | `.config/hypr/wallpapers/` |

### Keybindings (highlights)

| Key | Action |
|---|---|
| `Super + Q` | Open terminal |
| `Super + W` | Cycle wallpaper |
| `Super + ESC` | Lock screen |
| `Super + C` | Close window |
| `Super + E` | File manager |
| `Super + R` | App launcher |

### Scripts

| Script | Location | Description |
|---|---|---|
| `wallpaper.sh` | `.config/hypr/` | Sets a random wallpaper on login |
| `wallpaper-cycle.sh` | `.config/hypr/` | Cycles to a random wallpaper on demand |
| `powermenu` | `.local/bin/` | Power menu (shutdown, reboot, suspend) |
| `bluetoothmenu` | `.local/bin/` | Bluetooth device picker |

## Installation

### Prerequisites

- A fresh [Arch Linux](https://wiki.archlinux.org/title/Installation_guide) installation with a user account and `sudo` access
- Internet connection
- Git installed (`pacman -S git`)

### Steps

**1. Clone the repo**

```bash
git clone git@github.com:Leonardo-Flores/dotfiles.git ~/dotfiles
```

**2. Run the install script**

```bash
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

This will:
- Install all packages from the official repos and AUR (via yay)
- Symlink all config files into `~` using [GNU Stow](https://www.gnu.org/software/stow/)
- Set Zsh as the default shell
- Enable system services (NetworkManager, Bluetooth, Docker, CUPS, SDDM)
- Configure the SDDM login screen with the Catppuccin theme and wallpaper

**3. Reboot**

```bash
reboot
```

Select **Hyprland** in the SDDM session picker and log in.

## Syncing Between Machines

All config files are symlinked via Stow, so edits go directly into the repo.

**Push changes (from any machine):**

```bash
cd ~/dotfiles
git add -A
git commit -m "description of changes"
git push
```

**Pull changes (on another machine):**

```bash
cd ~/dotfiles
git pull
```

Since configs are symlinks, pulled changes take effect immediately. No need to re-run stow or copy files.

> **Note:** SDDM theme files live in `/usr/share/` and are not symlinked. If you update `sddm/catppuccin-theme.conf`, re-run the SDDM section of `install.sh` or manually copy the file:
> ```bash
> sudo cp ~/dotfiles/sddm/catppuccin-theme.conf /usr/share/sddm/themes/catppuccin/theme.conf
> ```

## Structure

```
~/dotfiles/
├── .config/
│   ├── fastfetch/        # System fetch tool
│   ├── hypr/             # Hyprland, hyprlock, hypridle, wallpapers
│   ├── kitty/            # Terminal emulator
│   ├── nvim/             # Neovim with Lazy plugin manager
│   ├── starship.toml     # Shell prompt
│   ├── swaync/           # Notification center
│   ├── waybar/           # Status bar
│   └── wofi/             # App launcher
├── .local/bin/           # Custom scripts (powermenu, bluetoothmenu)
├── sddm/                 # SDDM theme config (copied, not symlinked)
├── .gitconfig
├── .tmux.conf
├── .zshrc
├── install.sh
└── README.md
```
