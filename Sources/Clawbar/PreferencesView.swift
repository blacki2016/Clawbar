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
                    .tabItem { Label("Overview", systemImage: "sparkles.rectangle.stack") }
                    .tag(PreferencesTab.general)

                ProvidersPane(
                    settings: self.settings,
                    store: self.store,
                    managedCodexAccountCoordinator: self.managedCodexAccountCoordinator,
                    codexAccountPromotionCoordinator: self.codexAccountPromotionCoordinator)
                    .tabItem { Label("Providers", systemImage: "point.3.connected.trianglepath.dotted") }
                    .tag(PreferencesTab.providers)

                DisplayPane(settings: self.settings, store: self.store)
                    .tabItem { Label("Menubar", systemImage: "capsule.portrait") }
                    .tag(PreferencesTab.display)

                AdvancedPane(settings: self.settings)
                    .tabItem { Label("Tools", systemImage: "wrench.and.screwdriver") }
                    .tag(PreferencesTab.advanced)

                AboutPane(updater: self.updater)
                    .tabItem { Label("About", systemImage: "squareshape.split.2x2") }
                    .tag(PreferencesTab.about)

                if self.settings.debugMenuEnabled {
                    DebugPane(settings: self.settings, store: self.store)
                        .tabItem { Label("Debug", systemImage: "ladybug") }
                        .tag(PreferencesTab.debug)
                }
            }
        }
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
        HStack(alignment: .center, spacing: 14) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                ClawbarSectionEyebrow(text: "Clawbar control room")
                Text("Keep quota pressure visible.")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("Tune the menubar, refresh rhythm and provider setup from one branded surface.")
                    .font(.footnote)
                    .foregroundStyle(ClawbarTheme.mutedText(for: self.colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ClawbarTheme.panelBackground(for: self.colorScheme),
                            ClawbarTheme.panelSecondaryBackground(for: self.colorScheme),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(ClawbarTheme.panelStroke(for: self.colorScheme), lineWidth: 1))
    }
}
