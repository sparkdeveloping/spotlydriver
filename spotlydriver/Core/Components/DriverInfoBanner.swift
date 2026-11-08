import SwiftUI

struct DriverInfoBanner: View {
    let icon: String
    let message: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil
    var style: BannerStyle = .info

    enum BannerStyle {
        case info, warning, success, safety
    }

    var body: some View {
        HStack(alignment: .top, spacing: SpotlyDriverSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 24, height: 24)

            Text(message)
                .font(SpotlyDriverTypography.caption1)
                .foregroundStyle(SpotlyDriverColors.label)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: SpotlyDriverSpacing.xs)

            if let actionLabel, let action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(SpotlyDriverTypography.caption1)
                        .fontWeight(.semibold)
                        .foregroundStyle(iconColor)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(SpotlyDriverSpacing.sm)
        .background(backgroundColor)
        .overlay(RoundedRectangle(cornerRadius: SpotlyDriverRadius.md).stroke(iconColor.opacity(0.18), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.md))
        .accessibilityElement(children: .combine)
    }

    private var iconColor: Color {
        switch style {
        case .info: return SpotlyDriverColors.info
        case .warning: return SpotlyDriverColors.warning
        case .success: return SpotlyDriverColors.success
        case .safety: return SpotlyDriverColors.destructive
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .info: return SpotlyDriverColors.infoSoft
        case .warning: return SpotlyDriverColors.warningSoft
        case .success: return SpotlyDriverColors.successSoft
        case .safety: return SpotlyDriverColors.destructiveSoft
        }
    }
}
