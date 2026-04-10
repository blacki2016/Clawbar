import AppKit
import SwiftUI

@MainActor
struct PreferenceToggleRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let subtitle: String?
    @Binding var binding: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: self.$binding) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.title)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(ClawbarTheme.mutedText(for: self.colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .toggleStyle(.switch)
            .controlSize(.small)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ClawbarTheme.panelSecondaryBackground(for: self.colorScheme)))
    }
}

@MainActor
struct SettingsSection<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String?
    let caption: String?
    let contentSpacing: CGFloat
    private let content: () -> Content

    init(
        title: String? = nil,
        caption: String? = nil,
        contentSpacing: CGFloat = 14,
        @ViewBuilder content: @escaping () -> Content)
    {
        self.title = title
        self.caption = caption
        self.contentSpacing = contentSpacing
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title, !title.isEmpty {
                ClawbarSectionEyebrow(text: title)
            }
            if let caption, !caption.isEmpty {
                Text(caption)
                    .font(.footnote)
                    .foregroundStyle(ClawbarTheme.mutedText(for: self.colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }
            VStack(alignment: .leading, spacing: self.contentSpacing) {
                self.content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(ClawbarTheme.panelBackground(for: self.colorScheme)))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(ClawbarTheme.panelStroke(for: self.colorScheme), lineWidth: 1))
    }
}

@MainActor
struct AboutLinkRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let title: String
    let url: String
    @State private var hovering = false

    var body: some View {
        Button {
            if let url = URL(string: self.url) { NSWorkspace.shared.open(url) }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: self.icon)
                Text(self.title)
                    .underline(self.hovering, color: ClawbarTheme.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(ClawbarTheme.panelSecondaryBackground(for: self.colorScheme)))
            .foregroundColor(ClawbarTheme.accent)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { self.hovering = $0 }
    }
}
