import SwiftUI

struct DriverWelcomeView: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var showSignIn = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo + Branding
            VStack(spacing: SpotlyDriverSpacing.lg) {
                SpotlyDriverBadge(size: 88)

                VStack(spacing: SpotlyDriverSpacing.sm) {
                    Text("Earn with Spotly")
                        .font(SpotlyDriverTypography.largeTitle)
                        .foregroundStyle(SpotlyDriverColors.label)
                        .multilineTextAlignment(.center)

                    Text("Join Spotly's driver network and earn\ndelivering across Harare.")
                        .font(SpotlyDriverTypography.body)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            Spacer()

            // Highlights
            VStack(spacing: SpotlyDriverSpacing.sm) {
                highlightRow(icon: "clock.badge.checkmark", text: "Flexible hours — work when you want")
                highlightRow(icon: "dollarsign.circle", text: "Competitive per-delivery earnings")
                highlightRow(icon: "mappin.and.ellipse", text: "Local deliveries across your city")
            }
            .padding(.horizontal, SpotlyDriverSpacing.screenEdge)

            Spacer()

            // Actions
            VStack(spacing: SpotlyDriverSpacing.sm) {
                DriverButton(title: "Create Driver Account", style: .primary, icon: "person.badge.plus") {
                    appState.authState = .onboarding
                }

                DriverButton(title: "Sign In", style: .outline) {
                    showSignIn = true
                }

                Button(action: {
                    appState.skipToMain()
                }) {
                    Text("Continue as Demo")
                        .font(SpotlyDriverTypography.subheadline)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
            .padding(.bottom, SpotlyDriverSpacing.xl)
        }
        .background(SpotlyDriverColors.background)
        .sheet(isPresented: $showSignIn) {
            DriverSignInView()
                .environmentObject(appState)
        }
    }

    @ViewBuilder
    private func highlightRow(icon: String, text: String) -> some View {
        HStack(spacing: SpotlyDriverSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: SpotlyDriverRadius.sm)
                    .fill(SpotlyDriverColors.primaryLight)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(SpotlyDriverColors.primary)
            }
            Text(text)
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.label)
            Spacer()
        }
    }
}
