# Clawbar 🎚️ – Mögen deine Tokens niemals ausgehen.

Schlanke macOS 14+ Menüleisten-App, die deine Limits für Codex, Claude, Cursor, Gemini, Antigravity, Droid (Factory), Copilot, z.ai, Kiro, Vertex AI, Augment, Amp, JetBrains AI, OpenRouter, Perplexity und theclawbay im Blick behält (Sitzung + wöchentlich, wo verfügbar) und anzeigt, wann jedes Fenster zurückgesetzt wird. Ein Status-Item pro Anbieter (oder der Modus „Icons zusammenführen" mit einem Anbieter-Wechsler und optionaler Übersicht); aktiviere in den Einstellungen, was du nutzt. Kein Dock-Symbol, minimale UI, dynamische Menüleisten-Symbole.

<img src="codexbar.png" alt="Clawbar Menü-Screenshot" width="520" />

## Installation

### Voraussetzungen
- macOS 14+ (Sonoma)

### GitHub Releases
Download: <https://github.com/steipete/CodexBar/releases>

### Homebrew
```bash
brew install --cask steipete/tap/codexbar
```

### Linux (nur CLI)
```bash
brew install steipete/tap/codexbar
```
Alternativ `CodexBarCLI-v<tag>-linux-<arch>.tar.gz` von den GitHub Releases herunterladen.
Linux-Unterstützung über Omarchy: Community Waybar-Modul und TUI, gesteuert durch die `codexbar`-CLI.

### Erste Schritte
- Öffne Einstellungen → Anbieter und aktiviere, was du nutzt.
- Installiere bzw. melde dich bei den Anbieter-Quellen an, auf die du angewiesen bist (z. B. `codex`, `claude`, `gemini`, Browser-Cookies oder OAuth; Antigravity erfordert die Antigravity-App).
- Optional: Einstellungen → Anbieter → Codex → OpenAI-Cookies (Automatisch oder Manuell), um Dashboard-Ergänzungen hinzuzufügen.

## Anbieter

- [Codex](docs/codex.md) — Lokale Codex-CLI-RPC (+ PTY-Fallback) und optionale OpenAI-Web-Dashboard-Ergänzungen.
- [Claude](docs/claude.md) — OAuth-API oder Browser-Cookies (+ CLI-PTY-Fallback); Sitzungs- und Wochen-Nutzung.
- [Cursor](docs/cursor.md) — Browser-Sitzungs-Cookies für Plan, Nutzung und Abrechnungsresets.
- [Gemini](docs/gemini.md) — OAuth-gestützte Kontingent-API unter Verwendung von Gemini-CLI-Anmeldedaten (keine Browser-Cookies).
- [Antigravity](docs/antigravity.md) — Lokaler Language-Server-Probe (experimentell); keine externe Authentifizierung.
- [Droid](docs/factory.md) — Browser-Cookies + WorkOS-Token-Flows für Factory-Nutzung und Abrechnung.
- [Copilot](docs/copilot.md) — GitHub-Device-Flow + interne Copilot-Nutzungs-API.
- [z.ai](docs/zai.md) — API-Token (Keychain) für Kontingent + MCP-Fenster.
- [Kimi](docs/kimi.md) — Auth-Token (JWT aus `kimi-auth`-Cookie) für Wochenkontingent + 5-Stunden-Ratenlimit.
- [Kimi K2](docs/kimi-k2.md) — API-Schlüssel für kreditbasierte Nutzungsgesamte.
- [Kiro](docs/kiro.md) — CLI-basierte Nutzung via `kiro-cli /usage`-Befehl; monatliche Credits + Bonus-Credits.
- [Vertex AI](docs/vertexai.md) — Google Cloud gcloud OAuth mit Token-Kostenverfolgung aus lokalen Claude-Logs.
- [Augment](docs/augment.md) — Browser-Cookie-basierte Authentifizierung mit automatischem Sitzungs-Keepalive; Credits-Verfolgung und Nutzungsüberwachung.
- [Amp](docs/amp.md) — Browser-Cookie-basierte Authentifizierung mit Amp-Free-Nutzungsverfolgung.
- [JetBrains AI](docs/jetbrains.md) — Lokales XML-basiertes Kontingent aus der JetBrains-IDE-Konfiguration; monatliche Credits-Verfolgung.
- [OpenRouter](docs/openrouter.md) — API-Token für kreditbasierte Nutzungsverfolgung über mehrere KI-Anbieter.
- [theclawbay](docs/theclawbay.md) — API-Token für einheitliche Nutzungsverfolgung über mehrere KI-Anbieter über einen einzigen Proxy-Endpunkt (5h + Wochenfenster).
- Neue Anbieter willkommen: [Anbieter-Autorenanleitung](docs/provider.md).

## Symbol & Screenshot
Das Menüleisten-Symbol ist ein kleines Zwei-Leisten-Meter:
- Obere Leiste: 5-Stunden-/Sitzungsfenster. Falls wöchentlich fehlt/aufgebraucht und Credits verfügbar sind, wird es zu einer dickeren Credit-Leiste.
- Untere Leiste: Wöchentliches Fenster (Haarstrich).
- Fehler/veraltete Daten dimmen das Symbol; Status-Overlays zeigen Vorfälle an.

## Funktionen
- Multi-Anbieter-Menüleiste mit Anbieter-spezifischen Toggles (Einstellungen → Anbieter).
- Sitzungs- und Wochen-Meter mit Reset-Countdowns.
- Optionale Codex-Web-Dashboard-Ergänzungen (Code-Review verbleibend, Nutzungsaufschlüsselung, Credit-Verlauf).
- Lokale Kosten-Nutzungsanalyse für Codex + Claude (letzte 30 Tage).
- Anbieter-Status-Abfrage mit Vorfall-Badges im Menü und Symbol-Overlay.
- Modus „Icons zusammenführen" zum Kombinieren von Anbietern in ein Status-Item + Wechsler, mit optionaler Übersicht für bis zu drei Anbieter.
- Aktualisierungsintervalle (Manuell, 1 Min., 2 Min., 5 Min., 15 Min.).
- Gebündelte CLI (`clawbar`) für Skripte und CI (inkl. `clawbar cost --provider codex|claude` für lokale Kosten und `clawbar models` für verfügbare Provider-Modelle); Linux-CLI-Builds verfügbar.
- WidgetKit-Widget bildet die Menükarten-Schnappschüsse ab.
- Privatsphäre zuerst: Verarbeitung standardmäßig auf dem Gerät; Browser-Cookies sind Opt-in und werden wiederverwendet (keine Passwörter gespeichert).

## Hinweis zum Datenschutz
Fragt sich, ob CodexBar deine Festplatte durchsucht? Es durchkriecht nicht dein Dateisystem; es liest nur eine kleine Anzahl bekannter Speicherorte (Browser-Cookies/lokaler Speicher, lokale JSONL-Logs), wenn die entsprechenden Funktionen aktiviert sind. Siehe Diskussion und Prüfnotizen in [Issue #12](https://github.com/steipete/CodexBar/issues/12).

## macOS-Berechtigungen (warum sie benötigt werden)
- **Voller Festplattenzugriff (optional)**: nur erforderlich zum Lesen von Safari-Cookies/lokalem Speicher für webbasierte Anbieter (Codex Web, Claude Web, Cursor, Droid/Factory). Falls du ihn nicht gewährst, nutze Chrome/Firefox-Cookies oder nur CLI-Quellen.
- **Keychain-Zugriff (von macOS angefordert)**:
  - Chrome-Cookie-Import benötigt den „Chrome Safe Storage"-Schlüssel zum Entschlüsseln von Cookies.
  - Claude-OAuth-Anmeldedaten (von der Claude-CLI geschrieben) werden aus dem Keychain gelesen, wenn vorhanden.
  - z.ai-API-Token wird im Keychain über Einstellungen → Anbieter gespeichert; Copilot speichert seinen API-Token während des Device-Flows im Keychain.
  - **Wie verhindere ich diese Keychain-Warnungen?**
    - Öffne **Keychain-Zugriff.app** → Anmeldungsschlüsselbund → suche nach dem Eintrag (z. B. „Claude Code-credentials").
    - Öffne den Eintrag → **Zugriffskontrolle** → füge `Clawbar.app` unter „Immer den Zugriff durch diese Programme erlauben" hinzu.
    - Bevorzuge, nur Clawbar hinzuzufügen (vermeide „Allen Anwendungen erlauben", es sei denn, du willst es weit öffnen).
    - Starte Clawbar nach dem Speichern neu.
    - Referenz-Screenshot: ![Keychain-Zugriffskontrolle](docs/keychain-allow.png)
  - **Wie mache ich dasselbe für den Browser?**
    - Finde den „Safe Storage"-Schlüssel des Browsers (z. B. „Chrome Safe Storage", „Brave Safe Storage", „Firefox", „Microsoft Edge Safe Storage").
    - Öffne den Eintrag → **Zugriffskontrolle** → füge `Clawbar.app` unter „Immer den Zugriff durch diese Programme erlauben" hinzu.
    - Dadurch wird die Eingabeaufforderung entfernt, wenn Clawbar Cookies für diesen Browser entschlüsselt.
- **Dateien & Ordner-Eingabeaufforderungen (Ordner-/Volume-Zugriff)**: CodexBar startet Anbieter-CLIs (codex/claude/gemini/antigravity). Wenn diese CLIs ein Projektverzeichnis oder ein externes Laufwerk lesen, fragt macOS möglicherweise nach diesem Ordner/Volume (z. B. Desktop oder ein externes Volume). Dies wird durch das Arbeitsverzeichnis der CLI gesteuert, nicht durch Hintergrundausführung.
- **Was wir nicht anfordern**: Keine Bildschirmaufzeichnung, Barrierefreiheit oder Automatisierungsrechte; keine Passwörter werden gespeichert (Browser-Cookies werden auf Wunsch wiederverwendet).

## Dokumentation
- Anbieter-Übersicht: [docs/providers.md](docs/providers.md)
- Anbieter-Erstellung: [docs/provider.md](docs/provider.md)
- UI- & Symbol-Hinweise: [docs/ui.md](docs/ui.md)
- CLI-Referenz: [docs/cli.md](docs/cli.md)
- Architektur: [docs/architecture.md](docs/architecture.md)
- Aktualisierungsschleife: [docs/refresh-loop.md](docs/refresh-loop.md)
- Status-Abfrage: [docs/status.md](docs/status.md)
- Sparkle-Updates: [docs/sparkle.md](docs/sparkle.md)
- Release-Checkliste: [docs/RELEASING.md](docs/RELEASING.md)

## Erste Schritte (Entwicklung)
- Klone das Repo und öffne es in Xcode oder führe die Skripte direkt aus.
- Starte einmal, aktiviere dann Anbieter in Einstellungen → Anbieter.
- Installiere bzw. melde dich bei den Anbieter-Quellen an, auf die du angewiesen bist (CLIs, Browser-Cookies oder OAuth).
- Optional: Setze OpenAI-Cookies (Automatisch oder Manuell) für Codex-Dashboard-Ergänzungen.

## Aus Quellcode bauen
```bash
swift build -c release          # oder debug für Entwicklung
./Scripts/package_app.sh        # baut Clawbar.app an Ort und Stelle
CODEXBAR_SIGNING=adhoc ./Scripts/package_app.sh  # Ad-hoc-Signatur (kein Apple-Entwicklerkonto)
open Clawbar.app
```

Entwicklungszyklus:
```bash
./Scripts/compile_and_run.sh
```

## Verwandte Projekte
- ✂️ [Trimmy](https://github.com/steipete/Trimmy) — „Einmal einfügen, einmal ausführen." Mehrzeilige Shell-Snippets glattziehen, damit sie eingefügt und ausgeführt werden.
- 🧳 [MCPorter](https://mcporter.dev) — TypeScript-Toolkit + CLI für Model Context Protocol Server.
- 🧿 [oracle](https://askoracle.dev) — Frag das Orakel, wenn du nicht weiterkommst. Rufe GPT-5 Pro mit individuellem Kontext und Dateien auf.

## Suchst du eine Windows-Version?
- [Win-CodexBar](https://github.com/Finesssee/Win-CodexBar)

## Danksagung
Inspiriert von [ccusage](https://github.com/ryoppippi/ccusage) (MIT), insbesondere der Kosten-Nutzungsverfolgung.

## Lizenz
MIT • Peter Steinberger ([steipete](https://twitter.com/steipete))
