import Foundation

// MARK: - The Claw Bay Status

public struct TheClawBayStatusSnapshot: Sendable {
    public let overallStatus: TheClawBayOverallStatus
    public let openAIStatus: TheClawBayProviderStatus
    public let claudeStatus: TheClawBayProviderStatus
    public let checkedAt: Date

    public init(
        overallStatus: TheClawBayOverallStatus,
        openAIStatus: TheClawBayProviderStatus,
        claudeStatus: TheClawBayProviderStatus,
        checkedAt: Date = Date())
    {
        self.overallStatus = overallStatus
        self.openAIStatus = openAIStatus
        self.claudeStatus = claudeStatus
        self.checkedAt = checkedAt
    }
}

public enum TheClawBayOverallStatus: String, Sendable {
    case operational = "operational"
    case degraded = "degraded"
    case partial = "partial"
    case major = "major"
    case unknown = "unknown"

    public var displayName: String {
        switch self {
        case .operational: return "Operational"
        case .degraded: return "Degraded Performance"
        case .partial: return "Partial Outage"
        case .major: return "Major Outage"
        case .unknown: return "Unknown"
        }
    }
}

public enum TheClawBayProviderStatus: String, Sendable {
    case operational = "operational"
    case degraded = "degraded"
    case checking = "checking"
    case unknown = "unknown"

    public var displayName: String {
        switch self {
        case .operational: return "Operational"
        case .degraded: return "Degraded"
        case .checking: return "Checking"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - Status Probe

public enum TheClawBayStatusProbeError: LocalizedError, Sendable {
    case networkError(String)
    case parseError(String)

    public var errorDescription: String? {
        switch self {
        case let .networkError(msg): return "TheClawBay status error: \(msg)"
        case let .parseError(msg): return "Failed to parse TheClawBay status: \(msg)"
        }
    }
}

public struct TheClawBayStatusProbe: Sendable {
    public let statusPageURL: URL
    public var timeout: TimeInterval = 10.0
    private let urlSession: URLSession

    public init(
        statusPageURL: URL = URL(string: "https://theclawbay.com/status")!,
        timeout: TimeInterval = 10.0,
        urlSession: URLSession = .shared)
    {
        self.statusPageURL = statusPageURL
        self.timeout = timeout
        self.urlSession = urlSession
    }

    public func fetch() async throws -> TheClawBayStatusSnapshot {
        var request = URLRequest(url: self.statusPageURL)
        request.timeoutInterval = self.timeout
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "Accept")
        request.setValue("text/html", forHTTPHeaderField: "Accept")

        let (data, response) = try await self.urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TheClawBayStatusProbeError.networkError("HTTP \((response as? HTTPURLResponse)?.statusCode.description ?? "unknown")")
        }

        guard let html = String(data: data, encoding: .utf8) else {
            throw TheClawBayStatusProbeError.parseError("Could not decode HTML")
        }

        return Self.parse(html: html)
    }

    public static func parse(html: String) -> TheClawBayStatusSnapshot {
        let overallStatus = Self.parseOverallStatus(from: html)
        let openAIStatus = Self.parseProviderStatus(from: html, providerName: "OpenAI")
        let claudeStatus = Self.parseProviderStatus(from: html, providerName: "Claude")

        return TheClawBayStatusSnapshot(
            overallStatus: overallStatus,
            openAIStatus: openAIStatus,
            claudeStatus: claudeStatus,
            checkedAt: Date())
    }

    private static func parseOverallStatus(from html: String) -> TheClawBayOverallStatus {
        // Look for the status badge text like "All Systems Operational" or "Some Systems Affected"
        if html.contains("All Systems Operational") {
            return .operational
        } else if html.contains("Some Systems Affected") {
            return .degraded
        } else if html.contains("Partial Outage") {
            return .partial
        } else if html.contains("Major Outage") {
            return .major
        } else if html.contains("Systems Normal") || html.contains("all systems normal") {
            return .operational
        }

        // Fallback: check for specific indicator colors
        // amber = degraded, red = major, green = operational
        if html.contains("bg-amber-500") || html.contains("text-amber-400") {
            return .degraded
        } else if html.contains("bg-red-500") || html.contains("text-red-400") {
            return .major
        } else if html.contains("bg-green-500") || html.contains("text-green-400") {
            return .operational
        }

        return .unknown
    }

    private static func parseProviderStatus(from html: String, providerName: String) -> TheClawBayProviderStatus {
        // Look for "Checking" state which indicates a spinner
        if html.contains("\(providerName)") && html.contains("animate-spin") {
            return .checking
        } else if html.contains("\(providerName)") && html.contains("bg-green-") {
            return .operational
        } else if html.contains("\(providerName)") && html.contains("bg-amber-") {
            return .degraded
        } else if html.contains("\(providerName)") && html.contains("text-green-") {
            return .operational
        } else if html.contains("\(providerName)") && html.contains("text-red-") {
            return .degraded
        }

        return .unknown
    }
}
