import SwiftUI

struct DriverProfileView: View {
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        NavigationStack(path: $appState.profileNavPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sectionSpacing) {
                    SpotlyPageHeader(
                        title: "Profile",
                        subtitle: "Driver account, work settings, support, and demo controls.",
                        variant: .large
                    )
                    driverCard
                    section("Account", [.personalDetails, .vehicleDetails, .documents, .payoutMethod, .availabilityPreferences])
                    section("Work", [.deliveryZones, .jobHistory, .shiftHistory, .performance, .incidentHistory])
                    section("Support", [.helpSupport, .safetyCenter, .reportIssue, .terms, .privacy, .about])
                    settingsSection
                }
                .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                .padding(.top, SpotlyDriverSpacing.md)
                .padding(.bottom, SpotlyDriverSpacing.tabBarPadding)
            }
            .background(SpotlyDriverColors.groupedBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: DriverRoute.self) { route in
                JobsRouteDestination(route: route)
                    .environmentObject(appState)
            }
        }
    }

    private var driverCard: some View {
        VStack(spacing: SpotlyDriverSpacing.md) {
            HStack(spacing: SpotlyDriverSpacing.md) {
                Text(appState.profile.avatarInitials)
                    .font(SpotlyDriverTypography.title2)
                    .foregroundStyle(SpotlyDriverColors.primary)
                    .frame(width: 64, height: 64)
                    .background(SpotlyDriverColors.primaryLight)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.profile.fullName)
                        .font(SpotlyDriverTypography.title3)
                        .foregroundStyle(SpotlyDriverColors.label)
                    Text(appState.selectedZone?.name ?? appState.profile.city)
                        .font(SpotlyDriverTypography.subheadline)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    Text(appState.profile.vehicle.displaySummary)
                        .font(SpotlyDriverTypography.caption1)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                }
                Spacer()
            }

            HStack {
                badge("Rating", String(format: "%.1f", appState.profile.rating), "star.fill")
                badge("Jobs", "\(appState.profile.completedJobs)", "checkmark.circle.fill")
                badge("Status", appState.profile.verificationStatus.displayLabel, "checkmark.shield.fill")
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private func badge(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(SpotlyDriverColors.primary)
            Text(value)
                .font(SpotlyDriverTypography.caption1)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(SpotlyDriverTypography.caption2)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
    }

    private func section(_ title: String, _ destinations: [DriverProfileDestination]) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text(title)
                .font(SpotlyDriverTypography.headline)
            VStack(spacing: 0) {
                ForEach(destinations, id: \.self) { destination in
                    profileRow(destination.displayTitle, icon: icon(for: destination)) {
                        switch destination {
                        case .helpSupport:
                            appState.profileNavPath.append(DriverRoute.support)
                        case .safetyCenter:
                            appState.profileNavPath.append(DriverRoute.safety)
                        case .reportIssue:
                            appState.profileNavPath.append(DriverRoute.reportIssue(appState.activeJob?.id))
                        case .deliveryZones:
                            appState.profileNavPath.append(DriverRoute.deliveryZones)
                        case .incidentHistory:
                            appState.profileNavPath.append(DriverRoute.incidentCenter)
                        default:
                            appState.profileNavPath.append(DriverRoute.profileDestination(destination))
                        }
                    }
                    if destination != destinations.last { Divider().padding(.leading, 52) }
                }
            }
            .background(SpotlyDriverColors.cardBackground)
            .overlay(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card).stroke(SpotlyDriverColors.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Settings")
                .font(SpotlyDriverTypography.headline)
            VStack(spacing: 0) {
                profileRow("Appearance", icon: "circle.lefthalf.filled") {
                    appState.profileNavPath.append(DriverRoute.profileDestination(.appearance))
                }
                Divider().padding(.leading, 52)
                profileRow("Demo Controls", icon: "wrench.and.screwdriver.fill") {
                    appState.profileNavPath.append(DriverRoute.profileDestination(.demoControls))
                }
                Divider().padding(.leading, 52)
                profileRow("Reset demo data", icon: "arrow.counterclockwise") {
                    appState.resetDemoData()
                }
                Divider().padding(.leading, 52)
                profileRow("Sign out", icon: "rectangle.portrait.and.arrow.right", tint: SpotlyDriverColors.destructive, isDestructive: true) {
                    appState.signOut()
                }
            }
            .background(SpotlyDriverColors.cardBackground)
            .overlay(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card).stroke(SpotlyDriverColors.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        }
    }

    private func profileRow(_ title: String, icon: String, tint: Color = SpotlyDriverColors.primary, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        SpotlyListRow(
            title: title,
            icon: icon,
            tint: tint,
            isDestructive: isDestructive,
            action: action
        )
    }

    private func icon(for destination: DriverProfileDestination) -> String {
        switch destination {
        case .personalDetails: return "person.text.rectangle"
        case .vehicleDetails: return "car.fill"
        case .documents: return "doc.text.fill"
        case .payoutMethod: return "creditcard.fill"
        case .availabilityPreferences: return "slider.horizontal.3"
        case .deliveryZones: return "map.fill"
        case .jobHistory: return "clock.arrow.circlepath"
        case .shiftHistory: return "calendar.badge.clock"
        case .performance: return "chart.line.uptrend.xyaxis"
        case .incidentHistory: return "exclamationmark.bubble.fill"
        case .helpSupport: return "questionmark.circle.fill"
        case .safetyCenter: return "shield.lefthalf.filled"
        case .reportIssue: return "exclamationmark.triangle.fill"
        case .terms: return "doc.plaintext"
        case .privacy: return "lock.shield"
        case .about: return "info.circle.fill"
        case .appearance: return "circle.lefthalf.filled"
        case .demoControls: return "wrench.and.screwdriver.fill"
        }
    }
}

struct ProfileDestinationView: View {
    let destination: DriverProfileDestination
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                destinationContent
            }
            .padding(SpotlyDriverSpacing.screenEdge)
            .padding(.bottom, SpotlyDriverSpacing.tabBarPadding)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .navigationTitle(destination.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var destinationContent: some View {
        switch destination {
        case .personalDetails:
            PersonalDetailsForm()
        case .vehicleDetails:
            VehicleDetailsForm()
        case .documents:
            DocumentsContent()
        case .payoutMethod:
            PayoutMethodContent()
        case .availabilityPreferences:
            AvailabilityPreferencesContent()
        case .jobHistory:
            DriverJobHistoryContent()
        case .shiftHistory:
            ShiftHistoryView()
        case .performance:
            PerformanceContent()
        case .terms:
            InfoContent(icon: "doc.plaintext", title: "Terms of Service", message: "Drivers agree to complete accepted deliveries carefully, follow merchant pickup requirements, protect customer privacy, and report issues promptly through Spotly Driver.")
        case .privacy:
            InfoContent(icon: "lock.shield", title: "Privacy Policy", message: "Spotly Driver will only use driver, vehicle, location, and delivery data to operate marketplace logistics, safety workflows, support, and payouts at launch.")
        case .about:
            InfoContent(icon: "info.circle.fill", title: "About Spotly Driver", message: "Spotly Driver is the courier operations app for Spotly marketplace deliveries across food, grocery, pharmacy, gifts, events, and local commerce.")
        case .appearance:
            InfoContent(icon: "circle.lefthalf.filled", title: "Appearance", message: "Spotly Driver currently follows the system appearance and the cobalt/neutral Spotly operations design.")
        case .demoControls:
            DemoControlsContent()
        default:
            InfoContent(icon: icon, title: destination.displayTitle, message: message)
        }
    }

    private var icon: String {
        switch destination {
        case .payoutMethod: return "creditcard"
        case .documents: return "doc.text"
        case .performance: return "chart.bar"
        case .shiftHistory: return "calendar.badge.clock"
        case .incidentHistory: return "exclamationmark.bubble"
        case .appearance: return "circle.lefthalf.filled"
        case .demoControls: return "wrench.and.screwdriver.fill"
        default: return "info.circle"
        }
    }

    private var message: String {
        switch destination {
        case .payoutMethod:
            return "EcoCash, bank transfer, and wallet setup will be enabled for verified drivers before launch."
        case .documents:
            return "Driver verification will be reviewed by the Spotly operations team before launch."
        case .terms:
            return "Terms content is a launch placeholder for the demo app."
        case .privacy:
            return "Privacy content is a launch placeholder for the demo app."
        case .about:
            return "Spotly Driver is the courier app for Spotly delivery operations."
        case .availabilityPreferences:
            return "Manage preferred delivery zones, max distance, and quiet-hour placeholders for launch."
        case .shiftHistory:
            return "Review local demo shifts, completed deliveries, incidents, and zone performance."
        case .personalDetails:
            return "\(appState.profile.fullName) · \(appState.profile.phone) · \(appState.profile.email)"
        case .vehicleDetails:
            return appState.profile.vehicle.displaySummary
        case .demoControls:
            return "Prepare local demo scenarios quickly."
        default:
            return "This section is prepared for local demo navigation and will connect to live driver account services later."
        }
    }
}

struct PayoutMethodContent: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var selectedMethod = ""
    @State private var saved = false

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            DriverInfoBanner(icon: "checkmark.shield.fill", message: "Payouts will be enabled for verified driver accounts before launch.", style: .info)
            summaryCard("Current payout method", selectedMethod.isEmpty ? appState.payoutPreference : selectedMethod, icon: "creditcard.fill")
            ForEach(["EcoCash", "Bank transfer", "Spotly wallet"], id: \.self) { method in
                Button {
                    selectedMethod = method
                } label: {
                    HStack {
                        Text(method)
                            .font(SpotlyDriverTypography.subheadline)
                            .foregroundStyle(SpotlyDriverColors.label)
                        Spacer()
                        Image(systemName: selectedMethod == method ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedMethod == method ? SpotlyDriverColors.primary : SpotlyDriverColors.tertiaryLabel)
                    }
                    .padding(SpotlyDriverSpacing.md)
                    .background(SpotlyDriverColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
                }
                .buttonStyle(.plain)
            }
            DriverInfoBanner(icon: "calendar", message: "Weekly payout schedule selected. Manual payout will be enabled before launch.", style: .info)
            DriverButton(title: saved ? "Saved" : "Save Payout Method", style: .primary, icon: "checkmark.circle.fill") {
                appState.updatePayoutPreference(selectedMethod.isEmpty ? appState.payoutPreference : selectedMethod)
                saved = true
            }
        }
        .onAppear {
            selectedMethod = appState.payoutPreference
        }
    }
}

struct PersonalDetailsForm: View {
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var country: SpotlyCountryCode = .ZW
    @State private var city = ""
    @State private var emergencyName = "Tariro Moyo"
    @State private var emergencyPhone = ""
    @State private var language = "English"
    @State private var errorMessage: String?
    @State private var saved = false

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            HStack(spacing: SpotlyDriverSpacing.md) {
                Text(appState.profile.avatarInitials)
                    .font(SpotlyDriverTypography.title2)
                    .foregroundStyle(SpotlyDriverColors.primary)
                    .frame(width: 58, height: 58)
                    .background(SpotlyDriverColors.primaryLight)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text("Driver account")
                        .font(SpotlyDriverTypography.headline)
                    VerificationStatusPill(status: appState.profile.verificationStatus)
                }
                Spacer()
            }
            .padding(SpotlyDriverSpacing.md)
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()

            formField("Full name", text: $fullName)
            formField("Phone number", text: $phone)
            formField("Email", text: $email)
            Picker("Country", selection: $country) { ForEach(SpotlyCountryCatalog.countries, id: \.code) { item in Text(item.name).tag(item.code) } }
            Picker("City", selection: $city) { ForEach(DriverCountryEngine.definition(for: country).cities) { item in Text(item.name).tag(item.name) } }
            formField("Emergency contact", text: $emergencyName)
            formField("Emergency phone", text: $emergencyPhone)
            formField("Preferred language", text: $language)

            if let errorMessage {
                DriverInfoBanner(icon: "exclamationmark.triangle.fill", message: errorMessage, style: .safety)
            } else if saved {
                DriverInfoBanner(icon: "checkmark.circle.fill", message: "Saved locally for demo.", style: .info)
            }

            HStack(spacing: SpotlyDriverSpacing.sm) {
                DriverButton(title: "Cancel", style: .secondary) { dismiss() }
                DriverButton(title: "Save", style: .primary) { save() }
            }
        }
        .onAppear {
            fullName = appState.profile.fullName
            phone = appState.profile.phone
            email = appState.profile.email
            country = appState.profile.countryCode
            city = appState.profile.city
            if emergencyPhone.isEmpty { emergencyPhone = DriverCountryEngine.definition(for: country).dialCode + " " }
        }
    }

    private func save() {
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Full name is required."
            return
        }
        guard !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Phone number is required."
            return
        }
        guard email.isEmpty || email.contains("@") else {
            errorMessage = "Enter a valid email address."
            return
        }
        do {
            try appState.updateProfile(fullName: trimmedName, phone: phone, email: email, country: country, city: city)
            errorMessage = nil
            saved = true
        } catch { errorMessage = error.localizedDescription }
    }
}

struct VehicleDetailsForm: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var type: DriverVehicleType = .motorbike
    @State private var make = ""
    @State private var model = ""
    @State private var color = ""
    @State private var plate = ""
    @State private var saved = false

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            summaryCard(appState.profile.vehicle.type.displayLabel, appState.profile.vehicle.displaySummary, icon: appState.profile.vehicle.type.systemIcon)
            Picker("Vehicle type", selection: $type) {
                ForEach(DriverVehicleType.allCases, id: \.self) { vehicleType in
                    Text(vehicleType.displayLabel).tag(vehicleType)
                }
            }
            .pickerStyle(.menu)
            .padding(SpotlyDriverSpacing.md)
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            formField("Make", text: $make)
            formField("Model", text: $model)
            formField("Color", text: $color)
            formField("Plate number", text: $plate)
            DriverInfoBanner(icon: "shield.fill", message: "Insurance status: pending operations review. Capacity note: small parcel and grocery orders.", style: .info)
            DriverButton(title: saved ? "Saved" : "Save Vehicle", style: .primary, icon: "checkmark.circle.fill") {
                appState.updateVehicle(type: type, make: make, model: model, plateNumber: plate, color: color)
                saved = true
            }
        }
        .onAppear {
            type = appState.profile.vehicle.type
            make = appState.profile.vehicle.make
            model = appState.profile.vehicle.model
            color = appState.profile.vehicle.color
            plate = appState.profile.vehicle.plateNumber
        }
    }
}

struct DocumentsContent: View {
    @State private var submitted: Set<String> = ["Identity document", "Driver profile photo"]

    private let documents = [
        ("Identity document", "person.text.rectangle", "approved"),
        ("Driver profile photo", "person.crop.circle", "approved"),
        ("Vehicle registration", "car.text.rectangle", "pending review"),
        ("Proof of address", "house", "not submitted"),
        ("Driver agreement", "doc.text", "not submitted"),
        ("Safety acknowledgement", "shield.checkered", "pending review")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            DriverInfoBanner(icon: "checkmark.shield.fill", message: "Spotly operations reviews driver documents before launch access is enabled.", style: .info)
            ForEach(documents, id: \.0) { doc in
                documentRow(title: doc.0, icon: doc.1, baseStatus: doc.2)
            }
        }
    }

    private func documentRow(title: String, icon: String, baseStatus: String) -> some View {
        let status = submitted.contains(title) ? "pending review" : baseStatus
        return VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(SpotlyDriverColors.primary)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(SpotlyDriverTypography.subheadline)
                        .fontWeight(.semibold)
                    Text(status.capitalized)
                        .font(SpotlyDriverTypography.caption1)
                        .foregroundStyle(status == "approved" ? SpotlyDriverColors.primary : SpotlyDriverColors.warning)
                }
                Spacer()
            }
            HStack {
                DriverButton(title: "Upload placeholder", style: .secondary, height: 42) {
                    submitted.insert(title)
                }
                DriverButton(title: "Requirements", style: .outline, height: 42) {}
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }
}

struct AvailabilityPreferencesContent: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var maxDistance: Double = 8
    @State private var quietHours = false
    @State private var saved = false

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            summaryCard("Preferred zone", appState.selectedZone?.name ?? (appState.profile.city.isEmpty ? "Not selected" : appState.profile.city), icon: "map.fill")
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                Text("Max delivery distance: \(DriverFormatters.distance(maxDistance))")
                    .font(SpotlyDriverTypography.subheadline)
                Slider(value: $maxDistance, in: 2...15, step: 1)
                    .tint(SpotlyDriverColors.primary)
            }
            .padding(SpotlyDriverSpacing.md)
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            Toggle("Quiet hours placeholder", isOn: $quietHours)
                .padding(SpotlyDriverSpacing.md)
                .background(SpotlyDriverColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            DriverInfoBanner(icon: "bolt.fill", message: "Auto-accept remains off for this demo. Drivers review every request before accepting.", style: .info)
            DriverButton(title: saved ? "Saved" : "Save Preferences", style: .primary, icon: "checkmark.circle.fill") {
                appState.updateAvailabilityPreferences(maxDistance: maxDistance, quietHours: quietHours)
                saved = true
            }
        }
        .onAppear {
            maxDistance = appState.maxDeliveryDistanceKM
            quietHours = appState.quietHoursEnabled
        }
    }
}

struct PerformanceContent: View {
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                HStack {
                    Text("Strong")
                        .font(SpotlyDriverTypography.title2)
                        .foregroundStyle(SpotlyDriverColors.label)
                    Spacer()
                    Text("Reliable")
                        .font(SpotlyDriverTypography.caption1)
                        .fontWeight(.semibold)
                        .foregroundStyle(SpotlyDriverColors.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(SpotlyDriverColors.primaryLight)
                        .clipShape(Capsule())
                }
                Text("You're maintaining a strong acceptance rate and reliable completion record.")
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }
            .padding(SpotlyDriverSpacing.md)
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: SpotlyDriverSpacing.md),
                    GridItem(.flexible(), spacing: SpotlyDriverSpacing.md)
                ],
                spacing: SpotlyDriverSpacing.md
            ) {
                DriverMetricCard(title: "Rating", value: String(format: "%.1f", appState.profile.rating), icon: "star.fill")
                DriverMetricCard(title: "Completed", value: "\(appState.profile.completedJobs)", icon: "checkmark.circle")
                DriverMetricCard(title: "Acceptance", value: DriverFormatters.acceptanceRate(appState.earningsSummary.acceptanceRate), icon: "percent")
                DriverMetricCard(title: "Cancellation", value: "3%", icon: "xmark.circle")
                DriverMetricCard(title: "On-time", value: "94%", icon: "clock")
                DriverMetricCard(title: "Tips", value: DriverFormatters.price(appState.completedJobs.reduce(0) { $0 + $1.tip }), icon: "heart.fill")
            }
            weeklyRows
            feedbackSection
            DriverInfoBanner(icon: "chart.line.uptrend.xyaxis", message: "Live metrics will be calculated from completed Spotly deliveries at launch.", style: .info)
            tipsSection
        }
    }

    private var weeklyRows: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Weekly performance")
                .font(SpotlyDriverTypography.headline)
            ForEach([("Mon", 4), ("Tue", 6), ("Wed", 3), ("Thu", 7), ("Fri", 5), ("Sat", 2)], id: \.0) { day, jobs in
                HStack {
                    Text(day).frame(width: 36, alignment: .leading)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(SpotlyDriverColors.primary)
                        .frame(width: CGFloat(jobs) * 26, height: 10)
                    Spacer()
                    Text("\(jobs) jobs")
                        .font(SpotlyDriverTypography.caption1)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                }
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Recent feedback")
                .font(SpotlyDriverTypography.headline)
            ForEach(["Smooth delivery", "Friendly handoff", "Arrived on time"], id: \.self) { feedback in
                Label(feedback, systemImage: "quote.bubble.fill")
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Performance tips")
                .font(SpotlyDriverTypography.headline)
            ForEach(["Confirm pickup codes before leaving.", "Keep groceries upright and cold items separate.", "Contact support when customer PIN fails.", "Do not open pharmacy packages."], id: \.self) { tip in
                Label(tip, systemImage: "checkmark.circle.fill")
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }
}

struct DriverJobHistoryContent: View {
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            ForEach((appState.completedJobs + appState.cancelledJobs).prefix(8)) { job in
                DriverJobCard(job: job)
            }
        }
    }
}

struct DemoControlsContent: View {
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            DriverInfoBanner(icon: "wrench.and.screwdriver.fill", message: "For internal demo testing. These controls only change local state.", style: .info)
            control("Seed available jobs", "shippingbox.fill") { appState.seedAvailableJobs() }
            control("Seed prepared pickup", "fork.knife") { seed(.preparedFoodPickup) }
            control("Seed grocery shopping job", "cart.fill") { seed(.groceryShopAndDeliver) }
            control("Seed pharmacy job", "cross.fill") { seed(.pharmacyVerifiedPickup) }
            control("Seed cash collection job", "banknote.fill") { seed(.cashCollectionDelivery) }
            control("Seed batch job", "square.stack.3d.up.fill") { appState.seedAvailableJobs() }
            control("Start shift", "play.circle.fill") { appState.startShift(); appState.availability = .online }
            control("End shift", "stop.circle.fill") { appState.endShift(); appState.availability = .offline }
            control("Clear active job", "xmark.circle.fill") { appState.clearActiveJob() }
            control("Mark verification approved", "checkmark.shield.fill") { appState.setVerificationStatus(.verified) }
            control("Mark verification pending", "clock.fill") { appState.setVerificationStatus(.pending) }
            control("Reset earnings", "dollarsign.circle.fill") { appState.earningsSummary = DriverMockData.earningsSummary }
            control("Reset wallet transactions", "list.bullet.rectangle") { appState.walletTransactions = DriverMockData.walletTransactions }
            control("Reset incidents", "exclamationmark.bubble.fill") { appState.incidents = [] }
            control("Reset notifications", "bell.fill") { appState.notifications = DriverMockData.notifications }
            control("Simulate customer unavailable", "person.crop.circle.badge.exclamationmark") { appState.simulateCustomerUnavailable() }
            control("Simulate merchant not ready", "storefront.fill") { appState.simulateMerchantNotReady() }
            control("Reset demo data", "arrow.counterclockwise") { appState.resetDemoData() }
        }
    }

    private func seed(_ type: DeliveryJobType) {
        appState.seedJobs(ofType: type)
    }

    private func control(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(SpotlyDriverColors.primary)
                    .frame(width: 28)
                Text(title)
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(SpotlyDriverColors.label)
                Spacer()
            }
            .padding(SpotlyDriverSpacing.md)
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ShiftHistoryView: View {
    @EnvironmentObject var appState: DriverAppState

    private var shifts: [DriverShift] {
        var all = appState.pastShifts
        if let current = appState.currentShift, !all.contains(where: { $0.id == current.id }) {
            all.insert(current, at: 0)
        }
        return all
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            DriverInfoBanner(icon: "calendar.badge.clock", message: "Shift history is stored locally for demo review.", style: .info)
            if shifts.isEmpty {
                DriverEmptyState(icon: "clock", title: "No shifts yet", message: "Go online to start a driver shift. Ended shifts will appear here.")
                    .frame(minHeight: 320)
            } else {
                ForEach(shifts) { shift in
                    NavigationLink(value: DriverRoute.shiftSummary(shift.id)) {
                        shiftRow(shift)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func shiftRow(_ shift: DriverShift) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(shift.zone)
                        .font(SpotlyDriverTypography.headline)
                        .foregroundStyle(SpotlyDriverColors.label)
                    Text("\(DriverFormatters.formattedDate(shift.startedAt)) · \(shift.status.displayLabel)")
                        .font(SpotlyDriverTypography.caption1)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                }
                Spacer()
                Text(DriverFormatters.price(shift.totalEarnings))
                    .font(SpotlyDriverTypography.headline)
                    .foregroundStyle(SpotlyDriverColors.primary)
            }
            HStack(spacing: SpotlyDriverSpacing.sm) {
                shiftPill("\(shift.completedJobs) jobs", color: SpotlyDriverColors.secondaryLabel)
                shiftPill(DriverFormatters.duration(shift.onlineDurationMinutes), color: SpotlyDriverColors.primary)
                shiftPill(shift.city, color: SpotlyDriverColors.secondaryLabel)
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private func shiftPill(_ title: String, color: Color) -> some View {
        Text(title)
            .font(SpotlyDriverTypography.caption1)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }
}

struct ShiftSummaryView: View {
    let shiftID: String
    @EnvironmentObject var appState: DriverAppState

    private var shift: DriverShift? {
        if let current = appState.currentShift, current.id == shiftID { return current }
        return appState.pastShifts.first { $0.id == shiftID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                if let shift {
                    VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                        Text(shift.status == .active ? "Active shift" : "Shift summary")
                            .font(SpotlyDriverTypography.caption1)
                            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                        Text(shift.zone)
                            .font(SpotlyDriverTypography.title2)
                        Text(DriverFormatters.price(shift.totalEarnings))
                            .font(SpotlyDriverTypography.largeTitle)
                            .foregroundStyle(SpotlyDriverColors.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SpotlyDriverSpacing.md)
                    .background(SpotlyDriverColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
                    .driverCardShadow()

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: SpotlyDriverSpacing.md), GridItem(.flexible(), spacing: SpotlyDriverSpacing.md)], spacing: SpotlyDriverSpacing.md) {
                        DriverMetricCard(title: "Deliveries", value: "\(shift.completedJobs)", subtitle: "completed", icon: "checkmark.circle.fill")
                        DriverMetricCard(title: "Online", value: DriverFormatters.duration(shift.onlineDurationMinutes), subtitle: "shift time", icon: "clock.fill")
                        DriverMetricCard(title: "Incidents", value: "\(appState.incidents.count)", subtitle: "reported", icon: "exclamationmark.bubble.fill")
                        DriverMetricCard(title: "City", value: shift.city, subtitle: "service area", icon: "map.fill")
                    }

                    VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                        detailRow("Started", "\(DriverFormatters.formattedDate(shift.startedAt)) · \(DriverFormatters.formattedTime(shift.startedAt))")
                        detailRow("Ended", shift.endedAt.map { DriverFormatters.formattedTime($0) } ?? "In progress")
                        detailRow("Status", shift.status.displayLabel)
                    }
                    .padding(SpotlyDriverSpacing.md)
                    .background(SpotlyDriverColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
                    .driverCardShadow()
                } else {
                    DriverEmptyState(icon: "clock.badge.questionmark", title: "Shift unavailable", message: "This shift could not be found after local demo state changed.")
                        .frame(minHeight: 360)
                }
            }
            .padding(SpotlyDriverSpacing.screenEdge)
            .padding(.bottom, SpotlyDriverSpacing.tabBarPadding)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .navigationTitle("Shift Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            Spacer()
            Text(value)
                .font(SpotlyDriverTypography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(SpotlyDriverColors.label)
        }
    }
}

struct InfoContent: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(SpotlyDriverColors.primary)
                .frame(width: 64, height: 64)
                .background(SpotlyDriverColors.primaryLight)
                .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            Text(title)
                .font(SpotlyDriverTypography.title2)
            Text(message)
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }
}

private func formField(_ title: String, text: Binding<String>) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(SpotlyDriverTypography.caption1)
            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
        TextField(title, text: text)
            .font(SpotlyDriverTypography.subheadline)
            .textInputAutocapitalization(.words)
    }
    .padding(SpotlyDriverSpacing.md)
    .background(SpotlyDriverColors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
    .driverCardShadow()
}

private func summaryCard(_ title: String, _ subtitle: String, icon: String) -> some View {
    HStack(spacing: SpotlyDriverSpacing.md) {
        Image(systemName: icon)
            .foregroundStyle(SpotlyDriverColors.primary)
            .frame(width: 42, height: 42)
            .background(SpotlyDriverColors.primaryLight)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.small))
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(SpotlyDriverTypography.headline)
            Text(subtitle)
                .font(SpotlyDriverTypography.caption1)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
        }
        Spacer()
    }
    .padding(SpotlyDriverSpacing.md)
    .background(SpotlyDriverColors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
    .driverCardShadow()
}
