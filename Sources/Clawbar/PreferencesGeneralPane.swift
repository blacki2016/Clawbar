import AppKit
import ClawbarCore
import SwiftUI

@MainActor
struct GeneralPane: View {
    @Bindable var settings: SettingsStore
    @Bindable var store: UsageStore
    @ObservedObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 18) {
                // Language Section
                SettingsSection(title: L10n.settings, caption: L10n.languageAndBehaviorCaption) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.language)
                                .font(.body)
                            Text(L10n.preferredLanguageSubtitle)
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        Picker(L10n.language, selection: Binding(
                            get: { self.localizationManager.currentLanguage },
                            set: { self.localizationManager.currentLanguage = $0 }
                        )) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .frame(maxWidth: 150)
                    }
                }

                SettingsSection(title: L10n.systemSectionTitle, caption: L10n.systemSectionCaption) {
                    PreferenceToggleRow(
                        title: L10n.startAtLogin,
                        subtitle: L10n.startAtLoginSubtitle,
                        binding: self.$settings.launchAtLogin)
                }

                SettingsSection(title: L10n.usageIntelligenceTitle, caption: L10n.usageIntelligenceCaption) {
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle(isOn: self.$settings.costUsageEnabled) {
                                Text(L10n.showCostSummary)
                                    .font(.body)
                            }
                            .toggleStyle(.checkbox)

                            Text(L10n.showCostSummarySubtitle)
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                                .fixedSize(horizontal: false, vertical: true)

                            if self.settings.costUsageEnabled {
                                Text(L10n.autoRefreshHourlyTimeout)
                                    .font(.footnote)
                                    .foregroundStyle(.tertiary)

                                self.costStatusLine(provider: .claude)
                                self.costStatusLine(provider: .codex)
                            }
                        }
                    }
                }

                SettingsSection(title: L10n.automationTitle, caption: L10n.automationCaption) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.refreshCadence)
                                    .font(.body)
                                Text(L10n.refreshCadenceSubtitle)
                                    .font(.footnote)
                                    .foregroundStyle(.tertiary)
                            }
                            Spacer()
                            Picker(L10n.refreshCadence, selection: self.$settings.refreshFrequency) {
                                ForEach(RefreshFrequency.allCases) { option in
                                    Text(option.label).tag(option)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .frame(maxWidth: 200)
                        }
                        if self.settings.refreshFrequency == .manual {
                            Text(L10n.autoRefreshOff)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    PreferenceToggleRow(
                        title: L10n.checkProviderStatus,
                        subtitle: L10n.checkProviderStatusSubtitle,
                        binding: self.$settings.statusChecksEnabled)
                    PreferenceToggleRow(
                        title: L10n.sessionQuotaNotifications,
                        subtitle: L10n.sessionQuotaNotificationsSubtitle,
                        binding: self.$settings.sessionQuotaNotificationsEnabled)
                }

                SettingsSection(title: L10n.sessionSectionTitle, caption: L10n.sessionSectionCaption) {
                    HStack {
                        Spacer()
                        Button(L10n.quit) { NSApp.terminate(nil) }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private func costStatusLine(provider: UsageProvider) -> some View {
        let name = ProviderDescriptorRegistry.descriptor(for: provider).metadata.displayName

        guard provider == .claude || provider == .codex else {
            return Text("\(name): \(L10n.unsupported)")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }

        if self.store.isTokenRefreshInFlight(for: provider) {
            let elapsed: String = {
                guard let startedAt = self.store.tokenLastAttemptAt(for: provider) else { return "" }
                let seconds = max(0, Date().timeIntervalSince(startedAt))
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = seconds < 60 ? [.second] : [.minute, .second]
                formatter.unitsStyle = .abbreviated
                return formatter.string(from: seconds).map { " (\($0))" } ?? ""
            }()
            return Text("\(name): \(L10n.fetching)…\(elapsed)")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        if let snapshot = self.store.tokenSnapshot(for: provider) {
            let updated = UsageFormatter.updatedString(from: snapshot.updatedAt)
            let cost = snapshot.last30DaysCostUSD.map { UsageFormatter.usdString($0) } ?? "—"
            return Text("\(name): \(updated) · 30d \(cost)")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        if let error = self.store.tokenError(for: provider), !error.isEmpty {
            let truncated = UsageFormatter.truncatedSingleLine(error, max: 120)
            return Text("\(name): \(truncated)")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        if let lastAttempt = self.store.tokenLastAttemptAt(for: provider) {
            let rel = RelativeDateTimeFormatter()
            rel.unitsStyle = .abbreviated
            let when = rel.localizedString(for: lastAttempt, relativeTo: Date())
            return Text("\(name): \(L10n.lastAttempt) \(when)")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        return Text("\(name): \(L10n.noDataYet)")
            .font(.footnote)
            .foregroundStyle(.tertiary)
    }
}
