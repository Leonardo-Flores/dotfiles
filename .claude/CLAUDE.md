# Preferências globais (Leonardo)

Responda em **pt-BR**. Vá direto ao ponto; sem preâmbulo nem resumo do que eu já sei.

## Roteamento de modelos

A sessão principal roda no **Fable 5** e é onde eu quero conversar, planejar e decidir. O Fable é caro em cota, então o trabalho braçal vai pra agents do plugin `berzerk-core`:

| Situação | Quem faz |
|---|---|
| Planejar, discutir abordagem, decidir arquitetura, conversar comigo | **Fable (sessão principal)** |
| "Onde/como isso funciona hoje", mapear código, achar arquivos, ler muita coisa | agent **`scout`** (haiku) |
| Implementar algo já decidido e bem especificado (spec com arquivos, comportamento, critérios) | agent **`implementer`** (sonnet) — mande a spec completa de uma vez |
| Revisar diff antes de PR / depois do implementer | agent **`reviewer`** (opus) |
| **Bug crítico ou difícil**, debug cabeludo, mudança delicada em produção, coisa que errar custa caro | **Fable direto**, sem delegar |

Regras práticas:
- Tarefa trivial (1 arquivo, poucas linhas) → faz direto, não vale spawnar agent.
- Não use ultracode/workflows por conta própria; só se eu pedir.
- Antes de qualquer coisa num repo, leia o `CLAUDE.md` dele e o do diretório pai.
- Antes de tarefa com > 1 arquivo, apresente o plano em poucas linhas e espere meu ok (ou use plan mode).

## Higiene de contexto (cota)

- Não cole output gigante: `| head`, `| grep`, `--stat`. Um arquivo grande lido inteiro é reenviado em todo turno seguinte.
- Prefira `scout` a ler 10 arquivos você mesmo.
- Se a sessão passou de ~60% de contexto e a tarefa mudou, me sugira `/clear` ou `/compact`.

## Berzerk

Contas AWS: `713863945908` = Berzerk (profile `default`); `374…` = pessoal (profile `pessoal`). Nunca misturar. Detalhes no skill `aws-berzerk`. Commits/PRs: skill `pr`.

## Ambiente

Arch + Hyprland no notebook; devbox EC2 (Ubuntu arm64, `box up/ssh/attach`) roda o mesmo terminal — skill `devbox`. Dotfiles em `~/dotfiles` via stow (inclui `~/.claude/settings.json`, este arquivo e `~/.claude/skills`).
