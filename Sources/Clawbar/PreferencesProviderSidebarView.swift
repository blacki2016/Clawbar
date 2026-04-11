import ClawbarCore
import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct ProviderSidebarListView: View {
    @Environment(\.colorScheme) private var colorScheme
    let providers: [UsageProvider]
    @Bindable var store: UsageStore
    let isEnabled: (UsageProvider) -> Binding<Bool>
    let subtitle: (UsageProvider) -> String
    @Binding var selection: UsageProvider?
    let moveProviders: (IndexSet, Int) -> Void
    @State private var draggingProvider: UsageProvider?

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 10) {
                ClawbarSectionEyebrow(text: L10n.providerRoster)
                ForEach(self.providers, id: \.self) { provider in
                    Button {
                        self.selection = provider
                    } label: {
                        ProviderSidebarRowView(
                            provider: provider,
                            store: self.store,
                            isEnabled: self.isEnabled(provider),
                            subtitle: self.subtitle(provider),
                            isSelected: self.selection == provider,
                            draggingProvider: self.$draggingProvider)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .onDrop(
                        of: [UTType.plainText],
                        delegate: ProviderSidebarDropDelegate(
                            item: provider,
                            providers: self.providers,
                            dragging: self.$draggingProvider,
                            moveProviders: self.moveProviders))
                }
            }
            .padding(14)
        }
        .background(
            RoundedRectangle(cornerRadius: ProviderSettingsMetrics.sidebarCornerRadius, style: .continuous)
                .fill(ClawbarTheme.panelBackground(for: self.colorScheme)))
        .overlay(
            RoundedRectangle(cornerRadius: ProviderSettingsMetrics.sidebarCornerRadius, style: .continuous)
                .stroke(ClawbarTheme.panelStroke(for: self.colorScheme), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: ProviderSettingsMetrics.sidebarCornerRadius, style: .continuous))
        .frame(minWidth: ProviderSettingsMetrics.sidebarWidth, maxWidth: ProviderSettingsMetrics.sidebarWidth)
    }
}

@MainActor
private struct ProviderSidebarRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let provider: UsageProvider
    @Bindable var store: UsageStore
    @Binding var isEnabled: Bool
    let subtitle: String
    let isSelected: Bool
    @Binding var draggingProvider: UsageProvider?

    var body: some View {
        let isRefreshing = self.store.refreshingProviders.contains(self.provider)
        let showStatus = self.store.statusChecksEnabled
        let statusText = self.statusText

        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(self.isSelected ? ClawbarTheme.accent : ClawbarTheme.sea.opacity(0.16))
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    ProviderSidebarReorderHandle()
                        .contentShape(Rectangle())
                        .padding(.vertical, 4)
                        .padding(.horizontal, 2)
                        .help(L10n.dragToReorder)
                        .onDrag {
                            self.draggingProvider = self.provider
                            return NSItemProvider(object: self.provider.rawValue as NSString)
                        }

                    ProviderSidebarBrandIcon(provider: self.provider)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(self.store.metadata(for: self.provider).displayName)
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(.primary)

                            if showStatus {
                                ProviderStatusDot(indicator: self.store.statusIndicator(for: self.provider))
                            }

                            if isRefreshing {
                                ProgressView()
                                    .controlSize(.mini)
                            }
                        }
                        Text(self.statusHeadline)
                            .font(.caption)
                            .foregroundStyle(ClawbarTheme.mutedText(for: self.colorScheme))
                    }
                    Spacer(minLength: 8)
                    Toggle("", isOn: self.$isEnabled)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                }

                Text(statusText)
                    .font(.footnote)
                    .foregroundStyle(ClawbarTheme.mutedText(for: self.colorScheme))
                    .lineLimit(2)
                    .frame(height: ProviderSettingsMetrics.sidebarSubtitleHeight, alignment: .topLeading)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(self.isSelected
                    ? AnyShapeStyle(LinearGradient(
                        colors: [
                            ClawbarTheme.accent.opacity(self.colorScheme == .dark ? 0.20 : 0.12),
                            ClawbarTheme.accent.opacity(self.colorScheme == .dark ? 0.08 : 0.05),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing))
                    : AnyShapeStyle(ClawbarTheme.windowBackground(for: self.colorScheme).opacity(0.52))))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    self.isSelected
                        ? AnyShapeStyle(LinearGradient(
                            colors: [ClawbarTheme.accent.opacity(0.45), ClawbarTheme.sea.opacity(0.25)],
                            startPoint: .leading,
                            endPoint: .trailing))
                        : AnyShapeStyle(Color.clear),
                    lineWidth: 1))
    }

    private var statusHeadline: String {
        self.isEnabled ? L10n.activeFeed : L10n.paused
    }

    private var statusText: String {
        guard !self.isEnabled else { return self.subtitle }
        let lines = self.subtitle.split(separator: "\n", omittingEmptySubsequences: false)
        if lines.count >= 2 {
            let first = lines[0]
            let rest = lines.dropFirst().joined(separator: "\n")
            return "\(L10n.disabledPrefix(String(first)))\n\(rest)"
        }
        return L10n.disabledPrefix(self.subtitle)
    }
}

private struct ProviderSidebarReorderHandle: View {
    var body: some View {
        VStack(spacing: ProviderSettingsMetrics.reorderDotSpacing) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: ProviderSettingsMetrics.reorderDotSpacing) {
                    Circle()
                        .frame(
                            width: ProviderSettingsMetrics.reorderDotSize,
                            height: ProviderSettingsMetrics.reorderDotSize)
                    Circle()
                        .frame(
                            width: ProviderSettingsMetrics.reorderDotSize,
                            height: ProviderSettingsMetrics.reorderDotSize)
                }
            }
        }
        .frame(
            width: ProviderSettingsMetrics.reorderHandleSize,
            height: ProviderSettingsMetrics.reorderHandleSize)
        .foregroundStyle(.secondary)
        .accessibilityLabel(L10n.reorder)
    }
}

@MainActor
private struct ProviderSidebarBrandIcon: View {
    let provider: UsageProvider

    var body: some View {
        if let brand = ProviderBrandIcon.image(for: self.provider) {
            Image(nsImage: brand)
                .resizable()
                .scaledToFit()
                .frame(width: ProviderSettingsMetrics.iconSize, height: ProviderSettingsMetrics.iconSize)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "circle.dotted")
                .font(.system(size: ProviderSettingsMetrics.iconSize, weight: .regular))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
    }
}

private struct ProviderSidebarDropDelegate: DropDelegate {
    let item: UsageProvider
    let providers: [UsageProvider]
    @Binding var dragging: UsageProvider?
    let moveProviders: (IndexSet, Int) -> Void

    func dropEntered(info _: DropInfo) {
        guard let dragging, dragging != self.item else { return }
        guard let fromIndex = self.providers.firstIndex(of: dragging),
              let toIndex = self.providers.firstIndex(of: self.item)
        else { return }

        if fromIndex == toIndex { return }
        let adjustedIndex = toIndex > fromIndex ? toIndex + 1 : toIndex
        self.moveProviders(IndexSet(integer: fromIndex), adjustedIndex)
    }

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info _: DropInfo) -> Bool {
        self.dragging = nil
        return true
    }
}

private struct ProviderStatusDot: View {
    let indicator: ProviderStatusIndicator

    var body: some View {
        Circle()
            .fill(self.statusColor)
            .frame(width: 6, height: 6)
            .accessibilityHidden(true)
    }

    private var statusColor: Color {
        switch self.indicator {
        case .none: .green
        case .minor: .yellow
        case .major: .orange
        case .critical: .red
        case .maintenance: .gray
        case .unknown: .gray
        }
    }
}
