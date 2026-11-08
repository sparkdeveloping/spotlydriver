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

struct DeliveryZonesView: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var inactiveZone: DeliveryZone?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                selectedZoneSummary
                DriverInfoBanner(icon: "map.fill", message: "Select the zone where you want to receive Spotly requests. Inactive zones are launch placeholders.", style: .info)
                ForEach(Dictionary(grouping: appState.deliveryZones, by: \.city).keys.sorted(), id: \.self) { city in
                    VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                        Text(city)
                            .font(SpotlyDriverTypography.headline)
                        ForEach(appState.deliveryZones.filter { $0.city == city }) { zone in
                            zoneRow(zone)
                        }
                    }
                }
                DriverInfoBanner(icon: "sparkles", message: "Spotly will expand driver coverage as launch partners go live.", style: .info)
            }
            .padding(SpotlyDriverSpacing.screenEdge)
            .padding(.bottom, SpotlyDriverSpacing.tabBarPadding)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .navigationTitle("Delivery Zones")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $inactiveZone) { zone in
            VStack(spacing: SpotlyDriverSpacing.lg) {
                Image(systemName: "map.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(SpotlyDriverColors.warning)
                Text("Launch partner zone coming soon")
                    .font(SpotlyDriverTypography.title2)
                Text("\(zone.name) is not open for driver requests yet. Select an active zone in your approved country to go online today.")
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    .multilineTextAlignment(.center)
                DriverButton(title: "Done", style: .primary) {
                    inactiveZone = nil
                }
            }
            .padding(SpotlyDriverSpacing.xl)
            .presentationDetents([.medium])
        }
    }

    private var selectedZoneSummary: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Selected zone")
                .font(SpotlyDriverTypography.caption1)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            Text(appState.selectedZone?.name ?? "No zone selected")
                .font(SpotlyDriverTypography.title2)
                .foregroundStyle(SpotlyDriverColors.label)
            HStack {
                Text(appState.selectedZone?.demandLevel.displayLabel ?? "Select zone")
                Text("\(appState.selectedZone?.estimatedRequests ?? 0) estimated requests")
            }
            .font(SpotlyDriverTypography.caption1)
            .foregroundStyle(SpotlyDriverColors.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private func zoneRow(_ zone: DeliveryZone) -> some View {
        Button {
            if zone.isActive {
                appState.selectZone(zone.id)
            } else {
                inactiveZone = zone
            }
        } label: {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(zone.name)
                            .font(SpotlyDriverTypography.headline)
                            .foregroundStyle(zone.isActive ? SpotlyDriverColors.label : SpotlyDriverColors.secondaryLabel)
                        Text(zone.areas.joined(separator: ", "))
                            .font(SpotlyDriverTypography.caption1)
                            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    }
                    Spacer()
                    Image(systemName: zone.isActive ? (appState.selectedZoneID == zone.id ? "checkmark.circle.fill" : "circle") : "lock.fill")
                        .foregroundStyle(zone.isActive ? (appState.selectedZoneID == zone.id ? SpotlyDriverColors.primary : SpotlyDriverColors.tertiaryLabel) : SpotlyDriverColors.secondaryLabel)
                }
                HStack(spacing: SpotlyDriverSpacing.sm) {
                    Text(zone.isActive ? zone.demandLevel.displayLabel : "Coming soon")
                    Text("\(zone.estimatedRequests) est. requests")
                }
                .font(SpotlyDriverTypography.caption1)
                .foregroundStyle(zone.isActive ? SpotlyDriverColors.primary : SpotlyDriverColors.secondaryLabel)
                Text(zone.notes)
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }
            .padding(SpotlyDriverSpacing.md)
            .background(zone.isActive ? SpotlyDriverColors.cardBackground : SpotlyDriverColors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct IncidentCenterView: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var showResolved = false

    private var filteredIncidents: [DriverIncident] {
        appState.incidents.filter { showResolved ? $0.status == .resolved : $0.status != .resolved }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                DriverSegmentedControl(options: [false, true], selected: $showResolved) { $0 ? "Resolved" : "Open" }
                if filteredIncidents.isEmpty {
                    DriverEmptyState(icon: "exclamationmark.bubble", title: showResolved ? "No resolved incidents" : "No open incidents", message: "Reported issues will appear here after submission.")
                        .frame(minHeight: 360)
                } else {
                    ForEach(filteredIncidents) { incident in
                        NavigationLink(value: DriverRoute.incidentDetail(incident.id)) {
                            incidentCard(incident)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(SpotlyDriverSpacing.screenEdge)
            .padding(.bottom, SpotlyDriverSpacing.bottomSafePadding)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .navigationTitle("Incident Center")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func incidentCard(_ incident: DriverIncident) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            HStack {
                Text(incident.type.displayLabel)
                    .font(SpotlyDriverTypography.headline)
                    .foregroundStyle(SpotlyDriverColors.label)
                Spacer()
                Text(incident.status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(incident.status == .resolved ? SpotlyDriverColors.primary : SpotlyDriverColors.warning)
            }
            Text(incident.notes)
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            Text(DriverFormatters.formattedDate(incident.createdAt))
                .font(SpotlyDriverTypography.caption1)
                .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }
}

struct IncidentDetailView: View {
    let incidentID: String
    @EnvironmentObject var appState: DriverAppState

    private var incident: DriverIncident? {
        appState.incidents.first { $0.id == incidentID }
    }

    var body: some View {
        if let incident {
            ScrollView {
                VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                    DriverEmptyState(icon: "exclamationmark.triangle.fill", title: incident.type.displayLabel, message: incident.notes)
                    detailRow("Status", incident.status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                    detailRow("Related job", incident.jobID)
                    detailRow("Created", DriverFormatters.formattedDate(incident.createdAt))
                    if incident.status != .resolved {
                        DriverButton(title: "Mark Resolved", style: .primary, icon: "checkmark.circle.fill") {
                            appState.markIncidentResolved(incident.id)
                        }
                    }
                }
                .padding(SpotlyDriverSpacing.screenEdge)
            }
            .background(SpotlyDriverColors.groupedBackground)
            .navigationTitle("Incident Detail")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            DriverEmptyState(icon: "exclamationmark.magnifyingglass", title: "Incident unavailable", message: "This incident is no longer available.")
                .padding(SpotlyDriverSpacing.screenEdge)
                .background(SpotlyDriverColors.groupedBackground)
        }
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
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
    }
}
