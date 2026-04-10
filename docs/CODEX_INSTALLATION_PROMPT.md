# Prompt für Codex / Claude Code

---

Erledige folgende Aufgabe für das Clawbar-Projekt unter `/Users/leonardwieseckel/.openclaw/workspace-hubert/CodexBar/`:

## Aufgabe: Installation-Infrastruktur aufbauen

### Projekt-Info
- **Repo:** `https://github.com/blacki2016/Clawbar`
- **Aktuelles Release:** v0.21.0 — `Clawbar-macOS.zip` (~30MB, macOS 14+, Apple Silicon)
- **Release URL:** `https://github.com/blacki2016/Clawbar/releases/tag/v0.21.0`
- **CLI-Einstieg:** `/Applications/Clawbar.app/Contents/Helpers/clawbar`
- **Bestehendes Install-Script:** `install.sh` (funktioniert bereits, nicht brechen)

Lies zuerst `docs/INSTALLATION_SETUP.md` komplett durch — dort sind alle Details, Specs und Constraints.

---

### 1. Homebrew Tap (Haupt-Aufgabe)

Erstelle ein Homebrew Tap mit `Formula/clawbar.rb`:

```bash
brew install blacki2016/tap/clawbar
```

Die Formula soll:
- Die aktuelle Version von GitHub Releases als Cask installieren
- CLI-Symlink erstellen: `/Applications/Clawbar.app/Contents/Helpers/clawbar` → `/opt/homebrew/bin/clawbar`
- SHA256-Checksumme automatisch aus dem Release ziehen (oder mit `brew fetch --cask clawbar` verifizieren)
- Auto-Updates über GitHub Releases ermöglichen (`auto_updates true`)
- POSIX-kompatibel sein

Erstelle das Verzeichnis `homebrew-tap/Formula/` im Clawbar-Repo und lege dort die `clawbar.rb` ab.

**Teste die Formula** (lokal ohne push):
```bash
brew install --cask --dry-run homebrew-tap/Formula/clawbar.rb
```

---

### 2. Alternatives Shell-Install-Script

Erweitere das bestehende `install.sh` oder erstelle ein neues Script `install-cli.sh` das:
- Nur die CLI (nicht die GUI-App) installiert
- Funktioniert auf macOS und Linux
- Kein Root nötig (installiert in `$HOME/.local/bin/` oder `$HOME/bin/`)
- Genau eine Zeile zum Installieren:

```bash
curl -fsSL https://raw.githubusercontent.com/blacki2016/Clawbar/main/install-cli.sh | bash
```

---

### 3. README.md der App aktualisieren

Erweitere die `README.md` um einen sauberen **Installation**-Abschnitt mit allen drei Wegen:
1. Homebrew: `brew install blacki2016/tap/clawbar`
2. Shell-Install: `curl -fsSL https://raw.githubusercontent.com/blacki2016/Clawbar/main/install.sh | bash`
3. Manuell: ZIP von GitHub Releases downloaden

---

### Wichtige Hinweise

- **SHA256**: Ermittle die Checksumme des aktuellen Release-ZIPs und trage sie in die Formula ein
- **Versions-Dynamik**: Die Formula sollte nach Möglichkeit die Version aus dem latest GitHub Release beziehen, nicht hardcodieren
- **Pfade beachten**: CLI-Helper liegt in `/Applications/Clawbar.app/Contents/Helpers/clawbar`
- **Ad-hoc-Signatur**: Das Release ist nicht Developer-ID signiert — das ist für lokale Entwicklung OK
- **Nicht brechen**: Das bestehende `install.sh` muss weiter funktionieren

---

## Ergebnis

Am Ende sollten folgende Dateien im Repo sein:
- `homebrew-tap/Formula/clawbar.rb`
- `install-cli.sh` (oder Erweiterung von install.sh)
- Aktualisierte `README.md`

Commit und push alle Änderungen.
