#!/usr/bin/env bash
# Verlinkt die Dotfiles nach $HOME. Idempotent; vorhandene Dateien werden nach
# ~/.dotfiles-backup/<zeitstempel>/ verschoben, nie gelöscht.
#   ./install.sh            nur verlinken
#   ./install.sh --brew     zusätzlich `brew bundle` ausführen
#   DRY_RUN=1 ./install.sh  nur anzeigen
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

backup() { # <pfad> -> $BACKUP/<pfad relativ zu $HOME>
  local rel="${1#"$HOME"/}"
  echo "backup  $1 -> $BACKUP/$rel"
  run mkdir -p "$(dirname "$BACKUP/$rel")"
  run mv "$1" "$BACKUP/$rel"
}

run() { if [ -n "${DRY_RUN:-}" ]; then echo "  [dry] $*"; else "$@"; fi; }

link() { # <quelle im repo> <ziel>
  local src="$DOTFILES/$1" dst="$2"
  [ -e "$src" ] || { echo "fehlt im Repo: $1" >&2; return 1; }
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok      $dst"; return
  fi
  [ -e "$dst" ] || [ -L "$dst" ] && backup "$dst"
  [ -d "$(dirname "$dst")" ] || run mkdir -p "$(dirname "$dst")"
  echo "link    $dst -> $src"
  run ln -s "$src" "$dst"
}

# Shell
link zsh/zshrc    "$HOME/.zshrc"
link zsh/zshenv   "$HOME/.zshenv"
link zsh/zprofile "$HOME/.zprofile"
link zsh/profile  "$HOME/.profile"

# Git
link git/gitconfig "$HOME/.gitconfig"
link git/ignore    "$HOME/.config/git/ignore"

# Apps
link ghostty/config   "$HOME/.config/ghostty/config"
link zed/settings.json "$HOME/.config/zed/settings.json"
# Ghostty liest die macOS-Datei zusätzlich und mit Vorrang -> aus dem Weg räumen.
GHOSTTY_MAC="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
if [ -f "$GHOSTTY_MAC" ] && [ ! -L "$GHOSTTY_MAC" ]; then
  backup "$GHOSTTY_MAC"
fi

# Claude Code Subagents
for f in "$DOTFILES"/claude/agents/*.md; do
  link "claude/agents/$(basename "$f")" "$HOME/.claude/agents/$(basename "$f")"
done

# Eigene Skripte
for f in "$DOTFILES"/bin/*; do
  link "bin/$(basename "$f")" "$HOME/.local/bin/$(basename "$f")"
done

# Optionaler privater Teil: Repo dotfiles-private neben diesem oder ~/.dotfiles-private
PRIVATE="${DOTFILES_PRIVATE:-}"
for cand in "$DOTFILES/../dotfiles-private" "$HOME/.dotfiles-private"; do
  [ -z "$PRIVATE" ] && [ -x "$cand/install.sh" ] && PRIVATE="$(cd "$cand" && pwd)"
done
if [ -n "$PRIVATE" ]; then
  echo "== privat: $PRIVATE"
  BACKUP="$BACKUP" DRY_RUN="${DRY_RUN:-}" "$PRIVATE/install.sh"
else
  echo "== privat: nicht gefunden (optional)"
fi

if [ "${1:-}" = "--brew" ]; then
  command -v brew >/dev/null || { echo "Homebrew fehlt: https://brew.sh" >&2; exit 1; }
  run brew bundle --file "$DOTFILES/Brewfile"
fi

echo "fertig."
