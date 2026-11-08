import SwiftUI

struct SupportCenterView: View {
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        List {
            Section("Support") {
                supportRow("Current job help", icon: "shippingbox.fill", detail: appState.activeJob?.businessName ?? "No active job")
                supportRow("Payment and payout help", icon: "creditcard.fill", detail: "Payout setup is not live yet")
                supportRow("Account verification", icon: "checkmark.shield.fill", detail: appState.profile.verificationStatus.displayLabel)
                supportRow("Contact Spotly operations", icon: "phone.fill", detail: "Demo placeholder")
            }
            Section("Safety") {
                Button {
                    appState.profileNavPath.append(DriverRoute.safety)
                } label: {
                    Label("Open Safety Center", systemImage: "shield.lefthalf.filled")
                }
                Button {
                    appState.profileNavPath.append(DriverRoute.reportIssue(appState.activeJob?.id))
                } label: {
                    Label("Report an issue", systemImage: "exclamationmark.triangle.fill")
                }
            }
        }
        .navigationTitle("Help & Support")
    }

    private func supportRow(_ title: String, icon: String, detail: String) -> some View {
        HStack(spacing: SpotlyDriverSpacing.md) {
            Image(systemName: icon)
                .foregroundStyle(SpotlyDriverColors.primary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                Text(detail)
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }
        }
        .frame(minHeight: 56)
        .contentShape(Rectangle())
    }
}

struct SafetyCenterView: View {
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                DriverInfoBanner(icon: "exclamationmark.triangle.fill", message: "For emergencies, contact local emergency services first. Spotly operations support is a demo placeholder in this build.", style: .safety)

                safetyCard("Before pickup", ["Confirm the business name and order ID.", "Use safe parking and keep the order secure."])
                safetyCard("At drop-off", ["Confirm the customer name before handing over items.", "Do not enter unsafe buildings or private areas."])
                safetyCard("If something feels wrong", ["Pause requests and move to a safe location.", "Report the issue in the app for local demo tracking."])

                DriverButton(title: "Report Incident", style: .primary, icon: "exclamationmark.triangle.fill") {
                    appState.profileNavPath.append(DriverRoute.reportIssue(appState.activeJob?.id))
                }
                DriverButton(title: "Pause Requests", style: .secondary, icon: "pause.circle.fill") {
                    appState.pauseRequests()
                }
            }
            .padding(SpotlyDriverSpacing.screenEdge)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .navigationTitle("Safety Center")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func safetyCard(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text(title)
                .font(SpotlyDriverTypography.headline)
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "checkmark.circle.fill")
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }
}

struct ReportIssueView: View {
    let jobID: String?
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: DriverIncidentType = .storeNotReady
    @State private var notes = ""
    @State private var submitted = false

    var body: some View {
        NavigationStack {
            Group {
                if submitted {
                    DriverEmptyState(icon: "checkmark.seal.fill", title: "Issue submitted", message: "The issue has been saved locally for this demo. Spotly operations contact is not live yet.", ctaLabel: "Done") {
                        dismiss()
                    }
                } else {
                    Form {
                        Section("Issue type") {
                            Picker("Issue type", selection: $selectedType) {
                                ForEach(DriverIncidentType.allCases, id: \.self) { type in
                                    Text(type.displayLabel).tag(type)
                                }
                            }
                        }
                        Section("Notes") {
                            TextEditor(text: $notes)
                                .frame(minHeight: 120)
                        }
                        Section {
                            Button("Submit issue") {
                                appState.reportIssue(jobID: jobID ?? "general", type: selectedType, notes: notes.isEmpty ? selectedType.displayLabel : notes)
                                submitted = true
                            }
                            .font(SpotlyDriverTypography.headline)
                            .foregroundStyle(SpotlyDriverColors.primary)
                        }
                    }
                }
            }
            .navigationTitle("Report Issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
