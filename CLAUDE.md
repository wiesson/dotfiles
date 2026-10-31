# Rechner einrichten: Anleitung für Claude Code

Du bist ein Coding-Agent (Claude Code, Codex o. ä.) auf einem Mac von Arne Wiese. Arne hat dir
etwa gesagt: „Hol meine Dotfiles und richte den Rechner ein." Diese Datei ist dein Ablauf.
Arbeite ihn selbstständig von oben nach unten ab. Frag Arne nur, wenn ein Schritt seine Hände
braucht (Passwort, Login im Browser, ein Secret). Am Ende berichtest du, was erledigt ist und
was offen bleibt.

## Regeln

- **Nichts löschen.** `install.sh` verschiebt Vorhandenes nach `~/.dotfiles-backup/<zeitstempel>/`.
  Mach es genauso, wenn du selbst etwas ersetzt.
- **Idempotent.** Der Rechner kann schon halb eingerichtet sein. Prüfe vor jedem Schritt, ob er
  nötig ist (`command -v`, `brew bundle check`, `readlink`). Was schon passt, lässt du in Ruhe.
- **Keine Secrets in Dateien oder Repos.** Tokens gehören in die macOS-Keychain. Gib sie nie aus.
- **Interaktives macht Arne.** Befehle mit `sudo`, Passwort-Eingabe oder Browser-Login gibst du
  ihm als fertige Zeile mit `!`-Präfix, z. B. `! gh auth login`. Dann läuft der Befehl in dieser
  Session und du siehst das Ergebnis.
- **Sandbox oder Auto-Mode blockiert?** Schreiben nach `~/.claude/` und das Umbiegen von
  Shell-Dateien wird oft abgelehnt. Nicht umgehen: Arne den Befehl mit `!` zum Ausführen geben.
- **Offizielle Installer.** Für Tools außerhalb von Homebrew holst du den aktuellen
  Installationsbefehl von der offiziellen Website. Rate keine URLs.
- **Benutzername.** Ist `$HOME` nicht `/Users/wiese`, passt du absolute Pfade in
  `dotfiles-private/claude/settings.json`, `fx/settings.json` und den Memory-Dateien an.

## Repos

| Repo | Ort | Inhalt |
| --- | --- | --- |
| `wiesson/dotfiles` (öffentlich) | `~/Dev/dotfiles` | zsh, git, Ghostty, Zed, Claude-Subagents, Skripte, Brewfile |
| `wiesson/dotfiles-private` (privat) | `~/Dev/dotfiles-private` | `~/.claude/CLAUDE.md`, Claude-settings, Auto-Memory, MCP-Vorlage, ssh config, Kundenskripte |

## Ablauf

### 1. Grundlagen

1. Xcode Command Line Tools: `xcode-select -p`. Fehlen sie → `! xcode-select --install`, warten.
2. Homebrew: `command -v brew || ls /opt/homebrew/bin/brew`. Fehlt es → den Installer von
   https://brew.sh als `!`-Zeile an Arne geben (braucht sein Passwort). Danach
   `eval "$(/opt/homebrew/bin/brew shellenv)"` in deiner Shell.
3. `brew install gh` (falls fehlt), dann `gh auth status`. Nicht eingeloggt → `! gh auth login`
   (GitHub.com, HTTPS, Browser).

### 2. Repos holen

```sh
mkdir -p ~/Dev
[ -d ~/Dev/dotfiles ] || gh repo clone wiesson/dotfiles ~/Dev/dotfiles
[ -d ~/Dev/dotfiles-private ] || gh repo clone wiesson/dotfiles-private ~/Dev/dotfiles-private
git -C ~/Dev/dotfiles pull --ff-only; git -C ~/Dev/dotfiles-private pull --ff-only
```

### 3. Verlinken und Pakete

```sh
cd ~/Dev/dotfiles
DRY_RUN=1 ./install.sh     # ansehen, Arne kurz zeigen, was ersetzt wird
./install.sh --brew        # verlinkt öffentlich + privat, installiert das Brewfile
```

Wird `./install.sh` blockiert → `! cd ~/Dev/dotfiles && ./install.sh --brew` an Arne geben.
Schlägt einzelnes in `brew bundle` fehl, weitermachen und im Bericht nennen.

### 4. Tools außerhalb von Homebrew

Jeweils nur, wenn `command -v <tool>` nichts findet:

| Tool | Quelle | Danach |
| --- | --- | --- |
| Vite+ (`vp`, verwaltet Node) | https://viteplus.dev | `dev-update` |
| Claude Code | https://claude.ai/install.sh | läuft vermutlich schon |
| Codex CLI | https://github.com/openai/codex | `! codex login` |
| Bun | https://bun.sh | |
| Deno | https://deno.com | |
| fx | https://fx.sh (Vercel Labs), nach `~/.local/bin/fx` | `fx status` |
| Grok CLI | offizieller xAI-Installer | optional, nachrangig |
| parakeet-mlx | `uv tool install parakeet-mlx` | für `transcribe` |

Global installierte Agent-Skills: `claude/skill-lock.json` listet jeden Skill mit Quell-Repo.
Für jede Quelle `npx skills add <quelle> -g` (die Skills-CLI fragt, welche Skills; nimm genau
die aus der Lock-Datei). Claude-Code-Plugins (`codex@openai-codex`, `frontend-design`) stehen
in `settings.json`; fehlen sie nach einem Neustart von Claude Code, mit `/plugin` installieren.

### 5. Secrets in die Keychain

Die Skripte in `bin/` erwarten diese Einträge (Account `arne`). Fehlt einer
(`security find-generic-password -a arne -s <dienst> >/dev/null`), bittest du Arne, ihn
anzulegen. Der Wert wird interaktiv abgefragt und taucht nicht im Verlauf auf:

```
! security add-generic-password -a arne -s <dienst> -w
```

| Dienst | Wofür | Prüfen mit |
| --- | --- | --- |
| `studio-nordwerk-cloudflare-agent` | `cf-env`, `cf-api`, MCP `cloudflare-api` | `cf-doctor --quick` |
| `studio-nordwerk-stripe-agent` | MCP `stripe` | `stripe-doctor` |
| `firecrawl-api-key` | MCP `firecrawl` | – |

Arne kann die Werte vom alten Rechner holen (`security find-generic-password -a arne -s <dienst> -w`)
oder neu erzeugen (Cloudflare-Dashboard, Stripe-Dashboard, firecrawl.dev).

### 6. MCP-Server für Claude Code

Vorlage: `~/Dev/dotfiles-private/claude/mcp-servers.json`. Je Server, der in `claude mcp list`
fehlt, mit `claude mcp add-json -s user <name> '<json>'` eintragen. Vorher:

- `$HOME` im JSON durch den echten Pfad ersetzen.
- `firecrawl`: Den Platzhalter `<KEYCHAIN:firecrawl-api-key>` durch den Keychain-Wert ersetzen.
  Mach das im selben Befehl, damit der Key nicht auf dem Bildschirm landet:
  `claude mcp add-json -s user firecrawl "$(jq -c --arg k "$(security find-generic-password -a arne -s firecrawl-api-key -w)" '.firecrawl | .env.FIRECRAWL_API_KEY=$k' <vorlage>)"`
- `sipgate`: vorher `vp install -g sipgate-mcp` (bzw. `npm i -g`), dann den echten Pfad zu
  `dist/index.js` eintragen.
- `core`: braucht das Repo `~/Dev/nordwerk/core` (`gh repo list` zeigt, wo es liegt). Ohne
  dieses Repo weglassen und im Bericht nennen.
- `stripe` und `cloudflare-api` laufen über HTTP/OAuth bzw. `cf-mcp-headers`. Nach dem
  Eintragen in Claude Code `/mcp` öffnen und authentifizieren lassen (Arne).
- `lumae` nur, wenn `/Applications/Lumae.app` existiert.

### 7. Logins

Nur anstoßen, was fehlt: `gh` (Schritt 1), `! codex login`, `! gcloud auth login`, `! fly auth login`.
Danach `fx status`.

### 8. Prüfen

```sh
zsh -i -c 'echo shell ok; command -v vp eza fzf zoxide gh'
readlink ~/.zshrc ~/.gitconfig ~/.claude/CLAUDE.md ~/.claude/settings.json
brew bundle check --file ~/Dev/dotfiles/Brewfile
claude mcp list
cf-doctor --quick
```

### 9. Bericht an Arne

Kurze Tabelle: erledigt / übersprungen (war schon da) / offen mit dem genauen nächsten Befehl.
Weise darauf hin, dass ein neues Terminal-Fenster nötig ist, damit die neue Shell greift, und
Claude Code neu starten muss, damit `CLAUDE.md`, settings und MCP-Server geladen werden.

## Pflege (wenn Arne etwas Neues aufnehmen will)

1. Datei ins passende Repo verschieben. Persönliches, Kundenbezogenes und alles mit Pfaden zu
   privaten Projekten kommt in `dotfiles-private`, der Rest nach `dotfiles`. Dieses Repo ist öffentlich.
2. Eine `link`-Zeile in das jeweilige `install.sh` eintragen, `./install.sh` ausführen.
3. Vor dem Commit nach Secrets suchen (`grep -rnE 'sk_|ghp_|fc-|BEGIN .*PRIVATE|token|apikey' .`).
4. Committen und pushen. Änderungen am Auto-Memory (`dotfiles-private/claude/memory/`)
   entstehen von selbst; gelegentlich mitcommitten.
