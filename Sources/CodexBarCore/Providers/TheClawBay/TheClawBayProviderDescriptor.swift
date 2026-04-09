import CodexBarMacroSupport
import Foundation

@ProviderDescriptorRegistration
@ProviderDescriptorDefinition
public enum TheClawBayProviderDescriptor {
    static func makeDescriptor() -> ProviderDescriptor {
        ProviderDescriptor(
            id: .theclawbay,
            metadata: ProviderMetadata(
                id: .theclawbay,
                displayName: "The Claw Bay",
                sessionLabel: "5h",
                weeklyLabel: "Weekly",
                opusLabel: nil,
                supportsOpus: false,
                supportsCredits: false,
                creditsHint: "",
                toggleTitle: "Show The Claw Bay usage",
                cliName: "theclawbay",
                defaultEnabled: false,
                isPrimaryProvider: false,
                usesAccountFallback: false,
                dashboardURL: "https://theclawbay.com",
                statusPageURL: nil,
                statusLinkURL: "https://theclawbay.com/status"),
            branding: ProviderBranding(
                iconStyle: .theclawbay,
                iconResourceName: "ProviderIcon-theclawbay",
                color: ProviderColor(red: 16 / 255, green: 163 / 255, blue: 127 / 255)),
            tokenCost: ProviderTokenCostConfig(
                supportsTokenCost: false,
                noDataMessage: { "The Claw Bay cost summary is not yet supported." }),
            fetchPlan: ProviderFetchPlan(
                sourceModes: [.auto, .api],
                pipeline: ProviderFetchPipeline(resolveStrategies: { _ in [TheClawBayAPIFetchStrategy()] })),
            cli: ProviderCLIConfig(
                name: "theclawbay",
                aliases: ["tcb"],
                versionDetector: nil))
    }
}

struct TheClawBayAPIFetchStrategy: ProviderFetchStrategy {
    let id: String = "theclawbay.api"
    let kind: ProviderFetchKind = .apiToken

    func isAvailable(_ context: ProviderFetchContext) async -> Bool {
        Self.resolveToken(environment: context.env) != nil
    }

    func fetch(_ context: ProviderFetchContext) async throws -> ProviderFetchResult {
        guard let apiKey = Self.resolveToken(environment: context.env) else {
            throw TheClawBaySettingsError.missingToken
        }
        let usage = try await TheClawBayUsageFetcher.fetchUsage(apiKey: apiKey)
        return self.makeResult(
            usage: usage.toUsageSnapshot(),
            sourceLabel: "api")
    }

    func shouldFallback(on _: Error, context _: ProviderFetchContext) -> Bool {
        false
    }

    private static func resolveToken(environment: [String: String]) -> String? {
        ProviderTokenResolver.theClawBayToken(environment: environment)
    }
}

public enum TheClawBaySettingsError: LocalizedError, Sendable {
    case missingToken

    public var errorDescription: String? {
        switch self {
        case .missingToken:
            "The Claw Bay API token not configured. Set THECLAWBAY_API_KEY or configure it in Settings."
        }
    }
}
