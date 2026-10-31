# dotfiles

Mein Terminal-Setup für macOS: zsh, Git, Ghostty.

## Neuer Rechner

In Claude Code eingeben:

```
Richte mein Terminal mit meinen Dotfiles ein: Klone https://github.com/wiesson/dotfiles nach ~/Dev/dotfiles und führe dort ./install.sh aus. Fehlen die Xcode Command Line Tools oder Homebrew, gib mir den offiziellen Installationsbefehl als Zeile mit !-Präfix zum Ausführen und mach danach weiter. Sag mir am Ende kurz, ob alles geklappt hat.
```

Danach ein neues Terminal-Fenster öffnen.

Von Hand: Homebrew installieren (https://brew.sh), dann

```sh
git clone https://github.com/wiesson/dotfiles.git ~/Dev/dotfiles
~/Dev/dotfiles/install.sh
```

## Was passiert

`install.sh` erledigt in dieser Reihenfolge:

1. **Homebrew-Pakete** aus dem `Brewfile`: Ghostty, eza, fzf, zoxide, zsh-Plugins, gh, git-lfs,
   delta und die Werkzeuge, die Coding-Agenten ständig nutzen (ripgrep, fd, jq, ast-grep, uv).
2. **Node über Vite+** (`vp`, https://viteplus.dev), Default auf die aktuelle LTS.
3. **Globale CLIs** aus `npm-globals.txt` über `vp install -g`: agent-browser (inkl. Chrome
   for Testing), portless, skills, Codex.
4. **Claude Code**, falls es noch fehlt.
5. **Symlinks:**

| Repo | Ziel |
| --- | --- |
| `zsh/zshrc`, `zshenv`, `zprofile`, `profile` | `~/.zshrc` usw. |
| `git/gitconfig`, `git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` |
| `ghostty/config` | `~/.config/ghostty/config` |

Was vorher dort lag, landet in `~/.dotfiles-backup/<zeitstempel>/`. Mehrfaches Ausführen
ist unschädlich. `DRY_RUN=1 ./install.sh` zeigt nur an, `--no-brew` überspringt Schritt 1–4.

Die Git-Config setzt moderne Defaults, die zu Agenten-Workflows mit vielen Branches passen:
`push.autoSetupRemote`, `fetch.prune`, `rebase.autoStash`, `rerere`, `zdiff3`-Konflikte,
Histogram-Diffs und delta als Pager.

Später aktuell halten: `vp upgrade && vp env default lts && vp update -g && brew upgrade`.

Rechnerspezifisches gehört in `~/.zshrc.local` (wird geladen, falls vorhanden, und ist nicht im Repo).
