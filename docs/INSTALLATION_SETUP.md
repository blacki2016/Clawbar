# Clawbar — Installation Setup Brief

## Deine Aufgabe

Richte für das Clawbar-Projekt eine professionelle, breit aufgestellte Installation-Infrastruktur auf. Das Ziel: Entwickler und Nutzer sollen Clawbar mit möglichst wenig Reibung installieren können.

---

## Projekt-Steckbrief

**Produkt:** Clawbar 🦞
**Beschreibung:** macOS Menüleisten-App + CLI zur Echtzeit-Überwachung von KI-Token-Kontingenten (theclawbay, Codex, Claude, Gemini, Cursor, OpenRouter und 20+ weitere Anbieter)
**Repo:** `https://github.com/blacki2016/Clawbar`
**Version:** v0.21.0
**macOS-Anforderung:** macOS 14+ (Sonoma), Apple Silicon (ARM64)
**Architektur:** Swift/SwiftUI + Swift Package Manager, Swift Macros, Widget Extension
**Lizenz:** MIT

---

## Bestehender Release

- GitHub Release: `https://github.com/blacki2016/Clawbar/releases/tag/v0.21.0`
- Release Asset: `Clawbar-macOS.zip` (enthält `Clawbar.app`)
- Größe: ~30 MB
- Signatur: Ad-hoc (lokale Entwicklung)
- CLI-Helper: `/Applications/Clawbar.app/Contents/Helpers/clawbar`

---

## Bestehende Dateien

- `install.sh` im Repo-Root — einfaches Shell-Install-Script (funktioniert bereits)
  - URL: `https://raw.githubusercontent.com/blacki2016/Clawbar/main/install.sh`
  - Prüft macOS-Version, lädt Release-ZIP von GitHub, entpackt nach `/Applications/`, erstellt CLI-Symlink in `/usr/local/bin/` oder `/opt/homebrew/bin/`

---

## Deine Aufgaben

### 1. Homebrew Tap (PRIORITÄT 1)

Erstelle ein Homebrew Tap das folgendes ermöglicht:
```bash
brew install blacki2016/tap/clawbar
```

**So geht's:**
- Homebrew Taps leben in einem GitHub-Repo oder in einem Unterverzeichnis `homebrew-*/` eines bestehenden Repos
- Einfachste Variante: Im Clawbar-Repo ein Verzeichnis `homebrew-tap/` anlegen, darin die `Formula/clawbar.rb`
- Oder: Eigenes Repo `homebrew-tap` unter dem GitHub-Account `blacki2016`
- Die `.rb`-Datei muss das aktuelle Release-ZIP von GitHub als Cask installieren

**Was die Formula können muss:**
- Cask-Installation von `Clawbar.app` nach `/Applications/`
- Binary-Symlink für CLI: `/Applications/Clawbar.app/Contents/Helpers/clawbar` → z.B. `/opt/homebrew/bin/clawbar`
- Automatische Update-Prüfung über GitHub Releases
- Cleanup von alten Versionen

**Inspiration — typische Structure:**
```
homebrew-tap/
├── Formula/
│   └── clawbar.rb
├── README.md
└── .github/
    └── workflows/
        └── tests.yml
```

**Wichtige Details für die Formula:**
- `url` für die ZIP-Datei: muss dynamisch das latest Release treffen
- `sha256` muss automatisch ermittelt werden
- CLI-Symlink nicht vergessen (`:target` in Cask)
- `caveats`-Block mit Hinweis auf CLI-Nutzung

### 2. Installation via npm/pnpm (optional aber nice)

Erstelle ein einfaches npm-Paket das:
```bash
npm install -g clawbar-cli
```
ermöglicht — ein Wrapper-Script das den CLI-Helper herunterlädt und verfügbar macht.

**Was es tun muss:**
- Aktuelles Release von GitHub API holen
- Release-Asset (ZIP) herunterladen
- CLI-Binary extrahieren und in npm-global-binaries-Verzeichnis verlinken
- Plattform-Check (nur macOS)
- Funktionsfähig auch ohne npm/sudo

**Alternativ:** Ein einfaches Shell-basiertes Global-Install-Script das direkt ohne npm funktioniert:
```bash
curl -fsSL https://get.clawbar.app | bash
```

### 3. Installation via Direct Download mit Tracking (optional)

Erstelle eine eigene Landing-Page oder ein kurzes Script unter `https://get.clawbar.app` (oder nutze GitHub Pages) das:
- Die aktuelle Version anzeigt
- Den Download-Button zum Release-ZIP enthält
- Installationsanleitung zeigt

---

## Technische Specs

### Verzeichnisstruktur der Clawbar.app
```
Clawbar.app/
├── Contents/
│   ├── MacOS/Clawbar          ← Haupt-Binary
│   ├── Helpers/
│   │   ├── clawbar             ← CLI-Einstiegspunkt
│   │   └── ClawbarClaudeWatchdog
│   ├── PlugIns/
│   │   └── ClawbarWidget.appex ← Widget Extension
│   ├── Frameworks/
│   │   └── Sparkle.framework   ← Auto-Updater
│   └── Info.plist
└── Resources/
```

### Config-Pfad
- Primär: `~/.clawbar/config.json`
- Legacy-Fallback: `~/.codexbar/config.json` (für Upgrades von CodexBar)

### CLI-Befehle
```
clawbar usage [--provider ...]
clawbar cost [--provider ...]
clawbar models [--provider theclawbay]
clawbar config validate
clawbar config dump
clawbar --help
```

---

## Constraints

- **Nicht** das bestehende `install.sh` überschreiben oder brechen
- Alle Scripte müssen POSIX-kompatibel sein (keine GNU-spezifischen Features)
- Keine Credentials oder API-Keys hardcodieren
- Keine Third-Party-Dependencies ohne Not
- Alle Installer müssen rückstandsfrei funktionieren (keine half-installed states)

---

## Workflow

1. Homebrew Tap Formula erstellen und testen (lokal mit `brew install --cask --dry-run` oder ähnlich)
2. npm/cli-Installer Script(s) erstellen
3. README.md des Clawbar-Repos um Installations-Sektion erweitern
4. Alle Dateien im Clawbar-Repo unter `homebrew/`, `scripts/`, oder ähnlichem ablegen
5. Git commit + push

---

## Referenz-Templates

Homebrew Cask Formula Template:
```ruby
class Clawbar < Cask
  version "0.21.0"
  sha256 "..."

  url "https://github.com/blacki2016/Clawbar/releases/download/v#{version}/Clawbar-macOS.zip"
  name "Clawbar"
  desc "Token usage monitor for Codex, Claude, theclawbay and 20+ AI providers"
  homepage "https://clawbar.netlify.app"

  auto_updates true
  depends_on macos: ">= :sonoma"

  app "Clawbar.app"
  binary "#{appdir}/Clawbar.app/Contents/Helpers/clawbar", target: "clawbar"

  caveats do
    "Run 'clawbar --help' to get started."
  end
end
```

---

## Wichtige URLs für deine Arbeit

- GitHub Releases API: `https://api.github.com/repos/blacki2016/Clawbar/releases/latest`
- Aktuelles Release: `https://github.com/blacki2016/Clawbar/releases/tag/v0.21.0`
- Landing Page: `https://clawbar.netlify.app`
- Repo: `https://github.com/blacki2016/Clawbar`
- Bestehendes Install-Script: `https://raw.githubusercontent.com/blacki2016/Clawbar/main/install.sh`
