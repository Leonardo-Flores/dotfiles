---
name: devbox
description: Operar a devbox (EC2 sa-east-1 na conta Berzerk) — ligar, conectar, sincronizar dotfiles/Claude, horário de funcionamento, watchdog. Use quando o usuário falar em "box", "devbox", "ligar a EC2", "rodar na nuvem", ou quando algo precisa rodar fora do notebook.
---

# Devbox

EC2 Ubuntu 24.04 arm64 em `sa-east-1`, conta Berzerk (`713863945908`), tag `Name=berzerk-devbox-prod`, Terraform em `berzerk-infra/stacks/devbox/prod` (PR #150). Roda o mesmo ambiente de terminal do notebook (zsh, tmux, nvim, Claude Code). Marcada por `/etc/devbox`.

## Controle (do notebook) — `~/.local/bin/box`
```
box status            estado + ip + schedules
box up                liga (espera ficar running; SSM ~30 s, tailscale ~10 s)
box down              desliga agora
box ssh | box mosh    conecta via Tailscale (host `devbox`); cai pra SSM (`devbox-ssm`) se a tailnet não responder
box attach [sessão]   mosh + tmux attach (default: `default`)
box id                instance id
```
- Liga sozinha **seg–sex 07:00** (EventBridge Scheduler, grupo `berzerk-devbox-prod`).
- Fora de 07–17 um **watchdog na box desliga 4 h após a última atividade** — à noite/fim de semana basta `box up`, não precisa `box down`.
- `.ssh/config` tem `devbox` (Tailscale) e `devbox-ssm` (via SSM, sem Tailscale). Pendente: login do Tailscale na box.

## Sincronizar ambiente
- Na box: `cd ~/dotfiles && git pull && ./install-server.sh` (apt + releases GitHub + stow só da parte de terminal; **nunca** `install.sh` lá).
- O stow da box inclui `~/.claude/settings.json`, `~/.claude/CLAUDE.md` e `~/.claude/skills` — mesmo modelo/hook/statusline do notebook. `claude-notify` fica mudo lá (sem notify-send).
- Plugin `berzerk-core`: na box rodar `claude plugin marketplace add Berzerk-Tech/claude-plugins` (precisa de `gh auth login` / SSH pro GitHub).

## Não faça
- `terraform apply` no stack da devbox à mão (vai pelo CI do berzerk-infra).
- Deixar `box up` em horário comercial achando que vai desligar — o watchdog só age fora de 07–17.
