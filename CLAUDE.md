# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Arch Linux + Hyprland dotfiles with Catppuccin Mocha theming. All configs are symlinked into `~` via GNU Stow from this repo root. Edits to files here take effect immediately on the live system (no re-stow needed).

## Key Commands

- **Apply dotfiles:** `cd ~/dotfiles && stow -v --ignore='sddm' --ignore='install.sh' --target="$HOME" .`
- **Full install on fresh Arch:** `./install.sh` (installs packages, symlinks, enables services, configures SDDM)
- **Reload Waybar:** `killall waybar && waybar &` or `Super+F` to toggle visibility
- **Reload Hyprland config:** `hyprctl reload`
- **Cycle wallpaper:** `~/.config/hypr/wallpaper-cycle.sh` (updates desktop, lock screen, and SDDM)
- **Update SDDM theme manually:** `sudo cp ~/dotfiles/sddm/sugar-candy-theme.conf /usr/share/sddm/themes/sugar-candy/theme.conf`

## Architecture

### Symlink Strategy (Stow)

The repo root mirrors `$HOME`. Stow creates symlinks so `.config/hypr/hyprland.conf` in this repo becomes `~/.config/hypr/hyprland.conf`. The `sddm/` directory is excluded from stow because SDDM theme files must live in `/usr/share/` and are copied there instead.

### Wallpaper Pipeline

Wallpapers live in `~/wallpapers/bank/` (outside this repo). The cycle script (`wallpaper-cycle.sh`) picks a random image, copies it to `~/wallpapers/current.jpg`, syncs it to the SDDM background (via passwordless sudo rule), and applies it with `awww`. The lock screen (`hyprlock.conf`) also reads `~/wallpapers/current.jpg`, so all three surfaces stay in sync.

### Waybar Custom Modules

Waybar modules invoke scripts in `.local/bin/` for interactive menus:
- `bluetoothmenu` - wofi-based Bluetooth device picker
- `wifimenu` - wofi-based Wi-Fi network selector
- `powermenu` - wofi-based shutdown/reboot/suspend menu

These scripts use `wofi --dmenu` for selection UI. Waybar references them by command name (they're in `$PATH` via `~/.local/bin`).

### Neovim

Uses Lazy.nvim plugin manager. Plugin specs are in `.config/nvim/lua/plugins/` (one file per plugin or group). Core settings and keymaps are in `.config/nvim/lua/config/`. `lazy-lock.json` is gitignored. Catppuccin Mocha is the colorscheme (with transparent background). vim-tmux-navigator enables seamless Ctrl+hjkl navigation between nvim splits and tmux panes.

### Tmux

Prefix is `Ctrl+A`. TPM auto-installs on first launch. Plugins: tmux-resurrect (session save/restore), tmux-continuum (auto-save), tmux-yank (clipboard). Undercurl is enabled for LSP diagnostics. `.zshrc` auto-attaches to a `default` tmux session.

### SDDM

Uses sugar-candy theme. Theme config is at `sddm/sugar-candy-theme.conf` and the QML clock override is `sddm/Clock.qml`. These are copied (not symlinked) to `/usr/share/sddm/themes/sugar-candy/` by the install script.

## Conventions

- **Theme:** Catppuccin Mocha everywhere (GTK, Qt, Waybar, SDDM, Neovim). Key colors: mauve `#cba6f7`, blue `#89b4fa`, text `#cdd6f4`, surface `#585b70`.
- **Keyboard layout:** Brazilian (`br`).
- **Comments:** Mix of English and Portuguese in config files.
- **No window gaps or rounding** - the rice uses `gaps_in = 0`, `gaps_out = 0`, `rounding = 0`.
