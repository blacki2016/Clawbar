import AppKit
import SwiftUI

enum PreferencesTab: String, Hashable {
    case general
    case providers
    case display
    case advanced
    case about
    case debug

    static let defaultWidth: CGFloat = 496
    static let providersWidth: CGFloat = 720
    static let windowHeight: CGFloat = 580

    var preferredWidth: CGFloat {
        self == .providers ? PreferencesTab.providersWidth : PreferencesTab.defaultWidth
    }

    var preferredHeight: CGFloat {
        PreferencesTab.windowHeight
    }
}

@MainActor
struct PreferencesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Bindable var settings: SettingsStore
    @Bindable var store: UsageStore
    let updater: UpdaterProviding
    @Bindable var selection: PreferencesSelection
    let managedCodexAccountCoordinator: ManagedCodexAccountCoordinator
    let codexAccountPromotionCoordinator: CodexAccountPromotionCoordinator
    @State private var contentWidth: CGFloat = PreferencesTab.general.preferredWidth
    @State private var contentHeight: CGFloat = PreferencesTab.general.preferredHeight

    init(
        settings: SettingsStore,
        store: UsageStore,
        updater: UpdaterProviding,
        selection: PreferencesSelection,
        managedCodexAccountCoordinator: ManagedCodexAccountCoordinator = ManagedCodexAccountCoordinator(),
        codexAccountPromotionCoordinator: CodexAccountPromotionCoordinator? = nil)
    {
        self.settings = settings
        self.store = store
        self.updater = updater
        self.selection = selection
        self.managedCodexAccountCoordinator = managedCodexAccountCoordinator
        self.codexAccountPromotionCoordinator = codexAccountPromotionCoordinator
            ?? CodexAccountPromotionCoordinator(
                settingsStore: settings,
                usageStore: store,
                managedAccountCoordinator: managedCodexAccountCoordinator)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PreferencesHeroCard()

            TabView(selection: self.$selection.tab) {
                GeneralPane(settings: self.settings, store: self.store)
                    .tabItem { Label(L10n.overviewTab, systemImage: "sparkles.rectangle.stack") }
                    .tag(PreferencesTab.general)

                ProvidersPane(
                    settings: self.settings,
                    store: self.store,
                    managedCodexAccountCoordinator: self.managedCodexAccountCoordinator,
                    codexAccountPromotionCoordinator: self.codexAccountPromotionCoordinator)
                    .tabItem { Label(L10n.providers, systemImage: "point.3.connected.trianglepath.dotted") }
                    .tag(PreferencesTab.providers)

                DisplayPane(settings: self.settings, store: self.store)
                    .tabItem { Label(L10n.menubarTab, systemImage: "capsule.portrait") }
                    .tag(PreferencesTab.display)

                AdvancedPane(settings: self.settings)
                    .tabItem { Label(L10n.toolsTab, systemImage: "wrench.and.screwdriver") }
                    .tag(PreferencesTab.advanced)

                AboutPane(updater: self.updater)
                    .tabItem { Label(L10n.about, systemImage: "squareshape.split.2x2") }
                    .tag(PreferencesTab.about)

                if self.settings.debugMenuEnabled {
                    DebugPane(settings: self.settings, store: self.store)
                        .tabItem { Label(L10n.debugTab, systemImage: "ladybug") }
                        .tag(PreferencesTab.debug)
                }
            }
        }
        .id(self.localizationManager.currentLanguage)
        .tint(ClawbarTheme.accent)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(ClawbarTheme.windowBackground(for: self.colorScheme).ignoresSafeArea())
        .frame(width: self.contentWidth, height: self.contentHeight)
        .onAppear {
            self.updateLayout(for: self.selection.tab, animate: false)
            self.ensureValidTabSelection()
        }
        .onChange(of: self.selection.tab) { _, newValue in
            self.updateLayout(for: newValue, animate: true)
        }
        .onChange(of: self.settings.debugMenuEnabled) { _, _ in
            self.ensureValidTabSelection()
        }
    }

    private func updateLayout(for tab: PreferencesTab, animate: Bool) {
        let change = {
            self.contentWidth = tab.preferredWidth
            self.contentHeight = tab.preferredHeight
        }
        if animate {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) { change() }
        } else {
            change()
        }
    }

    private func ensureValidTabSelection() {
        if !self.settings.debugMenuEnabled, self.selection.tab == .debug {
            self.selection.tab = .general
            self.updateLayout(for: .general, animate: true)
        }
    }
}

private struct PreferencesHeroCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Clawbar logo with brand-colored glow
            ClawbarLogoImage(size: 56)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(
                    color: ClawbarTheme.accent.opacity(self.colorScheme == .dark ? 0.55 : 0.30),
                    radius: 14,
                    x: 0,
                    y: 4)

            VStack(alignment: .leading, spacing: 4) {
                ClawbarSectionEyebrow(text: L10n.heroEyebrow)
                Text(L10n.heroTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(L10n.heroSubtitle)
                    .font(.footnote)
                    .foregroundStyle(ClawbarTheme.mutedText(for: self.colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ClawbarTheme.accent.opacity(self.colorScheme == .dark ? 0.14 : 0.07),
                            ClawbarTheme.sea.opacity(self.colorScheme == .dark ? 0.07 : 0.04),
                            ClawbarTheme.panelBackground(for: self.colorScheme),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            ClawbarTheme.accent.opacity(0.40),
                            ClawbarTheme.sea.opacity(0.22),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing),
                    lineWidth: 1))
    }
}
