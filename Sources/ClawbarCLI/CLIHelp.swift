import ClawbarCore
import Foundation

extension ClawbarCLI {
    static func usageHelp(version: String) -> String {
        """
        Clawbar \(version)

        Usage:
          clawbar usage [--format text|json]
                        [--json]
                        [--json-only]
                        [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>] [-v|--verbose]
                        [--provider \(ProviderHelp.list)]
                        [--account <label>] [--account-index <index>] [--all-accounts]
                        [--no-credits] [--no-color] [--pretty] [--status] [--source <auto|web|cli|oauth|api>]
                        [--web-timeout <seconds>] [--web-debug-dump-html] [--antigravity-plan-debug] [--augment-debug]

        Description:
          Print usage from enabled providers as text (default) or JSON. Honors your in-app toggles.
          Output format: use --json (or --format json) for JSON on stdout; use --json-output for JSON logs on stderr.
          Source behavior is provider-specific:
          - Codex: OpenAI web dashboard (usage limits, credits remaining, code review remaining, usage breakdown).
            Auto falls back to Codex CLI only when cookies are missing.
          - Claude: claude.ai API.
            Auto falls back to Claude CLI only when cookies are missing.
          - Kilo: app.kilo.ai API.
            Auto falls back to Kilo CLI when API credentials are missing or unauthorized.
          Token accounts are loaded from ~/.clawbar/config.json (legacy fallback: ~/.codexbar/config.json).
          Use --account or --account-index to select a specific token account, or --all-accounts to fetch all.
          Account selection requires a single provider.

        Global flags:
          -h, --help      Show help
          -V, --version   Show version
          -v, --verbose   Enable verbose logging
          --no-color      Disable ANSI colors in text output
          --log-level <trace|verbose|debug|info|warning|error|critical>
          --json-output   Emit machine-readable logs (JSONL) to stderr

        Examples:
          clawbar usage
          clawbar usage --provider claude
          clawbar usage --provider gemini
          clawbar usage --format json --provider all --pretty
          clawbar usage --provider all --json
          clawbar usage --status
          clawbar usage --provider codex --source web --format json --pretty
        """
    }

    static func costHelp(version: String) -> String {
        """
        Clawbar \(version)

        Usage:
          clawbar cost [--format text|json]
                       [--json]
                       [--json-only]
                       [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>] [-v|--verbose]
                       [--provider \(ProviderHelp.list)]
                       [--no-color] [--pretty] [--refresh]

        Description:
          Print local token cost usage from Claude/Codex native logs plus supported pi sessions.
          This does not require web or CLI access and uses cached scan results unless --refresh is provided.

        Examples:
          clawbar cost
          clawbar cost --provider claude --format json --pretty
        """
    }

    static func modelsHelp(version: String) -> String {
        """
        Clawbar \(version)

        Usage:
          clawbar models [--format text|json]
                         [--json]
                         [--json-only]
                         [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>]
                         [-v|--verbose]
                         [--pretty]

        Description:
          List all configured providers and their available models.
          Shows enabled/disabled status for each provider.
          Only providers with a models API (currently: theclawbay) show model lists.
          Reads API keys from ~/.clawbar/config.json (legacy fallback: ~/.codexbar/config.json).

        Examples:
          clawbar models
          clawbar models --format json --pretty
        """
    }

    static func configHelp(version: String) -> String {
        """
        Clawbar \(version)

        Usage:
          clawbar config validate [--format text|json]
                                  [--json]
                                  [--json-only]
                                  [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>]
                                  [-v|--verbose]
                                  [--pretty]
          clawbar config dump [--format text|json]
                              [--json]
                              [--json-only]
                              [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>]
                              [-v|--verbose]
                              [--pretty]

        Description:
          Validate or print the Clawbar config file (default: validate).

        Examples:
          clawbar config validate --format json --pretty
          clawbar config dump --pretty
        """
    }

    static func rootHelp(version: String) -> String {
        """
        Clawbar \(version)

        Usage:
          clawbar [--format text|json]
                   [--json]
                   [--json-only]
                   [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>] [-v|--verbose]
                   [--provider \(ProviderHelp.list)]
                   [--account <label>] [--account-index <index>] [--all-accounts]
                   [--no-credits] [--no-color] [--pretty] [--status] [--source <auto|web|cli|oauth|api>]
                   [--web-timeout <seconds>] [--web-debug-dump-html] [--antigravity-plan-debug] [--augment-debug]
          clawbar cost [--format text|json]
                        [--json]
                        [--json-only]
                        [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>] [-v|--verbose]
                        [--provider \(ProviderHelp.list)] [--no-color] [--pretty] [--refresh]
          clawbar models [--format text|json]
                          [--json]
                          [--json-only]
                          [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>]
                          [-v|--verbose]
                          [--pretty]
          clawbar config <validate|dump> [--format text|json]
                                         [--json]
                                         [--json-only]
                                         [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>]
                                         [-v|--verbose]
                                         [--pretty]

        Global flags:
          -h, --help      Show help
          -V, --version   Show version
          -v, --verbose   Enable verbose logging
          --no-color      Disable ANSI colors in text output
          --log-level <trace|verbose|debug|info|warning|error|critical>
          --json-output   Emit machine-readable logs (JSONL) to stderr

        Examples:
          clawbar
          clawbar --format json --provider all --pretty
          clawbar --provider all --json
          clawbar --provider gemini
          clawbar cost --provider claude --format json --pretty
          clawbar models --format json --pretty
          clawbar config validate --format json --pretty
        """
    }
}
