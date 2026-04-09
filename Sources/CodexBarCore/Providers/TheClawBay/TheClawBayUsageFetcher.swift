import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct TheClawBayQuotaSnapshot: Sendable {
    public let mode: String?
    public let pooled: Bool?
    public let usageLimitPresentation: String?
    public let planMultiplier: Double?
    public let primary: TheClawBayQuotaWindow?
    public let secondary: TheClawBayQuotaWindow?
    public let updatedAt: Date

    public init(
        mode: String?,
        pooled: Bool?,
        usageLimitPresentation: String?,
        planMultiplier: Double?,
        primary: TheClawBayQuotaWindow?,
        secondary: TheClawBayQuotaWindow?,
        updatedAt: Date)
    {
        self.mode = mode
        self.pooled = pooled
        self.usageLimitPresentation = usageLimitPresentation
        self.planMultiplier = planMultiplier
        self.primary = primary
        self.secondary = secondary
        self.updatedAt = updatedAt
    }
}

public struct TheClawBayQuotaWindow: Sendable {
    public let usedPercent: Double
    public let windowMinutes: Int?
    public let resetsAt: Date?
    public let resetDescription: String?

    public init(usedPercent: Double, windowMinutes: Int?, resetsAt: Date?, resetDescription: String?) {
        self.usedPercent = usedPercent
        self.windowMinutes = windowMinutes
        self.resetsAt = resetsAt
        self.resetDescription = resetDescription
    }
}

extension TheClawBayQuotaSnapshot {
    public func toUsageSnapshot() -> UsageSnapshot {
        let identity = ProviderIdentitySnapshot(
            providerID: .theclawbay,
            accountEmail: nil,
            accountOrganization: nil,
            loginMethod: self.loginMethod)

        return UsageSnapshot(
            primary: self.primary.map(Self.rateWindow(for:)),
            secondary: self.secondary.map(Self.rateWindow(for:)),
            tertiary: nil,
            providerCost: nil,
            updatedAt: self.updatedAt,
            identity: identity)
    }

    private var loginMethod: String? {
        var parts: [String] = []
        if let mode = self.mode?.trimmingCharacters(in: .whitespacesAndNewlines), !mode.isEmpty {
            parts.append(mode)
        }
        if let pooled = self.pooled, pooled {
            parts.append("pooled")
        }
        if let presentation = self.usageLimitPresentation?.trimmingCharacters(in: .whitespacesAndNewlines),
           !presentation.isEmpty
        {
            parts.append(presentation)
        }
        if let multiplier = self.planMultiplier, multiplier != 1 {
            parts.append("x\(Self.formatMultiplier(multiplier))")
        }
        return parts.isEmpty ? "theclawbay" : parts.joined(separator: " · ")
    }

    private static func formatMultiplier(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }

    private static func rateWindow(for window: TheClawBayQuotaWindow) -> RateWindow {
        RateWindow(
            usedPercent: window.usedPercent,
            windowMinutes: window.windowMinutes,
            resetsAt: window.resetsAt,
            resetDescription: window.resetDescription)
    }
}

public struct TheClawBayUsageFetcher: Sendable {
    private static let log = CodexBarLog.logger(LogCategories.syntheticUsage)
    private static let quotaURL = URL(string: "https://api.theclawbay.com/api/codex-auth/v1/quota")!

    public static func fetchUsage(apiKey: String, now: Date = Date()) async throws -> TheClawBayQuotaSnapshot {
        guard !apiKey.isEmpty else {
            throw TheClawBayUsageError.invalidCredentials
        }

        var request = URLRequest(url: Self.quotaURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TheClawBayUsageError.networkError("Invalid response")
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            Self.log.error("TheClawBay API returned \(httpResponse.statusCode): \(errorMessage)")
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw TheClawBayUsageError.invalidCredentials
            }
            throw TheClawBayUsageError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }

        do {
            return try Self.parseSnapshot(from: data, fallbackDate: now)
        } catch let error as TheClawBayUsageError {
            throw error
        } catch {
            Self.log.error("TheClawBay parsing error: \(error.localizedDescription)")
            throw TheClawBayUsageError.parseFailed(error.localizedDescription)
        }
    }

    static func parseSnapshot(from data: Data, fallbackDate: Date = Date()) throws -> TheClawBayQuotaSnapshot {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = TheClawBayTimestampParser.parse(raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid The Claw Bay timestamp: \(raw)")
        }

        let decoded = try decoder.decode(TheClawBayQuotaResponse.self, from: data)
        let updatedAt = decoded.observedAt ?? decoded.lastRequestAt ?? fallbackDate
        return TheClawBayQuotaSnapshot(
            mode: decoded.mode,
            pooled: decoded.pooled,
            usageLimitPresentation: decoded.usageLimitPresentation,
            planMultiplier: decoded.planMultiplier,
            primary: decoded.usage?.fiveHour?.toWindow(defaultWindowMinutes: 5 * 60),
            secondary: decoded.usage?.weekly?.toWindow(defaultWindowMinutes: 7 * 24 * 60),
            updatedAt: updatedAt)
    }
}

private struct TheClawBayQuotaResponse: Decodable {
    let mode: String?
    let observedAt: Date?
    let pooled: Bool?
    let usageLimitPresentation: String?
    let planMultiplier: Double?
    let usage: Usage?
    let lastRequestAt: Date?

    struct Usage: Decodable {
        let fiveHour: Window?
        let weekly: Window?

        enum CodingKeys: String, CodingKey {
            case fiveHour
            case weekly
        }
    }

    struct Window: Decodable {
        let windowStart: Date?
        let windowEnd: Date?
        let secondsUntilReset: Double?
        let percentUsed: Double?
        let progressPercentUsed: Double?
        let percentRemaining: Double?
        let limitReached: Bool?

        func toWindow(defaultWindowMinutes: Int) -> TheClawBayQuotaWindow? {
            let usedPercent: Double?
            if let percentUsed {
                usedPercent = percentUsed
            } else if let progressPercentUsed {
                usedPercent = progressPercentUsed
            } else if let percentRemaining {
                usedPercent = 100 - percentRemaining
            } else if let limitReached, limitReached {
                usedPercent = 100
            } else {
                usedPercent = nil
            }

            guard let usedPercent else { return nil }
            let clamped = max(0, min(usedPercent, 100))
            let windowMinutes = Self.windowMinutes(start: self.windowStart, end: self.windowEnd) ?? defaultWindowMinutes
            let resetsAt = self.windowEnd ?? self.secondsUntilReset.map { Date(timeIntervalSinceNow: $0) }
            let resetDescription = resetsAt == nil ? Self.windowDescription(minutes: windowMinutes) : nil
            return TheClawBayQuotaWindow(
                usedPercent: clamped,
                windowMinutes: windowMinutes,
                resetsAt: resetsAt,
                resetDescription: resetDescription)
        }

        private static func windowMinutes(start: Date?, end: Date?) -> Int? {
            guard let start, let end else { return nil }
            let seconds = end.timeIntervalSince(start)
            guard seconds > 0 else { return nil }
            return Int((seconds / 60).rounded())
        }

        private static func windowDescription(minutes: Int?) -> String? {
            guard let minutes, minutes > 0 else { return nil }
            let dayMinutes = 24 * 60
            if minutes % dayMinutes == 0 {
                let days = minutes / dayMinutes
                return "\(days) day\(days == 1 ? "" : "s") window"
            }
            if minutes % 60 == 0 {
                let hours = minutes / 60
                return "\(hours) hour\(hours == 1 ? "" : "s") window"
            }
            return "\(minutes) minute\(minutes == 1 ? "" : "s") window"
        }
    }
}

private final class TheClawBayISO8601FormatterBox: @unchecked Sendable {
    let lock = NSLock()
    let withFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    let plain: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

private enum TheClawBayTimestampParser {
    static let box = TheClawBayISO8601FormatterBox()

    static func parse(_ text: String) -> Date? {
        self.box.lock.lock()
        defer { self.box.lock.unlock() }
        return self.box.withFractional.date(from: text) ?? self.box.plain.date(from: text)
    }
}

public enum TheClawBayUsageError: LocalizedError, Sendable {
    case invalidCredentials
    case networkError(String)
    case apiError(String)
    case parseFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            "Invalid The Claw Bay API credentials"
        case let .networkError(message):
            "The Claw Bay network error: \(message)"
        case let .apiError(message):
            "The Claw Bay API error: \(message)"
        case let .parseFailed(message):
            "Failed to parse The Claw Bay response: \(message)"
        }
    }
}
