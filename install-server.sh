#!/usr/bin/env bash
# Instala SÓ o ambiente de terminal (zsh, tmux, nvim, starship, ferramentas de
# dev) numa máquina Ubuntu 24.04 (arm64 ou x86_64) — a devbox EC2, ou qualquer
# VPS/WSL Ubuntu. Não toca em Hyprland/waybar/etc. Idempotente: pode rodar
# de novo pra atualizar o que vem de GitHub release.
#
# Pra Arch (notebook) continue usando ./install.sh.
set -euo pipefail

green()  { printf '\033[1;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[1;33m%s\033[0m\n' "$*"; }

ARCH=$(uname -m)
case "$ARCH" in
  aarch64) GH_ARCH=arm64;  AWS_ARCH=aarch64; NVIM_ARCH=arm64; FZF_ARCH=arm64;  LG_ARCH=arm64;  ZX_ARCH=aarch64 ;;
  x86_64)  GH_ARCH=amd64;  AWS_ARCH=x86_64;  NVIM_ARCH=x86_64; FZF_ARCH=amd64; LG_ARCH=x86_64; ZX_ARCH=x86_64 ;;
  *) echo "arch não suportada: $ARCH"; exit 1 ;;
esac

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DEBIAN_FRONTEND=noninteractive
mkdir -p ~/.local/bin

gh_latest_tag() { curl -fsSL "https://api.github.com/repos/$1/releases/latest" | jq -r .tag_name; }

# --- apt -----------------------------------------------------------------------
green "==> apt: base + shell"
sudo apt-get update -qq
sudo apt-get install -y -qq --no-install-recommends \
  zsh zsh-autosuggestions zsh-syntax-highlighting tmux git stow curl wget \
  ca-certificates gnupg unzip jq ripgrep fd-find bat btop htop mosh \
  build-essential python3 python3-pip python3-venv pipx \
  fontconfig xclip
# nomes diferentes no Debian/Ubuntu
[ -e ~/.local/bin/fd ]  || ln -sf "$(command -v fdfind)" ~/.local/bin/fd
[ -e ~/.local/bin/bat ] || ln -sf "$(command -v batcat)" ~/.local/bin/bat

# --- repos de terceiros (gh, terraform, docker, node) --------------------------
green "==> apt: repos de terceiros"
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  echo "deb [arch=$GH_ARCH signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
fi
if [ ! -f /etc/apt/keyrings/hashicorp.gpg ]; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg
  echo "deb [arch=$GH_ARCH signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
fi
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc >/dev/null
  echo "deb [arch=$GH_ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
fi
if [ ! -f /etc/apt/keyrings/nodesource.gpg ]; then
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  echo "deb [arch=$GH_ARCH signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list >/dev/null
fi
sudo apt-get update -qq
sudo apt-get install -y -qq gh terraform nodejs \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER" || true
sudo systemctl enable --now docker || true

# --- binários de GitHub release (versões do apt são velhas demais) --------------
green "==> neovim (release oficial)"
NVIM_TAG=$(gh_latest_tag neovim/neovim)
if [ "$(nvim --version 2>/dev/null | head -1 | awk '{print $2}')" != "$NVIM_TAG" ]; then
  curl -fsSL "https://github.com/neovim/neovim/releases/download/$NVIM_TAG/nvim-linux-$NVIM_ARCH.tar.gz" -o /tmp/nvim.tgz
  sudo rm -rf /opt/nvim && sudo mkdir -p /opt/nvim && sudo tar -xzf /tmp/nvim.tgz -C /opt/nvim --strip-components=1
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
fi

green "==> fzf (precisa >= 0.48 pelo 'fzf --zsh')"
FZF_TAG=$(gh_latest_tag junegunn/fzf); FZF_VER=${FZF_TAG#v}
if [ "$(fzf --version 2>/dev/null | awk '{print $1}')" != "$FZF_VER" ]; then
  curl -fsSL "https://github.com/junegunn/fzf/releases/download/$FZF_TAG/fzf-$FZF_VER-linux_$FZF_ARCH.tar.gz" | tar -xz -C ~/.local/bin fzf
fi

green "==> lazygit"
LG_TAG=$(gh_latest_tag jesseduffield/lazygit); LG_VER=${LG_TAG#v}
curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/$LG_TAG/lazygit_${LG_VER}_Linux_${LG_ARCH}.tar.gz" | tar -xz -C ~/.local/bin lazygit

green "==> fastfetch"
FF_TAG=$(gh_latest_tag fastfetch-cli/fastfetch)
curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/download/$FF_TAG/fastfetch-linux-$( [ "$ARCH" = aarch64 ] && echo aarch64 || echo amd64 ).deb" -o /tmp/fastfetch.deb
sudo apt-get install -y -qq /tmp/fastfetch.deb

green "==> starship + zoxide"
curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin >/dev/null
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir ~/.local/bin >/dev/null

green "==> stylua / prettierd / black / isort (formatters do nvim)"
ST_TAG=$(gh_latest_tag JohnnyMorganz/StyLua)
curl -fsSL "https://github.com/JohnnyMorganz/StyLua/releases/download/$ST_TAG/stylua-linux-$( [ "$ARCH" = aarch64 ] && echo aarch64 || echo x86_64 ).zip" -o /tmp/stylua.zip
unzip -q -o /tmp/stylua.zip -d ~/.local/bin && chmod +x ~/.local/bin/stylua
for pkg in black isort; do pipx install --force "$pkg" >/dev/null 2>&1 || true; done

# --- node tooling ----------------------------------------------------------------
green "==> pnpm, prettierd, bun"
sudo npm install -g pnpm @fsouza/prettierd >/dev/null
command -v bun >/dev/null || curl -fsSL https://bun.sh/install | bash >/dev/null

# --- AWS -------------------------------------------------------------------------
green "==> aws cli v2 + session-manager-plugin"
if ! command -v aws >/dev/null; then
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$AWS_ARCH.zip" -o /tmp/awscliv2.zip
  unzip -q -o /tmp/awscliv2.zip -d /tmp && sudo /tmp/aws/install --update && rm -rf /tmp/aws /tmp/awscliv2.zip
fi
if ! command -v session-manager-plugin >/dev/null; then
  curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_$( [ "$ARCH" = aarch64 ] && echo arm64 || echo 64bit )/session-manager-plugin.deb" -o /tmp/smp.deb
  sudo apt-get install -y -qq /tmp/smp.deb
fi

# --- Claude Code -----------------------------------------------------------------
green "==> claude code"
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash

# --- dotfiles ----------------------------------------------------------------------
green "==> stow (só a parte de terminal)"
sudo chsh -s "$(command -v zsh)" "$USER" || true
cd "$DOTFILES"
# Diretórios-alvo precisam existir ANTES do stow, senão ele "dobra" ~/.config
# inteiro num symlink pro repo (ignora os --ignore e faz qualquer arquivo novo
# em ~/.config — tokens do gh, gcloud — cair dentro do repo git).
mkdir -p ~/.config ~/.ssh ~/.local/bin ~/.local/share ~/.claude
chmod 700 ~/.ssh
# .zshrc/.bashrc padrão do Ubuntu atrapalham o stow
for f in .zshrc .bashrc .profile; do [ -f ~/$f ] && [ ! -L ~/$f ] && mv ~/$f ~/$f.pre-stow; done
stow -v --target="$HOME" \
  --ignore='sddm' --ignore='install.*\.sh' --ignore='wallpapers' --ignore='system' \
  --ignore='hypr' --ignore='waybar' --ignore='wofi' --ignore='swaync' --ignore='fuzzel' --ignore='kitty' \
  --ignore='^/?CLAUDE\.md$' --ignore='^/?README\.md$' .

# ssh-agent via systemd --user (o .zshrc aponta SSH_AUTH_SOCK pra ele).
# Sob sudo -u / cloud-init não há sessão: aponta o user manager na mão.
export XDG_RUNTIME_DIR="/run/user/$(id -u)" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
systemctl --user daemon-reload || true
systemctl --user enable --now ssh-agent.service || true

# tmux server sobe no boot (loginctl enable-linger feito pelo user_data) e
# restaura as sessões via tmux-continuum (@continuum-boot só ativa com /etc/devbox)
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone -q https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.tmux/plugins/tpm/bin/install_plugins >/dev/null
fi

green "==> pronto. Próximos passos manuais:"
cat <<'MSG'
  1. Restaurar segredos:  gpg -d migracao.tgz.gpg | tar xzf -   (em ~)
  2. gh auth status / aws sts get-caller-identity / claude (login por URL)
  3. Clonar os repos nos mesmos paths (~/projects, ~/www/github/com/...)
  4. exec zsh   -> cai no tmux 'default'; Ctrl+A Ctrl+R restaura as sessões
MSG
