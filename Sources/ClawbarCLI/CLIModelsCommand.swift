import ClawbarCore
import Commander
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct ModelsOptions: CommanderParsable {
    @Flag(names: [.short("v"), .long("verbose")], help: "Enable verbose logging")
    var verbose: Bool = false

    @Flag(name: .long("json-output"), help: "Emit machine-readable logs")
    var jsonOutput: Bool = false

    @Option(name: .long("log-level"), help: "Set log level (trace|verbose|debug|info|warning|error|critical)")
    var logLevel: String?

    @Option(name: .long("format"), help: "Output format: text | json")
    var format: OutputFormat?

    @Flag(name: .long("json"), help: "")
    var jsonShortcut: Bool = false

    @Flag(name: .long("json-only"), help: "Emit JSON only (suppress non-JSON output)")
    var jsonOnly: Bool = false

    @Flag(name: .long("pretty"), help: "Pretty-print JSON output")
    var pretty: Bool = false

    @Flag(name: .long("no-color"), help: "Disable ANSI colors in text output")
    var noColor: Bool = false
}

struct TheClawBayModel: Codable, Sendable {
    let id: String
    let object: String?
    let created: Int?
    let ownedBy: String?

    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case ownedBy = "owned_by"
    }
}

struct TheClawBayModelsResponse: Codable, Sendable {
    let object: String?
    let data: [TheClawBayModel]
}

struct ProviderModelsPayload: Codable, Sendable {
    let provider: String
    let enabled: Bool
    let modelsAvailable: Bool
    let models: [String]?
    let modelCount: Int?
    let error: String?
}

extension ClawbarCLI {
    static func runModels(_ values: ParsedValues) async {
        let output = CLIOutputPreferences.from(values: values)
        let config = Self.loadConfig(output: output)

        // Build list of all configured providers
        let allProviders = config.providers.map(\.id)
        let enabledSet = Set(config.enabledProviders())

        // Providers that have a models API
        let modelsAPIProviders: Set<UsageProvider> = [.theclawbay]

        // Fetch models for providers that support it
        var payloads: [ProviderModelsPayload] = []

        for provider in allProviders {
            let isEnabled = enabledSet.contains(provider)
            let hasModelsAPI = modelsAPIProviders.contains(provider)

            if hasModelsAPI, let apiKey = config.providerConfig(for: provider)?.sanitizedAPIKey, !apiKey.isEmpty {
                do {
                    let response = try await Self.fetchTheClawBayModels(apiKey: apiKey)
                    let ids = response.data.map(\.id).sorted()
                    payloads.append(ProviderModelsPayload(
                        provider: provider.rawValue,
                        enabled: isEnabled,
                        modelsAvailable: true,
                        models: ids,
                        modelCount: ids.count,
                        error: nil))
                } catch {
                    payloads.append(ProviderModelsPayload(
                        provider: provider.rawValue,
                        enabled: isEnabled,
                        modelsAvailable: false,
                        models: nil,
                        modelCount: nil,
                        error: error.localizedDescription))
                }
            } else {
                payloads.append(ProviderModelsPayload(
                    provider: provider.rawValue,
                    enabled: isEnabled,
                    modelsAvailable: hasModelsAPI,
                    models: nil,
                    modelCount: hasModelsAPI ? 0 : nil,
                    error: hasModelsAPI ? "no API key" : nil))
            }
        }

        switch output.format {
        case .json:
            Self.printJSON(payloads, pretty: output.pretty)
        case .text:
            Self.printProvidersTable(payloads)
        }

        Self.exit(code: .success, output: output, kind: .runtime)
    }

    private static func printProvidersTable(_ payloads: [ProviderModelsPayload]) {
        // Header
        print("Provider            Enabled   Models")
        print("────────────────── ──────── ───────────────────")

        for p in payloads {
            let name = p.provider.padding(toLength: 19, withPad: " ", startingAt: 0)
            let enabledStr = p.enabled ? "  yes" : "   no"
            let modelsStr: String
            if let count = p.modelCount, count > 0 {
                modelsStr = "\(count) available"
            } else if p.modelsAvailable {
                modelsStr = "no API key"
            } else {
                modelsStr = "–"
            }
            print("\(name) \(enabledStr)   \(modelsStr)")
        }
    }

    static func fetchTheClawBayModels(apiKey: String) async throws -> TheClawBayModelsResponse {
        guard let url = URL(string: "https://api.theclawbay.com/v1/models") else {
            throw CLIArgumentError("Invalid theclawbay models URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw CLIArgumentError("Invalid response from theclawbay")
        }
        guard http.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw CLIArgumentError("theclawbay models request failed: \(message)")
        }
        return try JSONDecoder().decode(TheClawBayModelsResponse.self, from: data)
    }
}
