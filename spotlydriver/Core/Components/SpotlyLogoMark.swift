import SwiftUI

struct SpotlyLogoMark: View {
    var size: CGFloat = 56
    var color: Color = .white

    var body: some View {
        ZStack {
            Image(systemName: "location.fill")
                .font(.system(size: size * 0.55, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
    }
}

struct SpotlyDriverBadge: View {
    var size: CGFloat = 72

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28)
                .fill(SpotlyDriverColors.primary)
                .frame(width: size, height: size)
                .driverElevatedShadow()

            Image(systemName: "location.fill")
                .font(.system(size: size * 0.42, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}
