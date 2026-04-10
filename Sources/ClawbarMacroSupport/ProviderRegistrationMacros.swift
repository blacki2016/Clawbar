@attached(peer, names: prefixed(_ClawbarDescriptorRegistration_))
public macro ProviderDescriptorRegistration() = #externalMacro(
    module: "ClawbarMacros",
    type: "ProviderDescriptorRegistrationMacro")

@attached(member, names: named(descriptor))
public macro ProviderDescriptorDefinition() = #externalMacro(
    module: "ClawbarMacros",
    type: "ProviderDescriptorDefinitionMacro")

@attached(peer, names: prefixed(_ClawbarImplementationRegistration_))
public macro ProviderImplementationRegistration() = #externalMacro(
    module: "ClawbarMacros",
    type: "ProviderImplementationRegistrationMacro")
