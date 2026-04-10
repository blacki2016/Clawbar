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

    @Option(name: .long("provider"), help: "Provider to query: theclawbay")
    var provider: String?
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

extension ClawbarCLI {
    static func runModels(_ values: ParsedValues) async {
        let output = CLIOutputPreferences.from(values: values)
        let config = Self.loadConfig(output: output)
        let provider = (values.options["provider"]?.last ?? "theclawbay").lowercased()

        guard provider == "theclawbay" || provider == "tcb" else {
            Self.exit(
                code: .failure,
                message: "Error: models currently supports only theclawbay.",
                output: output,
                kind: .args)
        }

        guard let apiKey = config.providerConfig(for: .theclawbay)?.sanitizedAPIKey,
              !apiKey.isEmpty
        else {
            Self.exit(
                code: .failure,
                message: "Error: theclawbay API key not found in ~/.codexbar/config.json.",
                output: output,
                kind: .config)
        }

        do {
            let response = try await Self.fetchTheClawBayModels(apiKey: apiKey)
            switch output.format {
            case .json:
                Self.printJSON(response, pretty: output.pretty)
            case .text:
                let ids = response.data.map(\.id).sorted()
                if ids.isEmpty {
                    print("theclawbay: keine Models gefunden")
                } else {
                    print("theclawbay models (\(ids.count))")
                    for id in ids {
                        print("- \(id)")
                    }
                }
            }
            Self.exit(code: .success, output: output, kind: .runtime)
        } catch {
            Self.printError(error, output: output, kind: .provider)
            Self.exit(code: .failure, output: output, kind: .provider)
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
