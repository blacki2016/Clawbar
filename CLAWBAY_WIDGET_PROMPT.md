# Prompt: TheClawBay Widget-Support für CodexBar

## Kontext

Du arbeitest in einem lokalen CodexBar-Swift-Monorepo unter:
`/Users/leonardwieseckel/.openclaw/workspace-hubert/CodexBar/`

### Was bereits existiert (TheClawBay-Provider — vollständig implementiert)

**Core-Dateien:**
- `Sources/CodexBarCore/Providers/TheClawBay/TheClawBayProviderDescriptor.swift`
- `Sources/CodexBarCore/Providers/TheClawBay/TheClawBayUsageFetcher.swift`
- `Sources/CodexBarCore/Providers/TheClawBay/TheClawBaySettingsReader.swift`

**App-Dateien:**
- `Sources/CodexBar/Providers/TheClawBay/TheClawBayProviderImplementation.swift`
- `Sources/CodexBar/Providers/TheClawBay/TheClawBaySettingsStore.swift`

**UsageProvider + IconStyle:**
- `.theclawbay` ist bereits in `UsageProvider` und `IconStyle` enums in `Providers.swift`

**WidgetColors:**
- `.theclawbay` Case existiert bereits in `WidgetColors.color(for:)` mit Farbe `Color(red: 16/255, green: 163/255, blue: 127/255)`

**Metadata:**
- `TheClawBayProviderDescriptor` registriert sich via `@ProviderDescriptorRegistration` Makro
- `ProviderDefaults.metadata` wird automatisch aus Descriptors befüllt

**Icon:**
- `ProviderIcon-theclawbay.png` existiert in `Sources/CodexBar/Resources/`

**Config:**
- API-Key ist in `~/.codexbar/config.json` eingetragen
- Provider ist aktiv (`enabled: true, source: "api"`)

---

## Was noch fehlt: Widget-Support

Die Widget-Extension ist in:
- `Sources/CodexBarWidget/CodexBarWidgetProvider.swift`
- `Sources/CodexBarWidget/CodexBarWidgetViews.swift`

### Ziel
TheClawBay soll im macOS Notification-Center-Widget auswählbar sein.

### Exakte Änderungen die nötig sind

**1. Datei: `Sources/CodexBarWidget/CodexBarWidgetProvider.swift`**

**A) `ProviderChoice` enum** — füge `.theclawbay` Case hinzu:
```swift
case theclawbay
```
sowie in `caseDisplayRepresentations`:
```swift
.theclawbay: DisplayRepresentation(title: "The Claw Bay"),
```

**B) `ProviderChoice.provider` computed property** — füge hinzu:
```swift
case .theclawbay: .theclawbay
```

**C) `ProviderChoice.init?(provider:)` initializer** — füge hinzu:
```swift
case .theclawbay: self = .theclawbay
```
(Die Zeile `case .theclawbay: return nil` muss entfernt werden.)

**2. Datei: `Sources/CodexBarWidget/CodexBarWidgetViews.swift`**

**A) `ProviderSwitchChip.shortLabel` computed property** — füge hinzu:
```swift
case .theclawbay: "TCB"
```

---

## Vorgehensweise

1. **Erst planen**: Lies beide Widget-Dateien vollständig durch
2. **Exakt die oben beschriebenen 4 Änderungen** in den richtigen Dateien machen
3. **Swift Build prüfen**: `cd /Users/leonardwieseckel/.openclaw/workspace-hubert/CodexBar && swift build`
4. Falls Build fehlschlägt: Fehler beheben und nochmal bauen
5. **compile_and_run.sh** ausführen um App + Widget neu zu bauen und zu starten

---

## Wichtige Hinweise

- **Genau 4 Stellen** ändern — nicht mehr, nicht weniger
- Keine neuen Dateien nötig
- Keine Änderungen an `WidgetColors` nötig (bereits vorhanden)
- Keine Änderungen an `ProviderDefaults.metadata` nötig (Descriptor registriert sich automatisch)
- Farbe für TheClawBay ist: `Color(red: 16/255, green: 163/255, blue: 127/255)` (Teal)
- **Wichtig**: Der `init?(provider:)` switch muss nun **nicht mehr** `return nil` für `.theclawbay` haben — CodexBar soll den Provider kennen. Der alte Kommentar `// The Claw Bay not yet supported in widgets` wird damit obsolet.

---

## Abschluss

Nach erfolgreichem Build:
1. Script `./Scripts/compile_and_run.sh` ausführen
2. App startet mit Widget-Support
3. Im Notification Center sollte "The Claw Bay" als Provider auswählbar sein
4. Kurz verifizieren dass der Build fehlerfrei durchläuft

Falls du auf Probleme stößt, beschreibe sie präzise bevor du Lösungen implementierst.
