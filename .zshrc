# Colors
autoload -U colors && colors

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Plugins (guard against missing files before install.sh)
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Starship prompt
eval "$(starship init zsh)"

# Secrets (API keys — not tracked by git)
[ -f ~/.secrets ] && source ~/.secrets

# Path
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR=nvim

# FZF integration
eval "$(fzf --zsh 2>/dev/null)"

# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# Auto-attach to tmux (skip in nested tmux or non-interactive shells)
if command -v tmux &>/dev/null && [ -z "$TMUX" ] && [[ $- == *i* ]]; then
    tmux attach-session -t default 2>/dev/null || tmux new-session -s default
fi

fastfetch
