import ClawbarCore
import ClawbarMacroSupport
import Foundation

@ProviderImplementationRegistration
struct KiroProviderImplementation: ProviderImplementation {
    let id: UsageProvider = .kiro
}
