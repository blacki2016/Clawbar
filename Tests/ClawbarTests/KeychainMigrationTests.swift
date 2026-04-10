import Testing
@testable import ClawbarApp

struct KeychainMigrationTests {
    @Test
    func `migration list covers known keychain items`() {
        let items = Set(KeychainMigration.itemsToMigrate.map(\.label))
        let expected: Set = [
            "com.steipete.Clawbar:codex-cookie",
            "com.steipete.Clawbar:claude-cookie",
            "com.steipete.Clawbar:cursor-cookie",
            "com.steipete.Clawbar:factory-cookie",
            "com.steipete.Clawbar:minimax-cookie",
            "com.steipete.Clawbar:minimax-api-token",
            "com.steipete.Clawbar:augment-cookie",
            "com.steipete.Clawbar:copilot-api-token",
            "com.steipete.Clawbar:zai-api-token",
            "com.steipete.Clawbar:synthetic-api-key",
        ]

        let missing = expected.subtracting(items)
        #expect(missing.isEmpty, "Missing migration entries: \(missing.sorted())")
    }
}
