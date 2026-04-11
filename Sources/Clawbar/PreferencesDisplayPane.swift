import ClawbarCore
import SwiftUI

@MainActor
struct DisplayPane: View {
    private static let maxOverviewProviders = SettingsStore.mergedOverviewProviderLimit

    @State private var isOverviewProviderPopoverPresented = false
    @Bindable var settings: SettingsStore
    @Bindable var store: UsageStore

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 18) {
                SettingsSection(title: L10n.menubarSignalTitle, caption: L10n.menubarSignalCaption) {
                    PreferenceToggleRow(
                        title: L10n.mergeIcons,
                        subtitle: L10n.mergeIconsSubtitle,
                        binding: self.$settings.mergeIcons)
                    PreferenceToggleRow(
                        title: L10n.switcherShowsIcons,
                        subtitle: L10n.switcherShowsIconsSubtitle,
                        binding: self.$settings.switcherShowsIcons)
                        .disabled(!self.settings.mergeIcons)
                        .opacity(self.settings.mergeIcons ? 1 : 0.5)
                    PreferenceToggleRow(
                        title: L10n.showMostUsedProvider,
                        subtitle: L10n.showMostUsedProviderSubtitle,
                        binding: self.$settings.menuBarShowsHighestUsage)
                        .disabled(!self.settings.mergeIcons)
                        .opacity(self.settings.mergeIcons ? 1 : 0.5)
                    PreferenceToggleRow(
                        title: L10n.menuBarShowsPercent,
                        subtitle: L10n.menuBarShowsPercentSubtitle,
                        binding: self.$settings.menuBarShowsBrandIconWithPercent)
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.displayMode)
                                .font(.body)
                            Text(L10n.displayModeSubtitle)
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        Picker(L10n.displayMode, selection: self.$settings.menuBarDisplayMode) {
                            ForEach(MenuBarDisplayMode.allCases) { mode in
                                Text(mode.label).tag(mode)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .frame(maxWidth: 200)
                    }
                    .disabled(!self.settings.menuBarShowsBrandIconWithPercent)
                    .opacity(self.settings.menuBarShowsBrandIconWithPercent ? 1 : 0.5)
                }

                SettingsSection(title: L10n.popoverContentTitle, caption: L10n.popoverContentCaption) {
                    PreferenceToggleRow(
                        title: L10n.showUsageAsUsed,
                        subtitle: L10n.showUsageAsUsedSubtitle,
                        binding: self.$settings.usageBarsShowUsed)
                    PreferenceToggleRow(
                        title: L10n.showResetTimeAsClock,
                        subtitle: L10n.showResetTimeAsClockSubtitle,
                        binding: self.$settings.resetTimesShowAbsolute)
                    PreferenceToggleRow(
                        title: L10n.showCreditsExtraUsage,
                        subtitle: L10n.showCreditsExtraUsageSubtitle,
                        binding: self.$settings.showOptionalCreditsAndExtraUsage)
                    PreferenceToggleRow(
                        title: L10n.showAllTokenAccounts,
                        subtitle: L10n.showAllTokenAccountsSubtitle,
                        binding: self.$settings.showAllTokenAccountsInMenu)
                    self.overviewProviderSelector
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .onAppear {
                self.reconcileOverviewSelection()
            }
            .onChange(of: self.settings.mergeIcons) { _, isEnabled in
                guard isEnabled else {
                    self.isOverviewProviderPopoverPresented = false
                    return
                }
                self.reconcileOverviewSelection()
            }
            .onChange(of: self.activeProvidersInOrder) { _, _ in
                if self.activeProvidersInOrder.isEmpty {
                    self.isOverviewProviderPopoverPresented = false
                }
                self.reconcileOverviewSelection()
            }
        }
    }

    private var overviewProviderSelector: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 12) {
                Text(L10n.overviewTabProviders)
                    .font(.body)
                Spacer(minLength: 0)
                if self.showsOverviewConfigureButton {
                    Button(L10n.configure) {
                        self.isOverviewProviderPopoverPresented = true
                    }
                    .offset(y: 1)
                    .popover(isPresented: self.$isOverviewProviderPopoverPresented, arrowEdge: .bottom) {
                        self.overviewProviderPopover
                    }
                }
            }

            if !self.settings.mergeIcons {
                Text(L10n.enableMergeIconsToConfigureOverview)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            } else if self.activeProvidersInOrder.isEmpty {
                Text(L10n.noEnabledProvidersForOverview)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            } else {
                Text(self.overviewProviderSelectionSummary)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
    }

    private var overviewProviderPopover: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.chooseUpToProviders(Self.maxOverviewProviders))
                .font(.headline)
            Text(L10n.overviewRowsFollowProviderOrder)
                .font(.footnote)
                .foregroundStyle(.tertiary)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(self.activeProvidersInOrder, id: \.self) { provider in
                        Toggle(
                            isOn: Binding(
                                get: { self.overviewSelectedProviders.contains(provider) },
                                set: { shouldSelect in
                                    self.setOverviewProviderSelection(provider: provider, isSelected: shouldSelect)
                                })) {
                            Text(self.providerDisplayName(provider))
                                .font(.body)
                        }
                        .toggleStyle(.checkbox)
                        .disabled(
                            !self.overviewSelectedProviders.contains(provider) &&
                                self.overviewSelectedProviders.count >= Self.maxOverviewProviders)
                    }
                }
            }
            .frame(maxHeight: 220)
        }
        .padding(12)
        .frame(width: 280)
    }

    private var activeProvidersInOrder: [UsageProvider] {
        self.store.enabledProviders()
    }

    private var overviewSelectedProviders: [UsageProvider] {
        self.settings.resolvedMergedOverviewProviders(
            activeProviders: self.activeProvidersInOrder,
            maxVisibleProviders: Self.maxOverviewProviders)
    }

    private var showsOverviewConfigureButton: Bool {
        self.settings.mergeIcons && !self.activeProvidersInOrder.isEmpty
    }

    private var overviewProviderSelectionSummary: String {
        let selectedNames = self.overviewSelectedProviders.map(self.providerDisplayName)
        guard !selectedNames.isEmpty else { return L10n.noProvidersSelected }
        return selectedNames.joined(separator: ", ")
    }

    private func providerDisplayName(_ provider: UsageProvider) -> String {
        ProviderDescriptorRegistry.descriptor(for: provider).metadata.displayName
    }

    private func setOverviewProviderSelection(provider: UsageProvider, isSelected: Bool) {
        _ = self.settings.setMergedOverviewProviderSelection(
            provider: provider,
            isSelected: isSelected,
            activeProviders: self.activeProvidersInOrder,
            maxVisibleProviders: Self.maxOverviewProviders)
    }

    private func reconcileOverviewSelection() {
        _ = self.settings.reconcileMergedOverviewSelectedProviders(
            activeProviders: self.activeProvidersInOrder,
            maxVisibleProviders: Self.maxOverviewProviders)
    }
}
