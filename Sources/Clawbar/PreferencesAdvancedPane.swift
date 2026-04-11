import KeyboardShortcuts
import SwiftUI

@MainActor
struct AdvancedPane: View {
    @Bindable var settings: SettingsStore
    @State private var isInstallingCLI = false
    @State private var cliStatus: String?

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 18) {
                SettingsSection(title: L10n.keyboardControlTitle, caption: L10n.keyboardControlCaption) {
                    HStack(alignment: .center, spacing: 12) {
                        Text(L10n.openMenuAction)
                            .font(.body)
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .openMenu)
                    }
                    Text(L10n.openMenuActionSubtitle)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }

                SettingsSection(title: L10n.cliHandoffTitle, caption: L10n.cliHandoffCaption) {
                    HStack(spacing: 12) {
                        Button {
                            Task { await self.installCLI() }
                        } label: {
                            if self.isInstallingCLI {
                                ProgressView().controlSize(.small)
                            } else {
                                Text(L10n.installCLI)
                            }
                        }
                        .disabled(self.isInstallingCLI)

                        if let status = self.cliStatus {
                            Text(status)
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                                .lineLimit(2)
                        }
                    }
                    Text(L10n.cliHandoffSubtitle)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }

                SettingsSection(title: L10n.diagnosticsTitle, caption: L10n.diagnosticsCaption) {
                    PreferenceToggleRow(
                        title: L10n.showDebugSettings,
                        subtitle: L10n.showDebugSettingsSubtitle,
                        binding: self.$settings.debugMenuEnabled)
                    PreferenceToggleRow(
                        title: L10n.surpriseMe,
                        subtitle: L10n.surpriseMeSubtitle,
                        binding: self.$settings.randomBlinkEnabled)
                }

                SettingsSection(title: L10n.privacyTitle, caption: L10n.privacyCaption) {
                    PreferenceToggleRow(
                        title: L10n.hidePersonalInfo,
                        subtitle: L10n.hidePersonalInfoSubtitle,
                        binding: self.$settings.hidePersonalInfo)
                }

                SettingsSection(
                    title: L10n.keychainAccessTitle,
                    caption: L10n.keychainAccessCaption) {
                        PreferenceToggleRow(
                            title: L10n.disableKeychainAccess,
                            subtitle: L10n.disableKeychainAccessSubtitle,
                            binding: self.$settings.debugDisableKeychainAccess)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}

extension AdvancedPane {
    private func installCLI() async {
        if self.isInstallingCLI { return }
        self.isInstallingCLI = true
        defer { self.isInstallingCLI = false }

        let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/clawbar")
        let fm = FileManager.default
        guard fm.fileExists(atPath: helperURL.path) else {
            self.cliStatus = L10n.cliHelperNotFound
            return
        }

        let destinations = [
            "/usr/local/bin/clawbar",
            "/opt/homebrew/bin/clawbar",
        ]

        var results: [String] = []
        for dest in destinations {
            let dir = (dest as NSString).deletingLastPathComponent
            guard fm.fileExists(atPath: dir) else { continue }
            guard fm.isWritableFile(atPath: dir) else {
                results.append(L10n.noWriteAccess(dir))
                continue
            }

            if fm.fileExists(atPath: dest) {
                if Self.isLink(atPath: dest, pointingTo: helperURL.path) {
                    results.append(L10n.installedIn(dir))
                } else {
                    results.append(L10n.existsIn(dir))
                }
                continue
            }

            do {
                try fm.createSymbolicLink(atPath: dest, withDestinationPath: helperURL.path)
                results.append(L10n.installedIn(dir))
            } catch {
                results.append(L10n.failedIn(dir))
            }
        }

        self.cliStatus = results.isEmpty
            ? L10n.noWritableBinDirs
            : results.joined(separator: " · ")
    }

    private static func isLink(atPath path: String, pointingTo destination: String) -> Bool {
        guard let link = try? FileManager.default.destinationOfSymbolicLink(atPath: path) else { return false }
        let dir = (path as NSString).deletingLastPathComponent
        let resolved = URL(fileURLWithPath: link, relativeTo: URL(fileURLWithPath: dir))
            .standardizedFileURL
            .path
        return resolved == destination
    }
}
