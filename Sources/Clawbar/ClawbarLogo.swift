import AppKit
import SwiftUI

/// Loads the `clawbar-logo.png` from the SPM resource bundle.
enum ClawbarLogo {
    /// Lazy-loaded resource bundle (same pattern as ProviderBrandIcon).
    private static let resourceBundle: Bundle? = {
        if let bundleURL = Bundle.main.url(forResource: "Clawbar_Clawbar", withExtension: "bundle"),
           let bundle = Bundle(url: bundleURL)
        {
            return bundle
        }
        return Bundle.main
    }()

    /// Returns the Clawbar logo image at the requested point size, or nil if not found.
    static func image(size: CGFloat = 56) -> NSImage? {
        // Debug: print path
        let bundle = Bundle.main
        print("Bundle main: \(bundle.bundlePath)")
        
        // Try finding clawbar-logo.png in Resources
        if let url = bundle.url(forResource: "clawbar-logo", withExtension: "png") {
            print("Found at: \(url.path)")
            let image = NSImage(contentsOf: url)
            if let img = image {
                img.size = NSSize(width: size, height: size)
            }
            return image
        }
        
        // Fallback: search recursively
        if let url = findImage(named: "clawbar-logo", in: bundle.bundlePath) {
            print("Found recursively: \(url)")
            let image = NSImage(contentsOf: url)
            if let img = image {
                img.size = NSSize(width: size, height: size)
            }
            return image
        }
        
        print("Logo not found, using fallback")
        return nil
    }
    
    private static func findImage(named name: String, in path: String) -> URL? {
        let fm = FileManager.default
        guard let items = try? fm.contentsOfDirectory(atPath: path) else { return nil }
        for item in items {
            let fullPath = (path as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false
            fm.fileExists(atPath: fullPath, isDirectory: &isDir)
            if isDir.boolValue {
                if let found = findImage(named: name, in: fullPath) {
                    return found
                }
            } else if item.hasPrefix(name) && item.hasSuffix(".png") {
                return URL(fileURLWithPath: fullPath)
            }
        }
        return nil
    }
}

/// SwiftUI view that shows `clawbar-logo.png`, falling back to the app icon.
@MainActor
struct ClawbarLogoImage: View {
    var size: CGFloat = 56

    var body: some View {
        let nsImage = ClawbarLogo.image(size: self.size)
            ?? NSApplication.shared.applicationIconImage

        Image(nsImage: nsImage!)
            .resizable()
            .scaledToFit()
            .frame(width: self.size, height: self.size)
    }
}

/// Compact brand header shown at the top of the menu bar popup.
@MainActor
struct ClawbarMenuBrandHeaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    let width: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ClawbarLogoImage(size: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                Text(L10n.appName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            // Gradient separator
            LinearGradient(
                colors: [ClawbarTheme.accent.opacity(0.6), ClawbarTheme.sea.opacity(0.4)],
                startPoint: .leading,
                endPoint: .trailing)
                .frame(height: 1)
                .padding(.horizontal, 10)
        }
        .frame(width: self.width)
        .background(ClawbarTheme.windowBackground(for: self.colorScheme))
    }
}
