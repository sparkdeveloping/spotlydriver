import SwiftUI

enum DriverButtonStyle {
    case primary, secondary, destructive, ghost, outline
}

struct DriverButton: View {
    let title: String
    var style: DriverButtonStyle = .primary
    var icon: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var height: CGFloat = SpotlyDriverSpacing.buttonHeight
    let action: () -> Void

    var body: some View {
        Button(action: {
            DriverHaptics.medium()
            action()
        }) {
            HStack(spacing: SpotlyDriverSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.85)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(SpotlyDriverTypography.ctaLabel)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(minHeight: max(44, height), maxHeight: max(44, height))
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.button))
            .overlay(
                RoundedRectangle(cornerRadius: SpotlyDriverRadius.button)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .opacity(isDisabled ? 0.55 : 1.0)
            .contentShape(Rectangle())
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return SpotlyDriverColors.primary
        case .secondary: return SpotlyDriverColors.primaryMuted
        case .destructive: return SpotlyDriverColors.destructive
        case .ghost, .outline: return Color.clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return SpotlyDriverColors.textOnPrimary
        case .secondary: return SpotlyDriverColors.primary
        case .destructive: return .white
        case .ghost, .outline: return SpotlyDriverColors.primary
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary: return SpotlyDriverColors.primary.opacity(0.18)
        case .outline: return SpotlyDriverColors.primary
        case .ghost: return Color.clear
        default: return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .secondary, .outline: return 1
        default: return 0
        }
    }
}

struct DriverIconButton: View {
    let icon: String
    var tint: Color = SpotlyDriverColors.primary
    var size: CGFloat = 44
    var background: Color = SpotlyDriverColors.primaryMuted
    var cornerRadius: CGFloat = SpotlyDriverRadius.md
    let action: () -> Void

    var body: some View {
        Button(action: {
            DriverHaptics.light()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: max(44, size), height: max(44, size))
                .background(background)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(SpotlyDriverColors.border, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(.plain)
    }
}
