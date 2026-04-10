import AppKit
import SwiftUI

enum ClawbarTheme {
    static let accentNSColor = NSColor(srgbRed: 0.93, green: 0.37, blue: 0.27, alpha: 1)
    static let seaNSColor = NSColor(srgbRed: 0.10, green: 0.70, blue: 0.67, alpha: 1)
    static let warningNSColor = NSColor(srgbRed: 0.77, green: 0.29, blue: 0.28, alpha: 1)

    static let accent = Color(nsColor: accentNSColor)
    static let sea = Color(nsColor: seaNSColor)
    static let warning = Color(nsColor: warningNSColor)

    static func windowBackground(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
            Color(red: 0.08, green: 0.09, blue: 0.12)
        default:
            Color(red: 0.95, green: 0.94, blue: 0.90)
        }
    }

    static func panelBackground(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
            Color(red: 0.13, green: 0.15, blue: 0.19)
        default:
            Color(red: 0.99, green: 0.98, blue: 0.96)
        }
    }

    static func panelSecondaryBackground(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
            Color(red: 0.16, green: 0.18, blue: 0.22)
        default:
            Color(red: 0.97, green: 0.95, blue: 0.92)
        }
    }

    static func panelStroke(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
            self.accent.opacity(0.22)
        default:
            Color.black.opacity(0.08)
        }
    }

    static func mutedText(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
            Color.white.opacity(0.66)
        default:
            Color.black.opacity(0.58)
        }
    }

    static func sectionEyebrow(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
            self.sea
        default:
            self.accent
        }
    }

    static func menuCardBackground(highlighted: Bool, darkMode: Bool) -> Color {
        if highlighted {
            return darkMode ? self.accent.opacity(0.24) : self.accent.opacity(0.16)
        }
        return darkMode
            ? Color(red: 0.14, green: 0.16, blue: 0.20)
            : Color(red: 0.98, green: 0.97, blue: 0.95)
    }

    static func menuCardStroke(highlighted: Bool, darkMode: Bool) -> Color {
        if highlighted {
            return darkMode ? self.sea.opacity(0.42) : self.accent.opacity(0.34)
        }
        return darkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.08)
    }

    static func switcherSelectedBackground() -> CGColor {
        self.accentNSColor.cgColor
    }

    static func switcherHoverBackground(lightMode: Bool) -> CGColor {
        (lightMode ? self.accentNSColor.withAlphaComponent(0.12) : self.seaNSColor.withAlphaComponent(0.16)).cgColor
    }

    static func switcherSelectionText() -> NSColor {
        NSColor.white
    }

    static func switcherText() -> NSColor {
        NSColor.secondaryLabelColor
    }
}

struct ClawbarPanel<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let padding: CGFloat
    @ViewBuilder let content: () -> Content

    init(padding: CGFloat = 16, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.content = content
    }

    var body: some View {
        self.content()
            .padding(self.padding)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(ClawbarTheme.panelBackground(for: self.colorScheme)))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ClawbarTheme.panelStroke(for: self.colorScheme), lineWidth: 1))
            .shadow(
                color: Color.black.opacity(self.colorScheme == .dark ? 0.22 : 0.08),
                radius: self.colorScheme == .dark ? 16 : 12,
                x: 0,
                y: 8)
    }
}

struct ClawbarSectionEyebrow: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String

    var body: some View {
        Text(self.text)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .kerning(0.7)
            .textCase(.uppercase)
            .foregroundStyle(ClawbarTheme.sectionEyebrow(for: self.colorScheme))
    }
}
