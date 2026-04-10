import SwiftUI
import WidgetKit

@main
struct ClawbarWidgetBundle: WidgetBundle {
    var body: some Widget {
        ClawbarSwitcherWidget()
        ClawbarUsageWidget()
        ClawbarHistoryWidget()
        ClawbarCompactWidget()
    }
}

struct ClawbarSwitcherWidget: Widget {
    private let kind = "ClawbarSwitcherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: self.kind,
            provider: ClawbarSwitcherTimelineProvider())
        { entry in
            ClawbarSwitcherWidgetView(entry: entry)
        }
        .configurationDisplayName("Clawbar Switcher")
        .description("Usage widget with a provider switcher.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ClawbarUsageWidget: Widget {
    private let kind = "ClawbarUsageWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: self.kind,
            intent: ProviderSelectionIntent.self,
            provider: ClawbarTimelineProvider())
        { entry in
            ClawbarUsageWidgetView(entry: entry)
        }
        .configurationDisplayName("Clawbar Usage")
        .description("Session and weekly usage with credits and costs.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ClawbarHistoryWidget: Widget {
    private let kind = "ClawbarHistoryWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: self.kind,
            intent: ProviderSelectionIntent.self,
            provider: ClawbarTimelineProvider())
        { entry in
            ClawbarHistoryWidgetView(entry: entry)
        }
        .configurationDisplayName("Clawbar History")
        .description("Usage history chart with recent totals.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct ClawbarCompactWidget: Widget {
    private let kind = "ClawbarCompactWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: self.kind,
            intent: CompactMetricSelectionIntent.self,
            provider: ClawbarCompactTimelineProvider())
        { entry in
            ClawbarCompactWidgetView(entry: entry)
        }
        .configurationDisplayName("Clawbar Metric")
        .description("Compact widget for credits or cost.")
        .supportedFamilies([.systemSmall])
    }
}
