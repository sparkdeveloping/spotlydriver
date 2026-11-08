import SwiftUI

struct DriverSegmentedControl<T: Hashable>: View {
    let options: [T]
    @Binding var selected: T
    let labelFor: (T) -> String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        DriverHaptics.selection()
                        withAnimation(SpotlyDriverMotion.quick) {
                            selected = option
                        }
                    }) {
                        Text(labelFor(option))
                            .font(SpotlyDriverTypography.subheadline)
                            .fontWeight(selected == option ? .semibold : .regular)
                            .foregroundStyle(selected == option ? SpotlyDriverColors.primary : SpotlyDriverColors.secondaryLabel)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .frame(minWidth: 78)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .padding(.horizontal, 4)
                            .background(selected == option ? SpotlyDriverColors.primaryLight : Color.clear)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
            }
            .padding(4)
            .frame(maxWidth: .infinity)
        }
        .background(SpotlyDriverColors.secondaryBackground)
        .overlay(RoundedRectangle(cornerRadius: SpotlyDriverRadius.md).stroke(SpotlyDriverColors.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.md))
    }
}

typealias SpotlySegmentedControl = DriverSegmentedControl
