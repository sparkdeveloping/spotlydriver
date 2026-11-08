import SwiftUI

struct DriverOnboardingView: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var currentStep = 0
    @State private var fullName = ""
    @State private var phone = ""
    @State private var city = "Harare"
    @State private var vehicleMake = ""
    @State private var vehicleModel = ""
    @State private var vehiclePlate = ""
    @State private var vehicleColor = ""
    @State private var selectedVehicleType: DriverVehicleType = .motorbike
    @State private var agreedToSafety = false

    let steps = ["Profile", "Vehicle", "Documents", "City", "Agreement", "Done"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Step Progress
                stepProgress

                ScrollView {
                    VStack(spacing: SpotlyDriverSpacing.xl) {
                        switch currentStep {
                        case 0: profileStep
                        case 1: vehicleStep
                        case 2: documentsStep
                        case 3: cityStep
                        case 4: agreementStep
                        case 5: completionStep
                        default: completionStep
                        }
                    }
                    .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                    .padding(.bottom, 120)
                }
            }
            .safeAreaInset(edge: .bottom) {
                DriverBottomActionBar {
                    if currentStep < 5 {
                        HStack(spacing: SpotlyDriverSpacing.sm) {
                            if currentStep > 0 {
                                DriverButton(title: "Back", style: .secondary, height: 50) {
                                    withAnimation(SpotlyDriverMotion.standard) {
                                        currentStep -= 1
                                    }
                                }
                                .frame(width: 100)
                            }
                            DriverButton(title: currentStep == 4 ? "Complete Verification" : "Continue", style: .primary, height: 50) {
                                advanceStep()
                            }
                        }
                    } else {
                        DriverButton(title: "Go to Dashboard", style: .primary) {
                            appState.completeVerificationDemo()
                        }
                    }
                }
            }
            .background(SpotlyDriverColors.groupedBackground)
            .navigationTitle("Driver Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") {
                        appState.skipToMain()
                    }
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    .font(SpotlyDriverTypography.subheadline)
                }
            }
        }
    }

    private var stepProgress: some View {
        HStack(spacing: 4) {
            ForEach(0..<steps.count, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep ? SpotlyDriverColors.primary : SpotlyDriverColors.separator)
                    .frame(height: 4)
                    .animation(SpotlyDriverMotion.quick, value: currentStep)
            }
        }
        .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
        .padding(.vertical, SpotlyDriverSpacing.sm)
        .background(SpotlyDriverColors.background)
    }

    private var profileStep: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
            stepHeader(title: "Your Profile", subtitle: "Enter your basic details as they appear on your national ID.")
            DriverTextField(label: "Full Name", placeholder: "John Smith", text: $fullName, icon: "person")
            DriverTextField(label: "Phone Number", placeholder: "+263 77 000 0000", text: $phone, keyboardType: .phonePad, icon: "phone")
        }
    }

    private var vehicleStep: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
            stepHeader(title: "Your Vehicle", subtitle: "Select the vehicle you will use for Spotly deliveries.")

            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                Text("Vehicle Type")
                    .font(SpotlyDriverTypography.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    .textCase(.uppercase)
                    .tracking(0.5)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: SpotlyDriverSpacing.sm) {
                    ForEach(DriverVehicleType.allCases, id: \.self) { type in
                        vehicleTypeButton(type)
                    }
                }
            }

            DriverTextField(label: "Make", placeholder: "Honda", text: $vehicleMake, icon: "car")
            DriverTextField(label: "Model", placeholder: "CG125", text: $vehicleModel)
            DriverTextField(label: "Plate Number", placeholder: "ADE 1234", text: $vehiclePlate, icon: "rectangle.and.text.magnifyingglass")
            DriverTextField(label: "Colour", placeholder: "Black", text: $vehicleColor)
        }
    }

    private var documentsStep: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
            stepHeader(title: "Required Documents", subtitle: "Driver verification will be reviewed by the Spotly operations team before launch.")

            VStack(spacing: SpotlyDriverSpacing.sm) {
                documentRow(icon: "person.text.rectangle", title: "National ID", subtitle: "Front and back photo")
                documentRow(icon: "car.badge.checkmark", title: "Driving Licence", subtitle: "Valid licence photo")
                documentRow(icon: "doc.text", title: "Vehicle Registration", subtitle: "Current registration")
                documentRow(icon: "shield.checkered", title: "Vehicle Insurance", subtitle: "Third-party minimum")
            }

            DriverInfoBanner(
                icon: "info.circle.fill",
                message: "Document uploads will be enabled when the Spotly Driver app goes live. For now, confirm you have these documents ready.",
                style: .info
            )
        }
    }

    private var cityStep: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
            stepHeader(title: "Your City", subtitle: "Select the city where you will be delivering.")

            VStack(spacing: SpotlyDriverSpacing.sm) {
                ForEach(["Harare", "Bulawayo", "Mutare", "Gweru"], id: \.self) { c in
                    Button(action: {
                        DriverHaptics.selection()
                        city = c
                    }) {
                        HStack {
                            Text(c)
                                .font(SpotlyDriverTypography.body)
                                .foregroundStyle(SpotlyDriverColors.label)
                            Spacer()
                            if city == c {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(SpotlyDriverColors.primary)
                            }
                        }
                        .padding(SpotlyDriverSpacing.md)
                        .background(city == c ? SpotlyDriverColors.primaryLight : SpotlyDriverColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpotlyDriverRadius.md)
                                .strokeBorder(city == c ? SpotlyDriverColors.primary : SpotlyDriverColors.border, lineWidth: city == c ? 1.5 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
            }
        }
    }

    private var agreementStep: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
            stepHeader(title: "Safety Agreement", subtitle: "Please read and agree to Spotly's driver guidelines before continuing.")

            VStack(spacing: SpotlyDriverSpacing.sm) {
                safetyPoint(icon: "car.fill", text: "Always follow road safety laws and regulations.")
                safetyPoint(icon: "person.2.fill", text: "Treat customers and businesses respectfully.")
                safetyPoint(icon: "shippingbox.fill", text: "Handle all deliveries with care.")
                safetyPoint(icon: "bell.fill", text: "Keep your phone available during deliveries.")
                safetyPoint(icon: "exclamationmark.triangle.fill", text: "For emergencies, contact local emergency services first.")
            }

            Button(action: {
                DriverHaptics.selection()
                agreedToSafety.toggle()
            }) {
                HStack(spacing: SpotlyDriverSpacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(agreedToSafety ? SpotlyDriverColors.primary : Color.clear)
                            .frame(width: 22, height: 22)
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(agreedToSafety ? SpotlyDriverColors.primary : SpotlyDriverColors.border, lineWidth: 1.5)
                            .frame(width: 22, height: 22)
                        if agreedToSafety {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    Text("I agree to Spotly's driver guidelines and terms of service.")
                        .font(SpotlyDriverTypography.subheadline)
                        .foregroundStyle(SpotlyDriverColors.label)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
    }

    private var completionStep: some View {
        VStack(spacing: SpotlyDriverSpacing.xl) {
            Spacer(minLength: SpotlyDriverSpacing.xxl)

            ZStack {
                Circle()
                    .fill(SpotlyDriverColors.primaryLight)
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(SpotlyDriverColors.primary)
            }

            VStack(spacing: SpotlyDriverSpacing.sm) {
                Text("Application Submitted")
                    .font(SpotlyDriverTypography.title2)
                    .foregroundStyle(SpotlyDriverColors.label)

                Text("Your driver profile has been submitted for review. The Spotly operations team will verify your documents before your account goes live.")
                    .font(SpotlyDriverTypography.body)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            DriverInfoBanner(
                icon: "clock.fill",
                message: "Verification typically takes 1–3 business days.",
                style: .info
            )
        }
        .padding(.horizontal, SpotlyDriverSpacing.xs)
    }

    @ViewBuilder
    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.xs) {
            Text(title)
                .font(SpotlyDriverTypography.title2)
                .foregroundStyle(SpotlyDriverColors.label)
            Text(subtitle)
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                .lineSpacing(4)
        }
        .padding(.top, SpotlyDriverSpacing.lg)
    }

    @ViewBuilder
    private func documentRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: SpotlyDriverSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: SpotlyDriverRadius.sm)
                    .fill(SpotlyDriverColors.primaryLight)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SpotlyDriverColors.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SpotlyDriverTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(SpotlyDriverColors.label)
                Text(subtitle)
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
        }
        .padding(SpotlyDriverSpacing.sm)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.md))
        .driverCardShadow()
    }

    @ViewBuilder
    private func safetyPoint(icon: String, text: String) -> some View {
        HStack(spacing: SpotlyDriverSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(SpotlyDriverColors.primary)
                .frame(width: 20)
            Text(text)
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.label)
            Spacer()
        }
    }

    @ViewBuilder
    private func vehicleTypeButton(_ type: DriverVehicleType) -> some View {
        Button(action: {
            DriverHaptics.selection()
            selectedVehicleType = type
        }) {
            VStack(spacing: 6) {
                Image(systemName: type.systemIcon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(selectedVehicleType == type ? SpotlyDriverColors.primary : SpotlyDriverColors.secondaryLabel)
                Text(type.displayLabel)
                    .font(SpotlyDriverTypography.caption1)
                    .fontWeight(.medium)
                    .foregroundStyle(selectedVehicleType == type ? SpotlyDriverColors.primary : SpotlyDriverColors.secondaryLabel)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpotlyDriverSpacing.sm)
            .background(selectedVehicleType == type ? SpotlyDriverColors.primaryLight : SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: SpotlyDriverRadius.md)
                    .strokeBorder(selectedVehicleType == type ? SpotlyDriverColors.primary : SpotlyDriverColors.border, lineWidth: selectedVehicleType == type ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }

    private func advanceStep() {
        DriverHaptics.medium()
        withAnimation(SpotlyDriverMotion.standard) {
            if currentStep == 4 {
                currentStep = 5
            } else {
                currentStep += 1
            }
        }
    }
}
