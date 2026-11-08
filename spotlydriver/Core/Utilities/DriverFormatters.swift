import Foundation

enum DriverFormatters {
    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    static let shortDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    static let shortTime: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    static let relativeDate: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()

    static func price(_ amount: Double) -> String {
        let formatted = currency.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
        return "USD \(formatted)"
    }

    static func priceShort(_ amount: Double) -> String {
        let formatted = currency.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
        return "USD \(formatted)"
    }

    static func distance(_ km: Double) -> String {
        String(format: "%.1f km", km)
    }

    static func duration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hrs = minutes / 60
        let mins = minutes % 60
        return mins > 0 ? "\(hrs)h \(mins)m" : "\(hrs)h"
    }

    static func timeAgo(_ date: Date) -> String {
        relativeDate.localizedString(for: date, relativeTo: Date())
    }

    static func formattedDate(_ date: Date) -> String {
        shortDate.string(from: date)
    }

    static func formattedTime(_ date: Date) -> String {
        shortTime.string(from: date)
    }

    static func acceptanceRate(_ rate: Double) -> String {
        String(format: "%.0f%%", rate * 100)
    }

    static func onlineHours(_ hours: Double) -> String {
        String(format: "%.1fh", hours)
    }
}
