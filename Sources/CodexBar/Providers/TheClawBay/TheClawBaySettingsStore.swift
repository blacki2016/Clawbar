import CodexBarCore
import Foundation

extension SettingsStore {
    var theClawBayAPIToken: String {
        get { self.configSnapshot.providerConfig(for: .theclawbay)?.sanitizedAPIKey ?? "" }
        set {
            self.updateProviderConfig(provider: .theclawbay) { entry in
                entry.apiKey = self.normalizedConfigValue(newValue)
            }
            self.logSecretUpdate(provider: .theclawbay, field: "apiKey", value: newValue)
        }
    }
}
