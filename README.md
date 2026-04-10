# Clawbar 🦞
**Mögen deine Tokens niemals ausgehen.**

macOS 14+ Menüleisten-App + CLI zur Echtzeit-Überwachung deiner KI-Token-Kontingente — für Codex, Claude, Cursor, Gemini, theclawbay und 20+ weitere Anbieter.

<img src="codexbar.png" alt="Clawbar Menü-Screenshot" width="480" />

## Features

- **Token-Monitoring** — Sitzungs- und Wochenlimits im Blick, mit automatischer Reset-Uhr
- **20+ Anbieter** — Codex, Claude, Cursor, Gemini, theclawbay, OpenRouter, Copilot, Kilo, Kimi, und mehr
- **Menüleisten-Widget** — Minimale UI, kein Dock-Symbol, dynamische Icons
- **CLI** — `clawbar usage`, `clawbar models`, `clawbar cost` — für Terminal-Nutzer
- **macOS Widget** — Kontingent-Übersicht direkt im Notification Center
- **Status-Seite** — Intergrierte Status-Abfrage für Anbieter wie theclawbay

## Installation

### Voraussetzungen
- macOS 14+ (Sonoma)
- Apple Silicon (ARM64)

### Lokaler Build
```bash
git clone https://github.com/blacki2016/Clawbar.git
cd Clawbar
./Scripts/compile_and_run.sh
```

### GitHub Releases
Download: <https://github.com/blacki2016/Clawbar/releases>

### CLI单独 (Linux/macOS)
```bash
brew install blacki2016/tap/clawbar
```
oder `CodexBarCLI-v<tag>-linux-<arch>.tar.gz` von den GitHub Releases.

## Quick Start

```bash
# Token-Stand aller Anbieter
clawbar usage

# Nur theclawbay
clawbar usage --provider theclawbay --source api

# Models-Liste für theclawbay
clawbar models --provider theclawbay

# Lokale Kosten-Analyse
clawbar cost

# Hilfe
clawbar --help
```

## Anbieter

| Anbieter | Auth | Dokumentation |
|---|---|---|
| **theclawbay** | API-Token | [theclawbay](docs/theclawbay.md) |
| **Codex** | CLI + Cookies | [codex](docs/codex.md) |
| **Claude** | OAuth / Cookies | [claude](docs/claude.md) |
| **Cursor** | Browser-Cookies | [cursor](docs/cursor.md) |
| **Gemini** | OAuth (CLI) | [gemini](docs/gemini.md) |
| **OpenRouter** | API-Token | [openrouter](docs/openrouter.md) |
| **Kilo** | API-Token | [kilo](docs/kilo.md) |
| **Kimi** | JWT-Token | [kimi](docs/kimi.md) |
| **Kimi K2** | API-Schlüssel | [kimi-k2](docs/kimi-k2.md) |
| **Copilot** | GitHub OAuth | [copilot](docs/copilot.md) |
| **Antigravity** | App (lokal) | [antigravity](docs/antigravity.md) |
| **Factory / Droid** | Browser-Cookies | [factory](docs/factory.md) |
| **z.ai** | API-Token | [zai](docs/zai.md) |
| **Kiro** | CLI | [kiro](docs/kiro.md) |
| **Vertex AI** | Google Cloud OAuth | [vertexai](docs/vertexai.md) |
| **Augment** | Browser-Cookies | [augment](docs/augment.md) |
| **Amp** | Browser-Cookies | [amp](docs/amp.md) |
| **JetBrains AI** | Lokale IDE-XML | [jetbrains](docs/jetbrains.md) |
| **Perplexity** | API-Token | [perplexity](docs/perplexity.md) |
| **Minimax** | API-Token | [minimax](docs/minimax.md) |
| **Alibaba Cloud** | API-Token | [alibaba](docs/alibaba-coding-plan.md) |

## Konfiguration

Clawbar sucht die Config unter `~/.clawbar/config.json` (Legacy-Fallback: `~/.codexbar/config.json`):

```json
{
  "providers": {
    "theclawbay": {
      "apiKey": "dein-api-key"
    },
    "claude": {
      "source": "oauth"
    }
  }
}
```

Siehe [configuration](docs/configuration.md) für alle Optionen.

## CLI-Befehle

```
clawbar usage [--provider ...]     Token-Stand anzeigen
clawbar cost [--provider ...]       Lokale Log-Kosten
clawbar models [--provider theclawbay]  Models auflisten
clawbar config validate            Config prüfen
clawbar config dump               Config anzeigen
```

Globale Flags: `--format json`, `--pretty`, `--no-color`, `--verbose`

## Tech Stack

- **Swift 5.9+** / SwiftUI / AppKit
- **Swift Package Manager** (kein CocoaPods)
- **KeychainAccess** für Credential-Speicherung
- **Sparkle** für Auto-Updates (Release-Builds)
- **Keychain** + **App Groups** für Widget-Datenfreigabe

## Lizenz

MIT — siehe [LICENSE](LICENSE).

## Branding

- **Logo / Maskottchen:** ClawBot — das rote 3D-Crab-Maskottchen mit HUD-Visor
- **Farbschema:** Rot (#E53935) + Cyan (#00BCD4) + Navy
- **Glass-Variante:** Monochrome Weiß-Transluzent für Provider-Symbole
