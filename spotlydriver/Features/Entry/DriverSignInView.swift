import SwiftUI

struct DriverSignInView: View {
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) var dismiss
    @State private var emailOrPhone = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpotlyDriverSpacing.xl) {
                    VStack(spacing: SpotlyDriverSpacing.sm) {
                        SpotlyDriverBadge(size: 60)
                        Text("Welcome back")
                            .font(SpotlyDriverTypography.title2)
                            .foregroundStyle(SpotlyDriverColors.label)
                        Text("Sign in to your driver account")
                            .font(SpotlyDriverTypography.subheadline)
                            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    }
                    .padding(.top, SpotlyDriverSpacing.xl)

                    VStack(spacing: SpotlyDriverSpacing.md) {
                        DriverTextField(
                            label: "Phone or Email",
                            placeholder: "Phone number or email",
                            text: $emailOrPhone,
                            keyboardType: .emailAddress,
                            icon: "person"
                        )
                        DriverTextField(
                            label: "Password",
                            placeholder: "Enter your password",
                            text: $password,
                            isSecure: true,
                            icon: "lock"
                        )

                        Button(action: {}) {
                            Text("Forgot password?")
                                .font(SpotlyDriverTypography.subheadline)
                                .foregroundStyle(SpotlyDriverColors.primary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(spacing: SpotlyDriverSpacing.sm) {
                        DriverButton(title: "Sign In", style: .primary, isLoading: isLoading) {
                            signIn()
                        }

                        HStack {
                            Rectangle()
                                .fill(SpotlyDriverColors.separator)
                                .frame(height: 1)
                            Text("or")
                                .font(SpotlyDriverTypography.caption1)
                                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                                .padding(.horizontal, SpotlyDriverSpacing.sm)
                            Rectangle()
                                .fill(SpotlyDriverColors.separator)
                                .frame(height: 1)
                        }

                        DriverButton(title: "Continue as Demo", style: .secondary) {
                            dismiss()
                            appState.skipToMain()
                        }
                    }
                }
                .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                .padding(.bottom, SpotlyDriverSpacing.xxxl)
            }
            .background(SpotlyDriverColors.background)
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(SpotlyDriverColors.primary)
                }
            }
        }
    }

    private func signIn() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            dismiss()
            appState.skipToMain()
        }
    }
}
