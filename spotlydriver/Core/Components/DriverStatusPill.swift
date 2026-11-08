import SwiftUI

struct DriverStatusPill: View {
    let availability: DriverAvailability

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)
            Text(availability.displayLabel)
                .font(SpotlyDriverTypography.caption2)
        }
        .foregroundStyle(dotColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .clipShape(Capsule())
        .accessibilityLabel("Driver status, \(availability.displayLabel)")
    }

    private var dotColor: Color {
        switch availability {
        case .online: return SpotlyDriverColors.success
        case .onJob: return SpotlyDriverColors.info
        case .offline: return SpotlyDriverColors.destructive
        case .paused: return SpotlyDriverColors.warning
        case .verificationRequired: return SpotlyDriverColors.destructive
        case .zoneUnavailable: return SpotlyDriverColors.warning
        }
    }

    private var backgroundColor: Color {
        switch availability {
        case .online: return SpotlyDriverColors.successSoft
        case .onJob: return SpotlyDriverColors.infoSoft
        case .offline: return SpotlyDriverColors.neutralSoft
        case .paused, .zoneUnavailable: return SpotlyDriverColors.warningSoft
        case .verificationRequired: return SpotlyDriverColors.destructiveSoft
        }
    }
}

struct VerificationStatusPill: View {
    let status: DriverVerificationStatus

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: iconName)
                .font(.system(size: 10, weight: .bold))
            Text(status.displayLabel)
                .font(SpotlyDriverTypography.caption2)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .clipShape(Capsule())
        .accessibilityLabel("Verification status, \(status.displayLabel)")
    }

    private var iconName: String {
        switch status {
        case .verified: return "checkmark.shield.fill"
        case .pending: return "clock.fill"
        case .notStarted: return "exclamationmark.circle.fill"
        case .rejected: return "xmark.shield.fill"
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .verified: return SpotlyDriverColors.success
        case .pending: return SpotlyDriverColors.info
        case .notStarted: return SpotlyDriverColors.secondaryLabel
        case .rejected: return SpotlyDriverColors.destructive
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .verified: return SpotlyDriverColors.successSoft
        case .pending: return SpotlyDriverColors.infoSoft
        case .notStarted: return SpotlyDriverColors.neutralSoft
        case .rejected: return SpotlyDriverColors.destructiveSoft
        }
    }
}

typealias SpotlyStatusPill = DriverStatusPill
typealias SpotlyVerificationBadge = VerificationStatusPill
