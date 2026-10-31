# dotfiles

macOS-Setup von Arne: zsh, Git, Ghostty, Zed, Claude-Code-Subagents und ein paar eigene Skripte.

## Neuer Rechner (mit Claude Code)

Claude Code installieren (`curl -fsSL https://claude.ai/install.sh | bash`), einloggen, dann:

> Hol meine Dotfiles von github.com/wiesson/dotfiles nach ~/Dev/dotfiles und richte den Rechner nach der CLAUDE.md im Repo ein.

Der komplette Ablauf für den Agenten steht in [`CLAUDE.md`](CLAUDE.md) (für Codex & Co. als `AGENTS.md`).

## Neuer Rechner (von Hand)

```sh
# 1. Homebrew: https://brew.sh
git clone https://github.com/wiesson/dotfiles.git ~/Dev/dotfiles
cd ~/Dev/dotfiles
DRY_RUN=1 ./install.sh   # erst anschauen
./install.sh --brew      # verlinken + Brewfile installieren
```

`install.sh` legt Symlinks von `$HOME` ins Repo an. Was vorher dort lag, landet in
`~/.dotfiles-backup/<zeitstempel>/`. Mehrfaches Ausführen ist unschädlich.

## Inhalt

| Repo | Ziel |
| --- | --- |
| `zsh/zshrc`, `zshenv`, `zprofile`, `profile` | `~/.zshrc` usw. |
| `git/gitconfig`, `git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `zed/settings.json` | `~/.config/zed/settings.json` |
| `claude/agents/*.md` | `~/.claude/agents/` (Subagents `fable-deep`, `sonnet-impl`, `haiku-scout`) |
| `bin/*` | `~/.local/bin/` |
| `Brewfile` | `brew bundle` |

`claude/skill-lock.json` ist nur ein Verzeichnis der global installierten Agent-Skills
(Quelle je Skill), keine Installation. Neu installieren mit `npx skills add <quelle>`.

## Privates bleibt draußen

Dieses Repo ist öffentlich. Nicht hier, sondern lokal oder in einem privaten Repo:

- `~/.zsh_private` bzw. `~/.zshrc.local` – Secrets, rechnerspezifische Aliase (wird von `.zshrc` geladen, falls vorhanden)
- `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, `~/.claude.json` (MCP-Server)
- `~/.ssh`, `~/.codex`, `~/.fx`, Kundenskripte
- Tokens liegen in der macOS-Keychain (`cf-env`, `cf-api`, `*-mcp-headers` lesen sie dort)

Liegt ein privates Repo unter `~/.dotfiles-private` (oder `$DOTFILES_PRIVATE`) mit
ausführbarem `install.sh`, ruft `install.sh` es am Ende auf.

## Außerhalb von Homebrew

- Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`
- Vite+ (`vp`, Node): https://viteplus.dev – danach `dev-update`
- Deno, Bun, Grok, fx, Codex: jeweils eigener Installer
- `transcribe` braucht `uv tool install parakeet-mlx` (Whisper-Modell optional unter `~/.local/share/whisper-cpp/`)
