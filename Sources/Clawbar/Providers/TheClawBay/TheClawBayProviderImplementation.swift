import AppKit
import ClawbarCore
import ClawbarMacroSupport
import Foundation

@ProviderImplementationRegistration
struct TheClawBayProviderImplementation: ProviderImplementation {
    let id: UsageProvider = .theclawbay

    @MainActor
    func presentation(context _: ProviderPresentationContext) -> ProviderPresentation {
        ProviderPresentation { _ in "api" }
    }

    @MainActor
    func observeSettings(_ settings: SettingsStore) {
        _ = settings.theClawBayAPIToken
    }

    @MainActor
    func isAvailable(context: ProviderAvailabilityContext) -> Bool {
        if TheClawBaySettingsReader.apiKey(environment: context.environment) != nil {
            return true
        }
        return !context.settings.theClawBayAPIToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @MainActor
    func settingsFields(context: ProviderSettingsContext) -> [ProviderSettingsFieldDescriptor] {
        [
            ProviderSettingsFieldDescriptor(
                id: "theclawbay-api-key",
                title: "API key",
                subtitle: "Stored in ~/.clawbar/config.json. Paste your theclawbay API key.",
                kind: .secure,
                placeholder: "ca_v1...",
                binding: context.stringBinding(\.theClawBayAPIToken),
                actions: [
                    ProviderSettingsActionDescriptor(
                        id: "theclawbay-open-docs",
                        title: "Open theclawbay Docs",
                        style: .link,
                        isVisible: nil,
                        perform: {
                            if let url = URL(string: "https://theclawbay.com/docs") {
                                NSWorkspace.shared.open(url)
                            }
                        }),
                ],
                isVisible: nil,
                onActivate: nil),
        ]
    }
}
