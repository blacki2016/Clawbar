import ClawbarCore
import Commander
import Testing
@testable import ClawbarCLI

struct CLIArgumentParsingTests {
    @Test
    func `json shortcut does not enable json logs`() throws {
        let signature = ClawbarCLI._usageSignatureForTesting()
        let parser = CommandParser(signature: signature)
        let parsed = try parser.parse(arguments: ["--json"])

        #expect(parsed.flags.contains("jsonShortcut"))
        #expect(!parsed.flags.contains("jsonOutput"))
        #expect(ClawbarCLI._decodeFormatForTesting(from: parsed) == .json)
    }

    @Test
    func `json output flag enables json logs`() throws {
        let signature = ClawbarCLI._usageSignatureForTesting()
        let parser = CommandParser(signature: signature)
        let parsed = try parser.parse(arguments: ["--json-output"])

        #expect(parsed.flags.contains("jsonOutput"))
        #expect(!parsed.flags.contains("jsonShortcut"))
        #expect(ClawbarCLI._decodeFormatForTesting(from: parsed) == .text)
    }

    @Test
    func `log level and verbose are parsed`() throws {
        let signature = ClawbarCLI._usageSignatureForTesting()
        let parser = CommandParser(signature: signature)
        let parsed = try parser.parse(arguments: ["--log-level", "info", "--verbose"])

        #expect(parsed.flags.contains("verbose"))
        #expect(parsed.options["logLevel"] == ["info"])
    }

    @Test
    func `resolved log level defaults to error`() {
        #expect(ClawbarCLI.resolvedLogLevel(verbose: false, rawLevel: nil) == .error)
        #expect(ClawbarCLI.resolvedLogLevel(verbose: true, rawLevel: nil) == .debug)
        #expect(ClawbarCLI.resolvedLogLevel(verbose: false, rawLevel: "info") == .info)
    }

    @Test
    func `format option overrides json shortcut`() throws {
        let signature = ClawbarCLI._usageSignatureForTesting()
        let parser = CommandParser(signature: signature)
        let parsed = try parser.parse(arguments: ["--json", "--format", "text"])

        #expect(parsed.flags.contains("jsonShortcut"))
        #expect(parsed.options["format"] == ["text"])
        #expect(ClawbarCLI._decodeFormatForTesting(from: parsed) == .text)
    }

    @Test
    func `json only enables json format`() throws {
        let signature = ClawbarCLI._usageSignatureForTesting()
        let parser = CommandParser(signature: signature)
        let parsed = try parser.parse(arguments: ["--json-only"])

        #expect(parsed.flags.contains("jsonOnly"))
        #expect(!parsed.flags.contains("jsonOutput"))
        #expect(ClawbarCLI._decodeFormatForTesting(from: parsed) == .json)
    }
}
