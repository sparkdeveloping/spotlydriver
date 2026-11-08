import SwiftUI

struct DriverProfileView: View {
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        NavigationStack(path: $appState.profileNavPath) {
            ScrollView {
                VStack(spacing: SpotlyDriverSpacing.lg) {
                    driverCard
                    section("Account", [.personalDetails, .vehicleDetails, .documents, .payoutMethod, .availabilityPreferences])
                    section("Work", [.deliveryZones, .jobHistory, .performance])
                    section("Support", [.helpSupport, .safetyCenter, .reportIssue, .terms, .privacy, .about])
                    settingsSection
                }
                .padding(SpotlyDriverSpacing.screenEdge)
            }
            .background(SpotlyDriverColors.groupedBackground)
            .navigationTitle("Profile")
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
                    Text(appState.profile.city)
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
                        default:
                            appState.profileNavPath.append(DriverRoute.profileDestination(destination))
                        }
                    }
                    if destination != destinations.last { Divider().padding(.leading, 52) }
                }
            }
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()
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
                profileRow("Reset demo data", icon: "arrow.counterclockwise") {
                    appState.resetDemoData()
                }
                Divider().padding(.leading, 52)
                profileRow("Sign out", icon: "rectangle.portrait.and.arrow.right", tint: SpotlyDriverColors.destructive) {
                    appState.signOut()
                }
            }
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()
        }
    }

    private func profileRow(_ title: String, icon: String, tint: Color = SpotlyDriverColors.primary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: SpotlyDriverSpacing.md) {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                    .frame(width: 28)
                Text(title)
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(tint == SpotlyDriverColors.destructive ? SpotlyDriverColors.destructive : SpotlyDriverColors.label)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
            }
            .frame(minHeight: 56)
            .padding(.horizontal, SpotlyDriverSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
        case .performance: return "chart.line.uptrend.xyaxis"
        case .helpSupport: return "questionmark.circle.fill"
        case .safetyCenter: return "shield.lefthalf.filled"
        case .reportIssue: return "exclamationmark.triangle.fill"
        case .terms: return "doc.plaintext"
        case .privacy: return "lock.shield"
        case .about: return "info.circle.fill"
        case .appearance: return "circle.lefthalf.filled"
        }
    }
}

struct ProfileDestinationView: View {
    let destination: DriverProfileDestination
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                DriverEmptyState(icon: icon, title: destination.displayTitle, message: message)
                    .frame(minHeight: 360)
                if destination == .documents {
                    DriverButton(title: "Open Verification", style: .primary, icon: "checkmark.shield") {
                        appState.profileNavPath.append(DriverRoute.verification)
                    }
                }
            }
            .padding(SpotlyDriverSpacing.screenEdge)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .navigationTitle(destination.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var icon: String {
        switch destination {
        case .payoutMethod: return "creditcard"
        case .documents: return "doc.text"
        case .performance: return "chart.bar"
        case .appearance: return "circle.lefthalf.filled"
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
        default:
            return "This section is prepared for local demo navigation and will connect to live driver account services later."
        }
    }
}
