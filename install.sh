#!/usr/bin/env bash
# Richtet das Terminal ein: Homebrew-Pakete aus dem Brewfile, dann Symlinks nach $HOME.
# Idempotent. Vorhandene Dateien wandern nach ~/.dotfiles-backup/<zeitstempel>/, nichts wird gelöscht.
#   ./install.sh            alles
#   ./install.sh --no-brew  nur verlinken
#   DRY_RUN=1 ./install.sh  nur anzeigen
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

run() { if [ -n "${DRY_RUN:-}" ]; then echo "  [dry] $*"; else "$@"; fi; }

backup() { # <pfad> -> $BACKUP/<pfad relativ zu $HOME>
  local rel="${1#"$HOME"/}"
  echo "backup  $1 -> $BACKUP/$rel"
  run mkdir -p "$(dirname "$BACKUP/$rel")"
  run mv "$1" "$BACKUP/$rel"
}

link() { # <quelle im repo> <ziel>
  local src="$DOTFILES/$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then echo "ok      $dst"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then backup "$dst"; fi
  [ -d "$(dirname "$dst")" ] || run mkdir -p "$(dirname "$dst")"
  echo "link    $dst -> $src"
  run ln -s "$src" "$dst"
}

# Pakete
if [ "${1:-}" != "--no-brew" ]; then
  if ! command -v brew >/dev/null; then
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && eval "$("$b" shellenv)"; done
  fi
  command -v brew >/dev/null || { echo "Homebrew fehlt – erst https://brew.sh installieren." >&2; exit 1; }
  run brew bundle --file "$DOTFILES/Brewfile"
fi

# Shell
link zsh/zshrc    "$HOME/.zshrc"
link zsh/zshenv   "$HOME/.zshenv"
link zsh/zprofile "$HOME/.zprofile"
link zsh/profile  "$HOME/.profile"

# Git
link git/gitconfig "$HOME/.gitconfig"
link git/ignore    "$HOME/.config/git/ignore"

# Ghostty (die macOS-Datei hätte Vorrang -> aus dem Weg räumen)
link ghostty/config "$HOME/.config/ghostty/config"
GHOSTTY_MAC="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
if [ -f "$GHOSTTY_MAC" ] && [ ! -L "$GHOSTTY_MAC" ]; then backup "$GHOSTTY_MAC"; fi

echo "fertig – neues Terminal-Fenster öffnen."
