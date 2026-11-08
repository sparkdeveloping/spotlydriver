import SwiftUI

struct DriverJobStepRow: View {
    let step: Int
    let title: String
    let subtitle: String
    let isCurrent: Bool
    let isCompleted: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: SpotlyDriverSpacing.sm) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(circleBackground)
                        .frame(width: 28, height: 28)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    } else if isCurrent {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                    } else {
                        Text("\(step)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
                    }
                }
                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? SpotlyDriverColors.primary : SpotlyDriverColors.separator)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 2)
                }
            }
            .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SpotlyDriverTypography.subheadline)
                    .fontWeight(isCurrent ? .semibold : .regular)
                    .foregroundStyle(isCurrent ? SpotlyDriverColors.label : (isCompleted ? SpotlyDriverColors.secondaryLabel : SpotlyDriverColors.tertiaryLabel))
                Text(subtitle)
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
            }
            .padding(.bottom, isLast ? 0 : SpotlyDriverSpacing.lg)

            Spacer()
        }
    }

    private var circleBackground: Color {
        if isCompleted { return SpotlyDriverColors.primary }
        if isCurrent { return SpotlyDriverColors.primary }
        return SpotlyDriverColors.secondaryBackground
    }
}
