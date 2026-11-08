import SwiftUI

struct DriverMetricCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var icon: String? = nil
    var accentColor: Color = SpotlyDriverColors.primary
    var fullWidth: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.xs) {
            HStack {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(accentColor)
                }
                Text(title)
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    .fontWeight(.medium)
            }

            Text(value)
                .font(SpotlyDriverTypography.metricMedium)
                .foregroundStyle(SpotlyDriverColors.label)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let subtitle {
                Text(subtitle)
                    .font(SpotlyDriverTypography.caption2)
                    .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
            }
        }
        .padding(SpotlyDriverSpacing.cardPadding)
        .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .leading)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }
}
