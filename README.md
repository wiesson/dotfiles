# dotfiles

Mein Terminal-Setup für macOS: zsh, Git, Ghostty.

## Neuer Rechner

In Claude Code eingeben:

```
Richte mein Terminal mit meinen Dotfiles ein: Klone https://github.com/wiesson/dotfiles nach ~/Dev/dotfiles und führe dort ./install.sh aus. Fehlen die Xcode Command Line Tools oder Homebrew, gib mir den offiziellen Installationsbefehl als Zeile mit !-Präfix zum Ausführen und mach danach weiter. Listet install.sh am Ende Befehle unter „Noch von Hand ausführen", gib mir jeden als !-Zeile. Sag mir am Ende kurz, ob alles geklappt hat.
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
   delta, OrbStack und die Werkzeuge, die Coding-Agenten ständig nutzen (ripgrep, fd, jq,
   ast-grep, uv).
2. **Node über Vite+** (`vp`, https://viteplus.dev), Default auf die aktuelle LTS.
3. **Globale CLIs** aus `npm-globals.txt` über `vp install -g`: agent-browser (inkl. Chrome
   for Testing), portless, skills, emulate, Codex.
4. **Agent-Skills** aus `skills.txt` über die skills-CLI, global für Claude Code, Codex,
   Cursor, OpenCode und Zed (Cloudflare, Stripe, shadcn, agent-browser, portless, …).
   Neuer Skill: Zeile in `skills.txt` ergänzen.
5. **Claude Code**, falls es noch fehlt.
6. **Symlinks:**

| Repo | Ziel |
| --- | --- |
| `zsh/zshrc`, `zshenv`, `zprofile`, `profile` | `~/.zshrc` usw. |
| `git/gitconfig`, `git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `bin/dev-update` | `~/.local/bin/dev-update` |

7. **macOS:** schnelle Tastenwiederholung, kein Akzent-Popup beim Gedrückthalten (`macos/defaults.sh`).
8. **`gh auth setup-git`**, damit `git push` über HTTPS den gh-Login nutzt.
9. **Touch ID für `sudo`** (`macos/touchid-sudo.sh`). Braucht einmal das Passwort; ohne
   Terminal-Eingabe (z. B. im Agenten) steht es am Ende unter „Noch von Hand ausführen", ebenso
   ein fehlender `gh auth login`.

Was vorher dort lag, landet in `~/.dotfiles-backup/<zeitstempel>/`. Mehrfaches Ausführen
ist unschädlich. `DRY_RUN=1 ./install.sh` zeigt nur an, `--no-brew` überspringt Schritt 1–5.

Die Git-Config setzt moderne Defaults, die zu Agenten-Workflows mit vielen Branches passen:
`push.autoSetupRemote`, `fetch.prune`, `rebase.autoStash`, `rerere`, `zdiff3`-Konflikte,
Histogram-Diffs und delta als Pager.

Später aktuell halten: `dev-update` (Homebrew, Vite+, Node LTS, globale CLIs, Skills, Claude Code).
`dev-update --check` zeigt nur an, was veraltet ist.

Rechnerspezifisches gehört in `~/.zshrc.local` (wird geladen, falls vorhanden, und ist nicht im Repo).
Ebenso die Git-Identität: Name und E-Mail stehen in `~/.gitconfig.local`, damit mehrere Leute
dieselben Dotfiles nutzen können. Fehlt sie, nennt `install.sh` am Ende den Befehl dafür.
