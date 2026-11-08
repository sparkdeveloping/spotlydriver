import SwiftUI

enum DriverMetricCardSize {
    case small
    case medium
    case wide

    var minHeight: CGFloat {
        switch self {
        case .small: return 118
        case .medium: return 132
        case .wide: return 150
        }
    }
}

enum DriverMetricTrend {
    case up(String)
    case down(String)
    case neutral(String)

    var label: String {
        switch self {
        case .up(let label), .down(let label), .neutral(let label):
            return label
        }
    }

    var iconName: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "minus"
        }
    }

    var color: Color {
        switch self {
        case .up: return SpotlyDriverColors.primary
        case .down: return SpotlyDriverColors.destructive
        case .neutral: return SpotlyDriverColors.secondaryLabel
        }
    }
}

struct DriverMetricCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var icon: String? = nil
    var accentColor: Color = SpotlyDriverColors.primary
    var fullWidth: Bool = false
    var size: DriverMetricCardSize = .medium
    var trend: DriverMetricTrend? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    cardContent
                }
                .buttonStyle(.plain)
            } else {
                cardContent
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.xs) {
            HStack(alignment: .top, spacing: SpotlyDriverSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(accentColor)
                        .frame(width: 30, height: 30)
                        .background(accentColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.small))
                }
                Text(title)
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 0)
            }

            Spacer(minLength: SpotlyDriverSpacing.xs)

            Text(value)
                .font(SpotlyDriverTypography.metricMedium)
                .foregroundStyle(SpotlyDriverColors.label)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            HStack(spacing: 6) {
                if let subtitle {
                    Text(subtitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                if let trend {
                    Label(trend.label, systemImage: trend.iconName)
                        .foregroundStyle(trend.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                Spacer(minLength: 0)
            }
            .font(SpotlyDriverTypography.caption2)
            .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
        }
        .padding(SpotlyDriverSpacing.cardPadding)
        .frame(maxWidth: .infinity, minHeight: size.minHeight, alignment: .leading)
        .background(SpotlyDriverColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: SpotlyDriverRadius.card)
                .stroke(SpotlyDriverColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverElevatedShadow()
        .contentShape(Rectangle())
    }
}
