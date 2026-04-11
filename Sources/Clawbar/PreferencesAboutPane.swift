import AppKit
import SwiftUI

@MainActor
struct AboutPane: View {
    @Environment(\.colorScheme) private var colorScheme
    let updater: UpdaterProviding
    @State private var iconHover = false
    @AppStorage("autoUpdateEnabled") private var autoUpdateEnabled: Bool = true
    @AppStorage(UpdateChannel.userDefaultsKey)
    private var updateChannelRaw: String = UpdateChannel.defaultChannel.rawValue
    @State private var didLoadUpdaterState = false

    private var versionString: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return build.map { "\(version) (\($0))" } ?? version
    }

    private var buildTimestamp: String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "CodexBuildTimestamp") as? String else { return nil }
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime]
        guard let date = parser.date(from: raw) else { return raw }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = .current
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 12) {
            if let image = NSApplication.shared.applicationIconImage {
                Button(action: self.openProjectHome) {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .scaleEffect(self.iconHover ? 1.06 : 1.0)
                        .shadow(
                            color: ClawbarTheme.accent.opacity(self.iconHover ? 0.55 : 0.20),
                            radius: self.iconHover ? 20 : 10,
                            x: 0,
                            y: self.iconHover ? 6 : 3)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.spring(response: 0.30, dampingFraction: 0.72)) {
                        self.iconHover = hovering
                    }
                }
            }

            VStack(spacing: 2) {
                ClawbarSectionEyebrow(text: L10n.aboutEyebrow)
                Text(L10n.appName)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                Text(L10n.versionString(self.versionString))
                    .foregroundStyle(ClawbarTheme.mutedText(for: self.colorScheme))
                if let buildTimestamp {
                    Text(L10n.builtString(buildTimestamp))
                        .font(.footnote)
                        .foregroundStyle(ClawbarTheme.mutedText(for: self.colorScheme))
                }
                Text(L10n.aboutSubtitle)
                    .font(.footnote)
                    .foregroundStyle(ClawbarTheme.mutedText(for: self.colorScheme))
            }

            VStack(alignment: .center, spacing: 10) {
                AboutLinkRow(
                    icon: "chevron.left.slash.chevron.right",
                    title: L10n.github,
                    url: "https://github.com/blacki2016/Clawbar")
                AboutLinkRow(icon: "arrow.down.circle", title: L10n.releases, url: "https://github.com/blacki2016/Clawbar/releases")
                AboutLinkRow(icon: "book", title: L10n.documentation, url: "https://github.com/blacki2016/Clawbar#installation")
                AboutLinkRow(icon: "ladybug", title: L10n.reportIssue, url: "https://github.com/blacki2016/Clawbar/issues")
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

            Divider()

            if self.updater.isAvailable {
                VStack(spacing: 10) {
                    Toggle(L10n.autoUpdateToggle, isOn: self.$autoUpdateEnabled)
                        .toggleStyle(.checkbox)
                        .frame(maxWidth: .infinity, alignment: .center)
                    VStack(spacing: 6) {
                        HStack(spacing: 12) {
                            Text(L10n.updateChannel)
                            Spacer()
                            Picker("", selection: self.updateChannelBinding) {
                                ForEach(UpdateChannel.allCases) { channel in
                                    Text(channel.displayName).tag(channel)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        .frame(maxWidth: 280)
                        Text(self.updateChannel.description)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 280)
                    }
                    Button(L10n.checkForUpdatesEllipsis) { self.updater.checkForUpdates(nil) }
                }
            } else {
                Text(self.updater.unavailableReason ?? L10n.updatesUnavailable)
                    .foregroundStyle(.secondary)
            }

            Text(L10n.copyrightLine)
                .font(.footnote)
                .foregroundStyle(ClawbarTheme.mutedText(for: self.colorScheme))
                .padding(.top, 4)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 4)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .onAppear {
            guard !self.didLoadUpdaterState else { return }
            // Align Sparkle's flag with the persisted preference on first load.
            self.updater.automaticallyChecksForUpdates = self.autoUpdateEnabled
            self.updater.automaticallyDownloadsUpdates = self.autoUpdateEnabled
            self.didLoadUpdaterState = true
        }
        .onChange(of: self.autoUpdateEnabled) { _, newValue in
            self.updater.automaticallyChecksForUpdates = newValue
            self.updater.automaticallyDownloadsUpdates = newValue
        }
    }

    private var updateChannel: UpdateChannel {
        UpdateChannel(rawValue: self.updateChannelRaw) ?? .stable
    }

    private var updateChannelBinding: Binding<UpdateChannel> {
        Binding(
            get: { self.updateChannel },
            set: { newValue in
                self.updateChannelRaw = newValue.rawValue
                self.updater.checkForUpdates(nil)
            })
    }

    private func openProjectHome() {
        guard let url = URL(string: "https://github.com/blacki2016/Clawbar") else { return }
        NSWorkspace.shared.open(url)
    }
}
