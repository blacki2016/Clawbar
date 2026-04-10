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
                SettingsSection(title: "Keyboard control", caption: "Jump into Clawbar without touching the pointer.") {
                    HStack(alignment: .center, spacing: 12) {
                        Text("Open menu")
                            .font(.body)
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .openMenu)
                    }
                    Text("Trigger the menu bar menu from anywhere.")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }

                SettingsSection(title: "CLI handoff", caption: "Install the bundled helper so scripts can read the same provider state.") {
                    HStack(spacing: 12) {
                        Button {
                            Task { await self.installCLI() }
                        } label: {
                            if self.isInstallingCLI {
                                ProgressView().controlSize(.small)
                            } else {
                                Text("Install CLI")
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
                    Text("Symlink the bundled clawbar helper to /usr/local/bin and /opt/homebrew/bin.")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }

                SettingsSection(title: "Diagnostics", caption: "Reveal troubleshooting tools and optional visual behavior.") {
                    PreferenceToggleRow(
                        title: "Show Debug Settings",
                        subtitle: "Expose troubleshooting tools in the Debug tab.",
                        binding: self.$settings.debugMenuEnabled)
                    PreferenceToggleRow(
                        title: "Surprise me",
                        subtitle: "Check if you like your agents having some fun up there.",
                        binding: self.$settings.randomBlinkEnabled)
                }

                SettingsSection(title: "Privacy", caption: "Reduce on-screen personal data when you demo or record the app.") {
                    PreferenceToggleRow(
                        title: "Hide personal information",
                        subtitle: "Obscure email addresses in the menu bar and menu UI.",
                        binding: self.$settings.hidePersonalInfo)
                }

                SettingsSection(
                    title: "Keychain access",
                    caption: """
                    Disable all Keychain reads and writes. Browser cookie import is unavailable; paste Cookie \
                    headers manually in Providers.
                    """) {
                        PreferenceToggleRow(
                            title: "Disable Keychain access",
                            subtitle: "Prevents any Keychain access while enabled.",
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
            self.cliStatus = "clawbar helper not found in app bundle."
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
                results.append("No write access: \(dir)")
                continue
            }

            if fm.fileExists(atPath: dest) {
                if Self.isLink(atPath: dest, pointingTo: helperURL.path) {
                    results.append("Installed: \(dir)")
                } else {
                    results.append("Exists: \(dir)")
                }
                continue
            }

            do {
                try fm.createSymbolicLink(atPath: dest, withDestinationPath: helperURL.path)
                results.append("Installed: \(dir)")
            } catch {
                results.append("Failed: \(dir)")
            }
        }

        self.cliStatus = results.isEmpty
            ? "No writable bin dirs found."
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
