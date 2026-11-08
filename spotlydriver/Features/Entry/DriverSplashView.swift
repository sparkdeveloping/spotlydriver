import SwiftUI

struct DriverSplashView: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8

    var body: some View {
        ZStack {
            SpotlyDriverColors.primary.ignoresSafeArea()

            VStack(spacing: SpotlyDriverSpacing.xl) {
                SpotlyLogoMark(size: 72, color: .white)
                    .scaleEffect(scale)
                    .opacity(opacity)

                VStack(spacing: SpotlyDriverSpacing.xs) {
                    Text("Spotly Driver")
                        .font(SpotlyDriverTypography.title1)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .opacity(opacity)

                    Text("Deliver with Spotly.")
                        .font(SpotlyDriverTypography.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .opacity(opacity)
                }
            }
        }
        .onAppear {
            withAnimation(SpotlyDriverMotion.spring) {
                opacity = 1
                scale = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(SpotlyDriverMotion.standard) {
                    appState.authState = .welcome
                }
            }
        }
    }
}
