# Habilita cores
 autoload -U colors && colors

# Histórico
 HISTSIZE=10000
 SAVEHIST=10000
 HISTFILE=~/.zsh_history
 setopt APPEND_HISTORY
 setopt SHARE_HISTORY
 setopt HIST_IGNORE_DUPS

# Plugins
 source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
 source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Starship prompt
 eval "$(starship init zsh)"

# Secrets (API keys — not tracked by git)
 [ -f ~/.secrets ] && source ~/.secrets

# Path
 export PATH=/home/leonardoflores/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl

# Editor
 export EDITOR=nvim

# Zoxide (smarter cd)
 eval "$(zoxide init zsh)"

# Dotfiles management (bare git repo)
 dotfiles() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }

 fastfetch
