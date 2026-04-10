#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation

private let cliVersion = "1.0.0"

extension ClawbarCLI {
    static func writeStderr(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        FileHandle.standardError.write(data)
    }

    static func printVersion() -> Never {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("Clawbar \(version)")
        } else {
            print("Clawbar \(cliVersion)")
        }
        Self.platformExit(0)
    }

    static func printHelp(for command: String?) -> Never {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? cliVersion
        switch command {
        case "usage":
            print(Self.usageHelp(version: version))
        case "cost":
            print(Self.costHelp(version: version))
        case "models":
            print(Self.modelsHelp(version: version))
        case "config", "validate", "dump":
            print(Self.configHelp(version: version))
        default:
            print(Self.rootHelp(version: version))
        }
        Self.platformExit(0)
    }

    static func platformExit(_ code: Int32) -> Never {
        #if canImport(Darwin)
        Darwin.exit(code)
        #else
        Glibc.exit(code)
        #endif
    }
}
