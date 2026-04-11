import AppKit
import SwiftUI

enum ClawbarTheme {
    // MARK: - Brand Colors (matches website design system)
    // Primary: #7c3aed (purple)
    static let accentNSColor = NSColor(srgbRed: 0.486, green: 0.227, blue: 0.929, alpha: 1)
    // Cyan: #22d3ee
    static let seaNSColor = NSColor(srgbRed: 0.133, green: 0.827, blue: 0.933, alpha: 1)
    // Warning: slightly muted purple-red
    static let warningNSColor = NSColor(srgbRed: 0.77, green: 0.29, blue: 0.28, alpha: 1)
    // Orange: #f97316
    static let orangeNSColor = NSColor(srgbRed: 0.976, green: 0.451, blue: 0.086, alpha: 1)

    static let accent = Color(nsColor: accentNSColor)
    static let sea = Color(nsColor: seaNSColor)
    static let warning = Color(nsColor: warningNSColor)
    static let orange = Color(nsColor: orangeNSColor)

    static func windowBackground(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
            // #06060f — deep near-black from website
            Color(red: 0.024, green: 0.024, blue: 0.059)
        default:
            Color(red: 0.97, green: 0.96, blue: 0.99)
        }
    }

    static func panelBackground(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
            // #0d0d22 — dark panel
            Color(red: 0.051, green: 0.051, blue: 0.133)
        default:
            Color(red: 0.99, green: 0.98, blue: 1.00)
        }
    }

    static func panelSecondaryBackground(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
            // #131330 — slightly lighter panel
            Color(red: 0.075, green: 0.075, blue: 0.188)
        default:
            Color(red: 0.96, green: 0.95, blue: 0.99)
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
            return darkMode ? self.accent.opacity(0.20) : self.accent.opacity(0.12)
        }
        return darkMode
            // #0d0d22 variant for cards
            ? Color(red: 0.075, green: 0.075, blue: 0.188)
            : Color(red: 0.98, green: 0.97, blue: 1.00)
    }

    static func menuCardStroke(highlighted: Bool, darkMode: Bool) -> Color {
        if highlighted {
            return darkMode ? self.sea.opacity(0.42) : self.accent.opacity(0.34)
        }
        return darkMode ? self.accent.opacity(0.12) : Color.black.opacity(0.07)
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
