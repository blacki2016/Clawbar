import ClawbarCore
import Commander
import Foundation
import Testing
@testable import ClawbarCLI

struct CLIEntryTests {
    @Test
    func `effective argv defaults to usage`() {
        #expect(ClawbarCLI.effectiveArgv([]) == ["usage"])
        #expect(ClawbarCLI.effectiveArgv(["--json"]) == ["usage", "--json"])
        #expect(ClawbarCLI.effectiveArgv(["usage", "--json"]) == ["usage", "--json"])
    }

    @Test
    func `decodes format from options and flags`() {
        let jsonOption = ParsedValues(positional: [], options: ["format": ["json"]], flags: [])
        #expect(ClawbarCLI._decodeFormatForTesting(from: jsonOption) == .json)

        let jsonFlag = ParsedValues(positional: [], options: [:], flags: ["json"])
        #expect(ClawbarCLI._decodeFormatForTesting(from: jsonFlag) == .json)

        let textDefault = ParsedValues(positional: [], options: [:], flags: [])
        #expect(ClawbarCLI._decodeFormatForTesting(from: textDefault) == .text)
    }

    @Test
    func `provider selection prefers override`() {
        let selection = ClawbarCLI.providerSelection(rawOverride: "codex", enabled: [.claude, .gemini])
        #expect(selection.asList == [.codex])
    }

    @Test
    func `normalize version extracts numeric`() {
        #expect(ClawbarCLI.normalizeVersion(raw: "codex 1.2.3 (build 4)") == "1.2.3")
        #expect(ClawbarCLI.normalizeVersion(raw: "  v2.0  ") == "2.0")
    }

    @Test
    func `make header includes version when available`() {
        let header = ClawbarCLI.makeHeader(provider: .codex, version: "1.2.3", source: "cli")
        #expect(header.contains("Codex"))
        #expect(header.contains("1.2.3"))
        #expect(header.contains("cli"))
    }

    @Test
    func `render open AI web dashboard text includes summary`() {
        let event = CreditEvent(
            date: Date(timeIntervalSince1970: 1_700_000_000),
            service: "codex",
            creditsUsed: 10)
        let snapshot = OpenAIDashboardSnapshot(
            signedInEmail: "user@example.com",
            codeReviewRemainingPercent: 45,
            codeReviewLimit: RateWindow(
                usedPercent: 55,
                windowMinutes: nil,
                resetsAt: Date().addingTimeInterval(3600),
                resetDescription: nil),
            creditEvents: [event],
            dailyBreakdown: [],
            usageBreakdown: [],
            creditsPurchaseURL: nil,
            updatedAt: Date())

        let text = ClawbarCLI.renderOpenAIWebDashboardText(snapshot)

        #expect(text.contains("Web session: user@example.com"))
        #expect(text.contains("Code review: 45% remaining (Resets in "))
        #expect(text.contains("Web history: 1 events"))
    }

    @Test
    func `maps errors to exit codes`() {
        #expect(ClawbarCLI.mapError(CodexStatusProbeError.codexNotInstalled) == ExitCode(2))
        #expect(ClawbarCLI.mapError(CodexStatusProbeError.timedOut) == ExitCode(4))
        #expect(ClawbarCLI.mapError(UsageError.noRateLimitsFound) == ExitCode(3))
    }

    @Test
    func `provider selection falls back to both for primary pair`() {
        let selection = ClawbarCLI.providerSelection(rawOverride: nil, enabled: [.codex, .claude])
        switch selection {
        case .both:
            break
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func `provider selection falls back to custom when non primary`() {
        let selection = ClawbarCLI.providerSelection(rawOverride: nil, enabled: [.codex, .gemini])
        switch selection {
        case let .custom(providers):
            #expect(providers == [.codex, .gemini])
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func `provider selection defaults to codex when empty`() {
        let selection = ClawbarCLI.providerSelection(rawOverride: nil, enabled: [])
        switch selection {
        case let .single(provider):
            #expect(provider == .codex)
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func `decodes source and timeout options`() throws {
        let signature = ClawbarCLI._usageSignatureForTesting()
        let parser = CommandParser(signature: signature)
        let parsed = try parser.parse(arguments: ["--web-timeout", "45", "--source", "oauth"])
        #expect(ClawbarCLI._decodeWebTimeoutForTesting(from: parsed) == 45)
        #expect(ClawbarCLI._decodeSourceModeForTesting(from: parsed) == .oauth)

        let parsedWeb = try parser.parse(arguments: ["--web"])
        #expect(ClawbarCLI._decodeSourceModeForTesting(from: parsedWeb) == .web)
    }

    @Test
    func `should use color respects format and flags`() {
        #expect(!ClawbarCLI.shouldUseColor(noColor: true, format: .text))
        #expect(!ClawbarCLI.shouldUseColor(noColor: false, format: .json))
    }

    @Test
    func `kilo usage text notes show fallback only for auto resolved to CLI`() {
        #expect(ClawbarCLI.usageTextNotes(
            provider: .kilo,
            sourceMode: .auto,
            resolvedSourceLabel: "cli") == ["Using CLI fallback"])
        #expect(ClawbarCLI.usageTextNotes(
            provider: .kilo,
            sourceMode: .api,
            resolvedSourceLabel: "cli").isEmpty)
        #expect(ClawbarCLI.usageTextNotes(
            provider: .codex,
            sourceMode: .auto,
            resolvedSourceLabel: "cli").isEmpty)
    }

    @Test
    func `kilo auto fallback summary includes ordered attempt details`() {
        let attempts = [
            ProviderFetchAttempt(
                strategyID: "kilo.api",
                kind: .apiToken,
                wasAvailable: true,
                errorDescription: "Kilo authentication failed (401/403)."),
            ProviderFetchAttempt(
                strategyID: "kilo.cli",
                kind: .cli,
                wasAvailable: true,
                errorDescription: "Kilo CLI session not found."),
        ]

        let summary = ClawbarCLI.kiloAutoFallbackSummary(
            provider: .kilo,
            sourceMode: .auto,
            attempts: attempts)
        let expected = [
            "Kilo auto fallback attempts: api: Kilo authentication failed (401/403).",
            " -> cli: Kilo CLI session not found.",
        ].joined()

        #expect(
            summary ==
                expected)
    }

    @Test
    func `kilo auto fallback summary is nil outside kilo auto failures`() {
        let attempts = [
            ProviderFetchAttempt(
                strategyID: "kilo.api",
                kind: .apiToken,
                wasAvailable: true,
                errorDescription: "example"),
        ]

        #expect(ClawbarCLI.kiloAutoFallbackSummary(
            provider: .kilo,
            sourceMode: .api,
            attempts: attempts) == nil)
        #expect(ClawbarCLI.kiloAutoFallbackSummary(
            provider: .codex,
            sourceMode: .auto,
            attempts: attempts) == nil)
    }

    @Test
    func `source mode requires web support is provider aware`() {
        #expect(ClawbarCLI.sourceModeRequiresWebSupport(.web, provider: .kilo))
        #expect(ClawbarCLI.sourceModeRequiresWebSupport(.auto, provider: .codex))
        #expect(!ClawbarCLI.sourceModeRequiresWebSupport(.auto, provider: .kilo))
        #expect(!ClawbarCLI.sourceModeRequiresWebSupport(.api, provider: .kilo))
    }
}
