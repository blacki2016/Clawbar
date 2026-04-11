import Foundation
import SwiftUI
import Combine

/// Supported app languages
enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case german = "de"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .german: return "Deutsch"
        }
    }
}

/// Centralized localization manager - marked @MainActor for concurrency safety
@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    static let languageDefaultsKey = "clawbar_language"

    @Published var currentLanguage: AppLanguage {
        didSet {
            guard oldValue != self.currentLanguage else { return }
            UserDefaults.standard.set(self.currentLanguage.rawValue, forKey: Self.languageDefaultsKey)
        }
    }

    private init() {
        self.currentLanguage = AppLanguage(
            rawValue: UserDefaults.standard.string(forKey: Self.languageDefaultsKey) ?? AppLanguage.english.rawValue)
            ?? .english
    }
    
    // Synchronous access to strings (cached)
    var strings: LocalizationStrings {
        currentLanguage.strings
    }
}

extension AppLanguage {
    var strings: LocalizationStrings {
        switch self {
        case .english: return .english
        case .german: return .german
        }
    }
}

// MARK: - Localized Strings

/// All UI strings in the app - accessible via LocalizationManager.shared.strings
@MainActor
enum L10n {
    private static var isGerman: Bool { LocalizationManager.shared.currentLanguage == .german }

    // MARK: - General
    static var appName: String { LocalizationManager.shared.strings.appName }
    static var version: String { LocalizationManager.shared.strings.version }
    
    // MARK: - Menu
    static var openMenu: String { LocalizationManager.shared.strings.openMenu }
    static var openSettings: String { LocalizationManager.shared.strings.openSettings }
    static var quit: String { LocalizationManager.shared.strings.quit }
    
    // MARK: - Provider
    static var provider: String { LocalizationManager.shared.strings.provider }
    static var providers: String { LocalizationManager.shared.strings.providers }
    static var account: String { LocalizationManager.shared.strings.account }
    static var accounts: String { LocalizationManager.shared.strings.accounts }
    static var noAccountsDetected: String { LocalizationManager.shared.strings.noAccountsDetected }
    static var chooseAccount: String { LocalizationManager.shared.strings.chooseAccount }
    
    // MARK: - Settings / Preferences
    static var settings: String { LocalizationManager.shared.strings.settings }
    static var general: String { LocalizationManager.shared.strings.general }
    static var display: String { LocalizationManager.shared.strings.display }
    static var advanced: String { LocalizationManager.shared.strings.advanced }
    
    // MARK: - Actions
    static var install: String { LocalizationManager.shared.strings.install }
    static var uninstall: String { LocalizationManager.shared.strings.uninstall }
    static var update: String { LocalizationManager.shared.strings.update }
    static var refresh: String { LocalizationManager.shared.strings.refresh }
    static var save: String { LocalizationManager.shared.strings.save }
    static var cancel: String { LocalizationManager.shared.strings.cancel }
    static var done: String { LocalizationManager.shared.strings.done }
    
    // MARK: - Status
    static var active: String { LocalizationManager.shared.strings.active }
    static var inactive: String { LocalizationManager.shared.strings.inactive }
    static var enabled: String { LocalizationManager.shared.strings.enabled }
    static var disabled: String { LocalizationManager.shared.strings.disabled }
    static var loading: String { LocalizationManager.shared.strings.loading }
    static var error: String { LocalizationManager.shared.strings.error }
    static var success: String { LocalizationManager.shared.strings.success }
    
    // MARK: - Usage
    static var usage: String { LocalizationManager.shared.strings.usage }
    static var credits: String { LocalizationManager.shared.strings.credits }
    static var session: String { LocalizationManager.shared.strings.session }
    static var weekly: String { LocalizationManager.shared.strings.weekly }
    static var resetIn: String { LocalizationManager.shared.strings.resetIn }
    static var resetsIn: String { LocalizationManager.shared.strings.resetsIn }
    
    // MARK: - About
    static var about: String { LocalizationManager.shared.strings.about }
    static var built: String { LocalizationManager.shared.strings.built }
    static var license: String { LocalizationManager.shared.strings.license }
    static var updateChannel: String { LocalizationManager.shared.strings.updateChannel }
    static var checkForUpdates: String { LocalizationManager.shared.strings.checkForUpdates }
    static var updatesUnavailable: String { LocalizationManager.shared.strings.updatesUnavailable }

    // MARK: - Preferences Shell
    static var overviewTab: String { isGerman ? "Überblick" : "Overview" }
    static var menubarTab: String { isGerman ? "Menüleiste" : "Menubar" }
    static var toolsTab: String { isGerman ? "Werkzeuge" : "Tools" }
    static var debugTab: String { "Debug" }
    static var heroEyebrow: String { isGerman ? "Clawbar Kommandozentrale" : "Clawbar control room" }
    static var heroTitle: String { isGerman ? "Behalte Quotendruck im Blick." : "Keep quota pressure visible." }
    static var heroSubtitle: String {
        isGerman
            ? "Passe Menüleiste, Refresh-Rhythmus und Provider-Setup auf einer zentralen Oberfläche an."
            : "Tune the menubar, refresh rhythm and provider setup from one branded surface."
    }

    // MARK: - General Pane
    static var languageAndBehaviorCaption: String { isGerman ? "Sprache und App-Verhalten." : "Language and app behavior." }
    static var language: String { isGerman ? "Sprache" : "Language" }
    static var preferredLanguageSubtitle: String {
        isGerman ? "Wähle deine bevorzugte Sprache für Clawbar." : "Choose your preferred language for Clawbar."
    }
    static var systemSectionTitle: String { isGerman ? "System" : "System" }
    static var systemSectionCaption: String {
        isGerman ? "Startverhalten und appweite Automatisierung." : "Launch behavior and app-wide automation."
    }
    static var startAtLogin: String { isGerman ? "Beim Login starten" : "Start at Login" }
    static var startAtLoginSubtitle: String {
        isGerman ? "Öffnet Clawbar automatisch beim Start deines Macs." : "Automatically opens Clawbar when you start your Mac."
    }
    static var usageIntelligenceTitle: String { isGerman ? "Nutzungsintelligenz" : "Usage intelligence" }
    static var usageIntelligenceCaption: String {
        isGerman
            ? "Lege fest, wie viel lokaler Kostenkontext in Clawbar sichtbar bleibt."
            : "Decide how much local cost context Clawbar should keep visible."
    }
    static var showCostSummary: String { isGerman ? "Kostenübersicht anzeigen" : "Show cost summary" }
    static var showCostSummarySubtitle: String {
        isGerman
            ? "Liest lokale Nutzungslogs und zeigt die Kosten von heute und den letzten 30 Tagen im Menü."
            : "Reads local usage logs. Shows today + last 30 days cost in the menu."
    }
    static var autoRefreshHourlyTimeout: String {
        isGerman ? "Auto-Refresh: stündlich · Timeout: 10 Min." : "Auto-refresh: hourly · Timeout: 10m"
    }
    static var automationTitle: String { isGerman ? "Automatisierung" : "Automation" }
    static var automationCaption: String {
        isGerman
            ? "Hintergrund-Refreshes, Provider-Health-Checks und Sitzungswarnungen."
            : "Background refreshes, provider health checks and session alerts."
    }
    static var refreshCadence: String { isGerman ? "Refresh-Intervall" : "Refresh cadence" }
    static var refreshCadenceSubtitle: String {
        isGerman ? "Wie oft Clawbar Provider im Hintergrund aktualisiert." : "How often Clawbar polls providers in the background."
    }
    static var autoRefreshOff: String {
        isGerman ? "Auto-Refresh ist deaktiviert; nutze im Menü den Befehl „Aktualisieren“." : "Auto-refresh is off; use the menu's Refresh command."
    }
    static var checkProviderStatus: String { isGerman ? "Provider-Status prüfen" : "Check provider status" }
    static var checkProviderStatusSubtitle: String {
        isGerman
            ? "Fragt OpenAI-/Claude-Statusseiten und Google Workspace für Gemini/Antigravity ab und zeigt Vorfälle im Icon und Menü."
            : "Polls OpenAI/Claude status pages and Google Workspace for Gemini/Antigravity, surfacing incidents in the icon and menu."
    }
    static var sessionQuotaNotifications: String { isGerman ? "Sitzungs-Quota-Benachrichtigungen" : "Session quota notifications" }
    static var sessionQuotaNotificationsSubtitle: String {
        isGerman
            ? "Benachrichtigt, wenn das 5-Stunden-Kontingent 0 % erreicht und wenn es wieder verfügbar ist."
            : "Notifies when the 5-hour session quota hits 0% and when it becomes available again."
    }
    static var sessionSectionTitle: String { isGerman ? "Sitzung" : "Session" }
    static var sessionSectionCaption: String {
        isGerman ? "Beende die App direkt aus der Zentrale." : "Quit the app directly from the control room."
    }
    static var unsupported: String { isGerman ? "nicht unterstützt" : "unsupported" }
    static var fetching: String { isGerman ? "lädt" : "fetching" }
    static var lastAttempt: String { isGerman ? "letzter Versuch" : "last attempt" }
    static var noDataYet: String { isGerman ? "noch keine Daten" : "no data yet" }

    // MARK: - Display Pane
    static var menubarSignalTitle: String { isGerman ? "Signal in der Menüleiste" : "Signal in the menubar" }
    static var menubarSignalCaption: String {
        isGerman ? "Definiere, wie kompakt oder ausdrucksstark Clawbar in der Menüleiste wirkt." : "Define how compact or expressive the live menubar presence should feel."
    }
    static var mergeIcons: String { isGerman ? "Icons zusammenführen" : "Merge Icons" }
    static var mergeIconsSubtitle: String { isGerman ? "Verwendet ein einzelnes Menüleisten-Icon mit Provider-Switcher." : "Use a single menu bar icon with a provider switcher." }
    static var switcherShowsIcons: String { isGerman ? "Switcher zeigt Icons" : "Switcher shows icons" }
    static var switcherShowsIconsSubtitle: String {
        isGerman ? "Zeigt Provider-Icons im Switcher an, sonst eine wöchentliche Fortschrittslinie." : "Show provider icons in the switcher (otherwise show a weekly progress line)."
    }
    static var showMostUsedProvider: String { isGerman ? "Meistgenutzten Provider anzeigen" : "Show most-used provider" }
    static var showMostUsedProviderSubtitle: String {
        isGerman ? "Die Menüleiste zeigt automatisch den Provider, der seinem Limit am nächsten ist." : "Menu bar auto-shows the provider closest to its rate limit."
    }
    static var menuBarShowsPercent: String { isGerman ? "Prozent in der Menüleiste anzeigen" : "Menu bar shows percent" }
    static var menuBarShowsPercentSubtitle: String {
        isGerman ? "Ersetzt die Critter-Balken durch Provider-Branding-Icons und einen Prozentwert." : "Replace critter bars with provider branding icons and a percentage."
    }
    static var displayMode: String { isGerman ? "Anzeigemodus" : "Display mode" }
    static var displayModeSubtitle: String {
        isGerman ? "Wähle, was in der Menüleiste gezeigt wird (Pace zeigt Nutzung vs. Erwartung)." : "Choose what to show in the menu bar (Pace shows usage vs. expected)."
    }
    static var popoverContentTitle: String { isGerman ? "Popover-Inhalt" : "Popover content" }
    static var popoverContentCaption: String {
        isGerman ? "Bestimme die Informationsdichte im Clawbar-Menü." : "Shape the information density inside the Clawbar menu."
    }
    static var showUsageAsUsed: String { isGerman ? "Nutzung als verbraucht anzeigen" : "Show usage as used" }
    static var showUsageAsUsedSubtitle: String {
        isGerman ? "Fortschrittsbalken füllen sich mit verbrauchter Quote statt verbleibender Quote." : "Progress bars fill as you consume quota (instead of showing remaining)."
    }
    static var showResetTimeAsClock: String { isGerman ? "Resetzeit als Uhrzeit anzeigen" : "Show reset time as clock" }
    static var showResetTimeAsClockSubtitle: String {
        isGerman ? "Zeigt Resetzeiten als absolute Uhrzeiten statt als Countdown." : "Display reset times as absolute clock values instead of countdowns."
    }
    static var showCreditsExtraUsage: String { isGerman ? "Credits und Zusatznutzung anzeigen" : "Show credits + extra usage" }
    static var showCreditsExtraUsageSubtitle: String {
        isGerman ? "Zeigt Codex Credits und Claude Extra-Nutzung im Menü." : "Show Codex Credits and Claude Extra usage sections in the menu."
    }
    static var showAllTokenAccounts: String { isGerman ? "Alle Token-Konten anzeigen" : "Show all token accounts" }
    static var showAllTokenAccountsSubtitle: String {
        isGerman ? "Stapelt Token-Konten im Menü, statt nur eine Konten-Umschaltleiste zu zeigen." : "Stack token accounts in the menu (otherwise show an account switcher bar)."
    }
    static var overviewTabProviders: String { isGerman ? "Provider im Überblick-Tab" : "Overview tab providers" }
    static var configure: String { isGerman ? "Konfigurieren…" : "Configure…" }
    static var enableMergeIconsToConfigureOverview: String {
        isGerman ? "Aktiviere „Icons zusammenführen“, um Provider für den Überblick zu konfigurieren." : "Enable Merge Icons to configure Overview tab providers."
    }
    static var noEnabledProvidersForOverview: String { isGerman ? "Keine aktivierten Provider für den Überblick verfügbar." : "No enabled providers available for Overview." }
    static func chooseUpToProviders(_ count: Int) -> String {
        isGerman ? "Wähle bis zu \(count) Provider" : "Choose up to \(count) providers"
    }
    static var overviewRowsFollowProviderOrder: String { isGerman ? "Überblick-Zeilen folgen immer der Provider-Reihenfolge." : "Overview rows always follow provider order." }
    static var noProvidersSelected: String { isGerman ? "Keine Provider ausgewählt" : "No providers selected" }
    static var automatic: String { isGerman ? "Automatisch" : "Automatic" }
    static func primaryMetric(_ value: String) -> String { isGerman ? "Primär (\(value))" : "Primary (\(value))" }
    static func secondaryMetric(_ value: String) -> String { isGerman ? "Sekundär (\(value))" : "Secondary (\(value))" }
    static func tertiaryMetric(_ value: String) -> String { isGerman ? "Tertiär (\(value))" : "Tertiary (\(value))" }
    static func averageMetric(_ lhs: String, _ rhs: String) -> String { isGerman ? "Durchschnitt (\(lhs) + \(rhs))" : "Average (\(lhs) + \(rhs))" }
    static var primaryAPILimit: String { isGerman ? "Primär (API-Key-Limit)" : "Primary (API key limit)" }
    static var menuBarMetric: String { isGerman ? "Menüleisten-Metrik" : "Menu bar metric" }
    static var menuBarMetricSubtitle: String { isGerman ? "Wähle, welches Fenster den Prozentwert in der Menüleiste bestimmt." : "Choose which window drives the menu bar percent." }

    // MARK: - Advanced Pane
    static var keyboardControlTitle: String { isGerman ? "Tastatursteuerung" : "Keyboard control" }
    static var keyboardControlCaption: String { isGerman ? "Öffne Clawbar ohne Maus." : "Jump into Clawbar without touching the pointer." }
    static var openMenuAction: String { isGerman ? "Menü öffnen" : "Open menu" }
    static var openMenuActionSubtitle: String { isGerman ? "Öffnet das Menüleisten-Menü von überall." : "Trigger the menu bar menu from anywhere." }
    static var cliHandoffTitle: String { isGerman ? "CLI-Übergabe" : "CLI handoff" }
    static var cliHandoffCaption: String {
        isGerman ? "Installiert den gebündelten Helper, damit Skripte denselben Provider-Status lesen können." : "Install the bundled helper so scripts can read the same provider state."
    }
    static var installCLI: String { isGerman ? "CLI installieren" : "Install CLI" }
    static var cliHandoffSubtitle: String {
        isGerman ? "Verlinkt den gebündelten `clawbar`-Helper nach `/usr/local/bin` und `/opt/homebrew/bin`." : "Symlink the bundled clawbar helper to /usr/local/bin and /opt/homebrew/bin."
    }
    static var diagnosticsTitle: String { isGerman ? "Diagnostik" : "Diagnostics" }
    static var diagnosticsCaption: String { isGerman ? "Zeigt Werkzeuge zur Fehleranalyse und optionales visuelles Verhalten." : "Reveal troubleshooting tools and optional visual behavior." }
    static var showDebugSettings: String { isGerman ? "Debug-Einstellungen anzeigen" : "Show Debug Settings" }
    static var showDebugSettingsSubtitle: String { isGerman ? "Blendet Werkzeuge zur Fehleranalyse im Debug-Tab ein." : "Expose troubleshooting tools in the Debug tab." }
    static var surpriseMe: String { isGerman ? "Überrasch mich" : "Surprise me" }
    static var surpriseMeSubtitle: String { isGerman ? "Prüft, ob deine Agents da oben ein wenig Spaß haben dürfen." : "Check if you like your agents having some fun up there." }
    static var privacyTitle: String { isGerman ? "Privatsphäre" : "Privacy" }
    static var privacyCaption: String { isGerman ? "Reduziert sichtbare persönliche Daten bei Demos oder Aufnahmen." : "Reduce on-screen personal data when you demo or record the app." }
    static var hidePersonalInfo: String { isGerman ? "Persönliche Informationen verbergen" : "Hide personal information" }
    static var hidePersonalInfoSubtitle: String { isGerman ? "Verschleiert E-Mail-Adressen in Menüleiste und Menü." : "Obscure email addresses in the menu bar and menu UI." }
    static var keychainAccessTitle: String { isGerman ? "Schlüsselbund-Zugriff" : "Keychain access" }
    static var keychainAccessCaption: String {
        isGerman ? "Deaktiviert alle Schlüsselbund-Lese- und Schreibzugriffe. Browser-Cookie-Import ist dann nicht verfügbar; Cookie-Header müssen manuell in den Providern eingefügt werden." : "Disable all Keychain reads and writes. Browser cookie import is unavailable; paste Cookie headers manually in Providers."
    }
    static var disableKeychainAccess: String { isGerman ? "Schlüsselbund-Zugriff deaktivieren" : "Disable Keychain access" }
    static var disableKeychainAccessSubtitle: String { isGerman ? "Verhindert jeden Schlüsselbund-Zugriff, solange aktiviert." : "Prevents any Keychain access while enabled." }
    static var cliHelperNotFound: String { isGerman ? "clawbar-Helper im App-Bundle nicht gefunden." : "clawbar helper not found in app bundle." }
    static func noWriteAccess(_ dir: String) -> String { isGerman ? "Kein Schreibzugriff: \(dir)" : "No write access: \(dir)" }
    static func installedIn(_ dir: String) -> String { isGerman ? "Installiert: \(dir)" : "Installed: \(dir)" }
    static func existsIn(_ dir: String) -> String { isGerman ? "Existiert bereits: \(dir)" : "Exists: \(dir)" }
    static func failedIn(_ dir: String) -> String { isGerman ? "Fehlgeschlagen: \(dir)" : "Failed: \(dir)" }
    static var noWritableBinDirs: String { isGerman ? "Keine beschreibbaren `bin`-Verzeichnisse gefunden." : "No writable bin dirs found." }

    // MARK: - About Pane
    static var aboutEyebrow: String { isGerman ? "Über Clawbar" : "About Clawbar" }
    static func versionString(_ value: String) -> String { isGerman ? "Version \(value)" : "Version \(value)" }
    static func builtString(_ value: String) -> String { isGerman ? "Erstellt \(value)" : "Built \(value)" }
    static var aboutSubtitle: String { isGerman ? "Ein dediziertes Token-Radar für Multi-Provider-KI-Workflows." : "A dedicated token radar for multi-provider AI workflows." }
    static var github: String { "GitHub" }
    static var releases: String { isGerman ? "Releases" : "Releases" }
    static var documentation: String { isGerman ? "Dokumentation" : "Documentation" }
    static var reportIssue: String { isGerman ? "Problem melden" : "Report issue" }
    static var autoUpdateToggle: String { isGerman ? "Automatisch nach Updates suchen" : "Check for updates automatically" }
    static var checkForUpdatesEllipsis: String { isGerman ? "Nach Updates suchen…" : "Check for Updates…" }
    static var copyrightLine: String { isGerman ? "© 2026 Clawbar. MIT-Lizenz." : "© 2026 Clawbar. MIT License." }

    // MARK: - Providers Pane
    static var selectAProvider: String { isGerman ? "Wähle einen Provider" : "Select a provider" }
    static var lastFetchFailed: String { isGerman ? "letzter Abruf fehlgeschlagen" : "last fetch failed" }
    static var usageNotFetchedYet: String { isGerman ? "Nutzung noch nicht geladen" : "usage not fetched yet" }
    static var managedStoreUnreadableNotice: String {
        isGerman
            ? "Der Speicher für verwaltete Konten ist nicht lesbar. Auf das Live-Konto kann weiterhin zugegriffen werden, aber Hinzufügen, Re-Authentifizierung und Entfernen verwalteter Konten sind deaktiviert, bis der Speicher wieder lesbar ist."
            : "Managed account storage is unreadable. Live account access is still available, but managed add, re-auth, and remove actions are disabled until the store is recoverable."
    }
    static var removeCodexAccountTitle: String { isGerman ? "Codex-Konto entfernen?" : "Remove Codex account?" }
    static func removeCodexAccountMessage(_ email: String) -> String {
        isGerman ? "\(email) aus Clawbar entfernen? Das verwaltete Codex-Home wird gelöscht." : "Remove \(email) from Clawbar? Its managed Codex home will be deleted."
    }
    static var managedLoginAlreadyRunning: String {
        isGerman
            ? "Eine verwaltete Codex-Anmeldung läuft bereits. Warte, bis sie abgeschlossen ist, bevor du ein weiteres Konto hinzufügst oder neu authentifizierst."
            : "A managed Codex login is already running. Wait for it to finish before adding or re-authenticating another account."
    }
    static var managedLoginFailed: String {
        isGerman
            ? "Die verwaltete Codex-Anmeldung wurde nicht abgeschlossen. Versuche es erneut, nachdem du den Browser-Login beendet hast."
            : "Managed Codex login did not complete. Try again after finishing the browser login flow."
    }
    static var managedLoginMissingEmail: String {
        isGerman
            ? "Die Codex-Anmeldung wurde abgeschlossen, aber es war keine Konto-E-Mail verfügbar. Versuche es erneut, nachdem das Konto vollständig angemeldet ist."
            : "Codex login completed, but no account email was available. Try again after confirming the account is fully signed in."
    }
    static func unsafeManagedHome(_ path: String) -> String {
        isGerman ? "Clawbar hat einen unerwarteten Managed-Home-Pfad nicht verändert: \(path)" : "Clawbar refused to modify an unexpected managed home path: \(path)"
    }

    // MARK: - Codex Accounts
    static var noSystemAccount: String { isGerman ? "Kein Systemkonto" : "No system account" }
    static var addingAccount: String { isGerman ? "Konto wird hinzugefügt…" : "Adding Account…" }
    static var addAccount: String { isGerman ? "Konto hinzufügen" : "Add Account" }
    static var reauthenticating: String { isGerman ? "Erneute Anmeldung…" : "Re-authenticating…" }
    static var reauth: String { isGerman ? "Neu anmelden" : "Re-auth" }
    static var activeAccount: String { isGerman ? "Aktiv" : "Active" }
    static var chooseCodexAccount: String { isGerman ? "Wähle, welchem Codex-Konto Clawbar folgen soll." : "Choose which Codex account Clawbar should follow." }
    static var accountLabel: String { LocalizationManager.shared.strings.account }
    static var noCodexAccounts: String { isGerman ? "Noch keine Codex-Konten erkannt." : "No Codex accounts detected yet." }
    static var systemLabel: String { isGerman ? "System" : "System" }
    static var systemAccountSubtitle: String { isGerman ? "Das Standard-Codex-Konto auf diesem Mac." : "The default Codex account on this Mac." }
    static var systemBadge: String { isGerman ? "(System)" : "(System)" }
    static var remove: String { isGerman ? "Entfernen" : "Remove" }

    // MARK: - Provider Detail
    static var plan: String { isGerman ? "Plan" : "Plan" }
    static var balance: String { isGerman ? "Guthaben" : "Balance" }
    static func lastFetchFailedTitle(_ providerName: String) -> String {
        isGerman ? "Letzter Abruf von \(providerName) fehlgeschlagen:" : "Last \(providerName) fetch failed:"
    }
    static var providerSettings: String { isGerman ? "Einstellungen" : "Settings" }
    static var options: String { isGerman ? "Optionen" : "Options" }
    static var state: String { isGerman ? "Status" : "State" }
    static var source: String { isGerman ? "Quelle" : "Source" }
    static var updated: String { isGerman ? "Aktualisiert" : "Updated" }
    static var statusLabel: String { isGerman ? "Status" : "Status" }
    static var providerDeck: String { isGerman ? "Provider-Deck" : "Provider deck" }
    static var notDetected: String { isGerman ? "nicht erkannt" : "not detected" }
    static var refreshing: String { isGerman ? "Aktualisiert…" : "Refreshing" }
    static var notFetchedYet: String { isGerman ? "Noch nicht geladen" : "Not fetched yet" }
    static var usageRadar: String { isGerman ? "Nutzungsradar" : "Usage radar" }
    static var disabledNoRecentData: String { isGerman ? "Deaktiviert — keine aktuellen Daten" : "Disabled — no recent data" }
    static var noUsageYet: String { isGerman ? "Noch keine Nutzung" : "No usage yet" }
    static var costLabel: String { isGerman ? "Kosten" : "Cost" }
    static var providerRoster: String { isGerman ? "Provider-Übersicht" : "Provider roster" }
    static var dragToReorder: String { isGerman ? "Zum Neuordnen ziehen" : "Drag to reorder" }
    static var activeFeed: String { isGerman ? "Aktiver Feed" : "Active feed" }
    static var paused: String { isGerman ? "Pausiert" : "Paused" }
    static func disabledPrefix(_ text: String) -> String { isGerman ? "Deaktiviert — \(text)" : "Disabled — \(text)" }
    static var reorder: String { isGerman ? "Neu anordnen" : "Reorder" }

    // MARK: - Token Accounts
    static var noTokenAccountsYet: String { isGerman ? "Noch keine Token-Konten." : "No token accounts yet." }
    static var removeSelectedAccount: String { isGerman ? "Ausgewähltes Konto entfernen" : "Remove selected account" }
    static var label: String { isGerman ? "Bezeichnung" : "Label" }
    static var add: String { isGerman ? "Hinzufügen" : "Add" }
    static var openTokenFile: String { isGerman ? "Token-Datei öffnen" : "Open token file" }
    static var reload: String { isGerman ? "Neu laden" : "Reload" }
    static var copyError: String { isGerman ? "Fehler kopieren" : "Copy error" }
    static var hideDetails: String { isGerman ? "Details ausblenden" : "Hide details" }
    static var showDetails: String { isGerman ? "Details anzeigen" : "Show details" }

    // MARK: - Debug Pane
    static var logging: String { isGerman ? "Logging" : "Logging" }
    static var enableFileLogging: String { isGerman ? "Datei-Logging aktivieren" : "Enable file logging" }
    static func fileLoggingSubtitle(_ path: String) -> String {
        isGerman ? "Schreibt Logs zur Analyse nach \(path)." : "Write logs to \(path) for debugging."
    }
    static var verbosity: String { isGerman ? "Ausführlichkeit" : "Verbosity" }
    static var verbositySubtitle: String { isGerman ? "Steuert, wie detailliert geloggt wird." : "Controls how much detail is logged." }
    static var openLogFile: String { isGerman ? "Logdatei öffnen" : "Open log file" }
    static var forceAnimationOnNextRefresh: String { isGerman ? "Animation beim nächsten Refresh erzwingen" : "Force animation on next refresh" }
    static var forceAnimationOnNextRefreshSubtitle: String { isGerman ? "Zeigt nach dem nächsten Refresh vorübergehend die Ladeanimation." : "Temporarily shows the loading animation after the next refresh." }
    static var loadingAnimations: String { isGerman ? "Ladeanimationen" : "Loading animations" }
    static var loadingAnimationsCaption: String { isGerman ? "Wähle ein Muster und spiele es in der Menüleiste ab. „Zufällig“ behält das bisherige Verhalten." : "Pick a pattern and replay it in the menu bar. \"Random\" keeps the existing behavior." }
    static var animationPattern: String { isGerman ? "Animationsmuster" : "Animation pattern" }
    static var randomDefault: String { isGerman ? "Zufällig (Standard)" : "Random (default)" }
    static var replaySelectedAnimation: String { isGerman ? "Ausgewählte Animation wiederholen" : "Replay selected animation" }
    static var blinkNow: String { isGerman ? "Jetzt blinken" : "Blink now" }
    static var probeLogs: String { isGerman ? "Probe-Logs" : "Probe logs" }
    static var probeLogsCaption: String { isGerman ? "Lädt die neuesten Probe-Ausgaben zur Analyse; „Kopieren“ übernimmt den vollständigen Text." : "Fetch the latest probe output for debugging; Copy keeps the full text." }
    static var providerLabel: String { isGerman ? "Provider" : "Provider" }
    static var fetchLog: String { isGerman ? "Log laden" : "Fetch log" }
    static var copy: String { isGerman ? "Kopieren" : "Copy" }
    static var saveToFile: String { isGerman ? "In Datei sichern" : "Save to file" }
    static var loadParseDump: String { isGerman ? "Parse-Dump laden" : "Load parse dump" }
    static var rerunProviderAutodetect: String { isGerman ? "Provider-Autodetect erneut ausführen" : "Re-run provider autodetect" }
    static var fetchStrategyAttempts: String { isGerman ? "Abrufstrategie-Versuche" : "Fetch strategy attempts" }
    static var fetchStrategyAttemptsCaption: String { isGerman ? "Letzte Pipeline-Entscheidungen und Fehler eines Providers." : "Last fetch pipeline decisions and errors for a provider." }
    static var openAICookies: String { isGerman ? "OpenAI-Cookies" : "OpenAI cookies" }
    static var openAICookiesCaption: String { isGerman ? "Cookie-Import- und WebKit-Scrape-Logs des letzten OpenAI-Cookie-Versuchs." : "Cookie import + WebKit scrape logs from the last OpenAI cookies attempt." }
    static var noLogYetUpdateCookies: String { isGerman ? "Noch kein Log. Aktualisiere OpenAI-Cookies unter Provider → Codex, um einen Import auszuführen." : "No log yet. Update OpenAI cookies in Providers → Codex to run an import." }
    static var caches: String { isGerman ? "Caches" : "Caches" }
    static var clearCachedCostResults: String { isGerman ? "Löscht zwischengespeicherte Cost-Scan-Ergebnisse." : "Clear cached cost scan results." }
    static var clearCostCache: String { isGerman ? "Kosten-Cache leeren" : "Clear cost cache" }
    static var notifications: String { isGerman ? "Benachrichtigungen" : "Notifications" }
    static var notificationsCaption: String { isGerman ? "Löst Test-Benachrichtigungen für das 5-Stunden-Sitzungsfenster aus (aufgebraucht/wiederhergestellt)." : "Trigger test notifications for the 5-hour session window (depleted/restored)." }
    static var postDepleted: String { isGerman ? "Aufgebraucht senden" : "Post depleted" }
    static var postRestored: String { isGerman ? "Wiederhergestellt senden" : "Post restored" }
    static var cliSessions: String { isGerman ? "CLI-Sitzungen" : "CLI sessions" }
    static var cliSessionsCaption: String { isGerman ? "Hält Codex/Claude-CLI-Sitzungen nach einer Probe offen. Standardmäßig wird nach der Datenerfassung beendet." : "Keep Codex/Claude CLI sessions alive after a probe. Default exits once data is captured." }
    static var keepCLISessionsAlive: String { isGerman ? "CLI-Sitzungen offen halten" : "Keep CLI sessions alive" }
    static var keepCLISessionsAliveSubtitle: String { isGerman ? "Überspringt das Teardown zwischen Probes (nur Debug)." : "Skip teardown between probes (debug-only)." }
    static var resetCLISessions: String { isGerman ? "CLI-Sitzungen zurücksetzen" : "Reset CLI sessions" }
    static var errorSimulation: String { isGerman ? "Fehlersimulation" : "Error simulation" }
    static var errorSimulationCaption: String { isGerman ? "Injiziert eine künstliche Fehlermeldung in die Menükarte für Layout-Tests." : "Inject a fake error message into the menu card for layout testing." }
    static var simulatedErrorText: String { isGerman ? "Simulierter Fehlertext" : "Simulated error text" }
    static var setMenuError: String { isGerman ? "Menüfehler setzen" : "Set menu error" }
    static var clearMenuError: String { isGerman ? "Menüfehler löschen" : "Clear menu error" }
    static var setCostError: String { isGerman ? "Kostenfehler setzen" : "Set cost error" }
    static var clearCostError: String { isGerman ? "Kostenfehler löschen" : "Clear cost error" }
    static var cliPaths: String { isGerman ? "CLI-Pfade" : "CLI paths" }
    static var cliPathsCaption: String { isGerman ? "Aufgelöste Codex-Binaries und PATH-Ebenen; Login-Shell-PATH beim Start (kurzes Timeout)." : "Resolved Codex binary and PATH layers; startup login PATH capture (short timeout)." }
    static var codexBinary: String { isGerman ? "Codex-Binary" : "Codex binary" }
    static var claudeBinary: String { isGerman ? "Claude-Binary" : "Claude binary" }
    static var effectivePath: String { isGerman ? "Effektiver PATH" : "Effective PATH" }
    static var unavailable: String { isGerman ? "Nicht verfügbar" : "Unavailable" }
    static var loginShellPathStartup: String { isGerman ? "Login-Shell-PATH (Startaufnahme)" : "Login shell PATH (startup capture)" }
    static var loadingLogStatus: String { isGerman ? "Lädt…" : "Loading…" }
    static var noLogYetFetchToLoad: String { isGerman ? "Noch kein Log. Lade eins, um es anzuzeigen." : "No log yet. Fetch to load." }
    static var notFound: String { isGerman ? "Nicht gefunden" : "Not found" }
    static func failed(_ error: String) -> String { isGerman ? "Fehlgeschlagen: \(error)" : "Failed: \(error)" }
    static var cleared: String { isGerman ? "Geleert." : "Cleared." }
    static var noFetchAttemptsYet: String { isGerman ? "Noch keine Abrufversuche." : "No fetch attempts yet." }
    static var available: String { isGerman ? "verfügbar" : "available" }
    static var unavailableLower: String { isGerman ? "nicht verfügbar" : "unavailable" }
}

// MARK: - Localization Strings

struct LocalizationStrings: Codable {
    let appName: String
    let version: String
    let openMenu: String
    let openSettings: String
    let quit: String
    let provider: String
    let providers: String
    let account: String
    let accounts: String
    let noAccountsDetected: String
    let chooseAccount: String
    let settings: String
    let general: String
    let display: String
    let advanced: String
    let install: String
    let uninstall: String
    let update: String
    let refresh: String
    let save: String
    let cancel: String
    let done: String
    let active: String
    let inactive: String
    let enabled: String
    let disabled: String
    let loading: String
    let error: String
    let success: String
    let usage: String
    let credits: String
    let session: String
    let weekly: String
    let resetIn: String
    let resetsIn: String
    let about: String
    let built: String
    let license: String
    let updateChannel: String
    let checkForUpdates: String
    let updatesUnavailable: String
    
    static let english = LocalizationStrings(
        appName: "Clawbar",
        version: "Version",
        openMenu: "Open menu",
        openSettings: "Open Settings",
        quit: "Quit Clawbar",
        provider: "Provider",
        providers: "Providers",
        account: "Account",
        accounts: "Accounts",
        noAccountsDetected: "No accounts detected yet.",
        chooseAccount: "Choose which account Clawbar should follow.",
        settings: "Settings",
        general: "General",
        display: "Display",
        advanced: "Advanced",
        install: "Install",
        uninstall: "Uninstall",
        update: "Update",
        refresh: "Refresh",
        save: "Save",
        cancel: "Cancel",
        done: "Done",
        active: "Active",
        inactive: "Inactive",
        enabled: "Enabled",
        disabled: "Disabled",
        loading: "Loading...",
        error: "Error",
        success: "Success",
        usage: "Usage",
        credits: "Credits",
        session: "Session",
        weekly: "Weekly",
        resetIn: "Reset in",
        resetsIn: "Resets in",
        about: "About",
        built: "Built",
        license: "MIT License",
        updateChannel: "Update Channel",
        checkForUpdates: "Check for Updates",
        updatesUnavailable: "Updates unavailable in this build."
    )
    
    static let german = LocalizationStrings(
        appName: "Clawbar",
        version: "Version",
        openMenu: "Menü öffnen",
        openSettings: "Einstellungen öffnen",
        quit: "Clawbar beenden",
        provider: "Anbieter",
        providers: "Anbieter",
        account: "Konto",
        accounts: "Konten",
        noAccountsDetected: "Noch keine Konten erkannt.",
        chooseAccount: "Wähle welches Konto Clawbar nutzen soll.",
        settings: "Einstellungen",
        general: "Allgemein",
        display: "Darstellung",
        advanced: "Erweitert",
        install: "Installieren",
        uninstall: "Deinstallieren",
        update: "Aktualisieren",
        refresh: "Aktualisieren",
        save: "Speichern",
        cancel: "Abbrechen",
        done: "Fertig",
        active: "Aktiv",
        inactive: "Inaktiv",
        enabled: "Aktiviert",
        disabled: "Deaktiviert",
        loading: "Lädt...",
        error: "Fehler",
        success: "Erfolg",
        usage: "Nutzung",
        credits: "Guthaben",
        session: "Sitzung",
        weekly: "Wöchentlich",
        resetIn: "Zurücksetzen in",
        resetsIn: "Zurückgesetzt in",
        about: "Über",
        built: "Erstellt",
        license: "MIT Lizenz",
        updateChannel: "Update-Kanal",
        checkForUpdates: "Nach Updates suchen",
        updatesUnavailable: "Updates in diesem Build nicht verfügbar."
    )
}
