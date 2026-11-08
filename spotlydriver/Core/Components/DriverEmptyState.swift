import SwiftUI

struct DriverEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var ctaLabel: String? = nil
    var ctaAction: (() -> Void)? = nil
    var iconColor: Color = SpotlyDriverColors.primary

    var body: some View {
        VStack(spacing: SpotlyDriverSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: SpotlyDriverRadius.lg)
                    .fill(iconColor.opacity(0.10))
                    .frame(width: 58, height: 58)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(spacing: SpotlyDriverSpacing.xs) {
                Text(title)
                    .font(SpotlyDriverTypography.title3)
                    .foregroundStyle(SpotlyDriverColors.label)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(message)
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let ctaLabel, let ctaAction {
                DriverButton(title: ctaLabel, style: .secondary, height: SpotlyDriverSpacing.compactButtonHeight, action: ctaAction)
                    .frame(maxWidth: 240)
            }
        }
        .padding(SpotlyDriverSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(SpotlyDriverColors.cardBackground)
        .overlay(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card).stroke(SpotlyDriverColors.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
        .accessibilityElement(children: .combine)
    }
}
