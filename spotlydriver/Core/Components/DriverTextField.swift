import SwiftUI

struct DriverTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.xs) {
            Text(label)
                .font(SpotlyDriverTypography.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(spacing: SpotlyDriverSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                        .frame(width: 20)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(SpotlyDriverTypography.body)
                } else {
                    TextField(placeholder, text: $text)
                        .font(SpotlyDriverTypography.body)
                        .keyboardType(keyboardType)
                }
            }
            .padding(SpotlyDriverSpacing.sm)
            .frame(height: 50)
            .background(SpotlyDriverColors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: SpotlyDriverRadius.md)
                    .strokeBorder(SpotlyDriverColors.border, lineWidth: 1)
            )
        }
    }
}
