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

`install.sh` installiert die Pakete aus dem `Brewfile` (Ghostty, eza, fzf, zoxide,
zsh-Plugins, gh) und verlinkt:

| Repo | Ziel |
| --- | --- |
| `zsh/zshrc`, `zshenv`, `zprofile`, `profile` | `~/.zshrc` usw. |
| `git/gitconfig`, `git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` |
| `ghostty/config` | `~/.config/ghostty/config` |

Was vorher dort lag, landet in `~/.dotfiles-backup/<zeitstempel>/`. Mehrfaches Ausführen
ist unschädlich. `DRY_RUN=1 ./install.sh` zeigt nur an, `--no-brew` überspringt die Pakete.

Rechnerspezifisches gehört in `~/.zshrc.local` (wird geladen, falls vorhanden, und ist nicht im Repo).
