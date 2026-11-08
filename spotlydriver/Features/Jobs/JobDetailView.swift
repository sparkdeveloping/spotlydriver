import SwiftUI

struct JobDetailView: View {
    let job: DeliveryJob
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                DriverJobCard(
                    job: job,
                    onAccept: job.status == .offered ? {
                        appState.acceptJob(jobID: job.id)
                        navigateToActiveJob(job.id)
                    } : nil,
                    onDecline: job.status == .offered ? { appState.declineJob(jobID: job.id) } : nil,
                    onContinue: job.status.isActive ? { navigateToActiveJob(job.id) } : nil
                )

                DriverRouteMapPlaceholder(job: job)

                if job.status == .offered {
                    DriverInfoBanner(icon: "sparkles", message: "\(job.recommendationReason) request received \(DriverFormatters.timeAgo(job.createdAt)). Review requirements before accepting.", style: job.cashToCollect > 0 || job.jobType == .pharmacyVerifiedPickup ? .warning : .info)
                }

                detailSection("Route", [
                    ("Pickup", job.pickupAddress),
                    ("Drop-off", job.dropoffAddress),
                    ("Distance", DriverFormatters.distance(job.distanceKM)),
                    ("Estimated time", DriverFormatters.duration(job.estimatedDurationMinutes))
                ])

                detailSection("Order", [
                    ("Order ID", job.orderID),
                    ("Items", job.itemsSummary),
                    ("Customer", job.customerName),
                    ("Phone", job.customerPhoneMasked),
                    ("Status", job.status.displayLabel)
                ])

                detailSection("Payment", [
                    ("Collection", job.paymentCollectionType.displayLabel),
                    ("Base fare", DriverFormatters.price(job.earnings)),
                    ("Tip", DriverFormatters.price(job.tip)),
                    ("Bonus", "Coming soon"),
                    ("Cash to collect", DriverFormatters.price(job.cashToCollect)),
                    ("Earnings", DriverFormatters.price(job.totalEarnings))
                ])

                requirementsSection

                if let notes = job.notes, !notes.isEmpty {
                    DriverInfoBanner(icon: "info.circle.fill", message: notes, style: .info)
                }
            }
            .padding(SpotlyDriverSpacing.screenEdge)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .safeAreaInset(edge: .bottom) {
            if job.status == .offered {
                DriverBottomActionBar {
                    HStack(spacing: SpotlyDriverSpacing.sm) {
                        DriverButton(title: "Decline", style: .secondary) {
                            appState.declineJob(jobID: job.id)
                        }
                        DriverButton(title: "Accept request", style: .primary) {
                            appState.acceptJob(jobID: job.id)
                            navigateToActiveJob(job.id)
                        }
                    }
                }
            }
        }
        .navigationTitle(job.businessName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Requirements")
                .font(SpotlyDriverTypography.headline)
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                requirementRow(job.operationalBadge, icon: job.categoryIcon)
                requirementRow(job.pickupRequirement.displayLabel, icon: "shippingbox.fill")
                requirementRow(job.dropoffRequirement.displayLabel, icon: "house.fill")
                requirementRow(job.paymentHandling.displayLabel, icon: "creditcard.fill")
                if job.jobType == .pharmacyVerifiedPickup {
                    requirementRow("Do not open pharmacy packages", icon: "lock.shield.fill")
                }
            }
            .padding(SpotlyDriverSpacing.md)
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()
        }
    }

    private func requirementRow(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(SpotlyDriverTypography.subheadline)
            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
    }

    private func detailSection(_ title: String, _ rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text(title)
                .font(SpotlyDriverTypography.headline)
            VStack(spacing: 0) {
                ForEach(rows, id: \.0) { row in
                    HStack(alignment: .top) {
                        Text(row.0)
                            .font(SpotlyDriverTypography.subheadline)
                            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                        Spacer(minLength: SpotlyDriverSpacing.md)
                        Text(row.1)
                            .font(SpotlyDriverTypography.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(SpotlyDriverColors.label)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(SpotlyDriverSpacing.md)
                    if row.0 != rows.last?.0 { Divider().padding(.leading, SpotlyDriverSpacing.md) }
                }
            }
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()
        }
    }

    private func navigateToActiveJob(_ id: String) {
        switch appState.selectedTab {
        case .home:
            appState.homeNavPath.append(DriverRoute.activeJob(id))
        case .jobs:
            appState.jobsNavPath.append(DriverRoute.activeJob(id))
        case .earnings:
            appState.earningsNavPath.append(DriverRoute.activeJob(id))
        case .profile:
            appState.profileNavPath.append(DriverRoute.activeJob(id))
        }
    }
}

struct JobUnavailableView: View {
    var body: some View {
        DriverEmptyState(icon: "exclamationmark.magnifyingglass", title: "Job unavailable", message: "This job is no longer available or has moved out of the current demo state.")
            .padding(SpotlyDriverSpacing.screenEdge)
            .background(SpotlyDriverColors.groupedBackground)
            .navigationTitle("Job")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct DriverRouteMapPlaceholder: View {
    let job: DeliveryJob

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            HStack {
                Text("Route")
                    .font(SpotlyDriverTypography.headline)
                    .foregroundStyle(SpotlyDriverColors.label)
                Spacer()
                Text("\(DriverFormatters.distance(job.distanceKM)) · \(DriverFormatters.duration(job.estimatedDurationMinutes))")
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }

            ZStack {
                RoundedRectangle(cornerRadius: SpotlyDriverRadius.card)
                    .fill(SpotlyDriverColors.primaryLight)
                Path { path in
                    path.move(to: CGPoint(x: 44, y: 112))
                    path.addCurve(to: CGPoint(x: 250, y: 44), control1: CGPoint(x: 110, y: 52), control2: CGPoint(x: 175, y: 128))
                }
                .stroke(SpotlyDriverColors.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 7]))
                mapPin(title: "Pickup", area: job.pickupArea, color: SpotlyDriverColors.primary)
                    .position(x: 58, y: 112)
                mapPin(title: "Drop-off", area: job.dropoffArea, color: SpotlyDriverColors.destructive)
                    .position(x: 260, y: 44)
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))

            HStack {
                Text("Live navigation will open Apple Maps before launch.")
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                Spacer()
                Button("Open in Maps") {
                    DriverExternalLinks.openMapsAddress(job.status.stepIndex <= 2 ? job.pickupAddress : job.dropoffAddress)
                }
                .font(SpotlyDriverTypography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(SpotlyDriverColors.primary)
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private func mapPin(title: String, area: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(color)
            Text(title)
                .font(SpotlyDriverTypography.caption2)
                .fontWeight(.semibold)
            Text(area)
                .font(SpotlyDriverTypography.caption2)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                .lineLimit(1)
        }
        .padding(6)
        .background(SpotlyDriverColors.cardBackground.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.small))
    }
}

struct JobSummaryView: View {
    let job: DeliveryJob
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                DriverJobCard(job: job)
                DriverRouteMapPlaceholder(job: job)
                timelineSection
                DriverButton(title: "Report Issue", style: .outline, icon: "exclamationmark.triangle") {
                    appState.jobsNavPath.append(DriverRoute.reportIssue(job.id))
                }
            }
            .padding(SpotlyDriverSpacing.screenEdge)
            .padding(.bottom, SpotlyDriverSpacing.bottomSafePadding)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .navigationTitle(job.status == .delivered ? "Job Summary" : "Job Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Timeline")
                .font(SpotlyDriverTypography.headline)
            let events = job.timeline ?? [JobTimelineEvent(id: "\(job.id)-summary", jobID: job.id, title: job.status.displayLabel, subtitle: job.businessName, timestamp: job.completedAt ?? job.createdAt, status: job.status, iconName: job.categoryIcon)]
            ForEach(events) { event in
                HStack(alignment: .top, spacing: SpotlyDriverSpacing.sm) {
                    Image(systemName: event.iconName)
                        .foregroundStyle(SpotlyDriverColors.primary)
                        .frame(width: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(SpotlyDriverTypography.subheadline)
                            .fontWeight(.semibold)
                        Text("\(event.subtitle) · \(DriverFormatters.formattedTime(event.timestamp))")
                            .font(SpotlyDriverTypography.caption1)
                            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    }
                    Spacer()
                }
                .padding(SpotlyDriverSpacing.md)
                .background(SpotlyDriverColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            }
        }
    }
}

struct DriverNotificationsView: View {
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if appState.notifications.isEmpty {
                    DriverEmptyState(icon: "bell.slash", title: "No notifications", message: "Driver alerts and updates will appear here.")
                        .frame(minHeight: 320)
                } else {
                    ForEach(appState.notifications) { notification in
                        Button {
                            handle(notification)
                        } label: {
                            HStack(alignment: .top, spacing: SpotlyDriverSpacing.md) {
                                Image(systemName: notification.type.systemIcon)
                                    .foregroundStyle(SpotlyDriverColors.primary)
                                    .frame(width: 32, height: 32)
                                    .background(SpotlyDriverColors.primaryLight)
                                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.sm))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.title)
                                        .font(SpotlyDriverTypography.subheadline)
                                        .fontWeight(notification.isRead ? .regular : .semibold)
                                    Text(notification.message)
                                        .font(SpotlyDriverTypography.caption1)
                                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                                    Text(DriverFormatters.timeAgo(notification.createdAt))
                                        .font(SpotlyDriverTypography.caption2)
                                        .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
                                }
                                Spacer()
                                if !notification.isRead {
                                    Circle()
                                        .fill(SpotlyDriverColors.primary)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Read all") { appState.markAllNotificationsRead() }
                }
            }
        }
    }

    private func handle(_ notification: DriverNotification) {
        appState.markNotificationRead(notification.id)
        dismiss()
        switch notification.type {
        case .newJob, .newJobRequest, .jobCancelled:
            if let id = notification.relatedJobID {
                appState.selectedTab = .jobs
                appState.jobsNavPath.append(DriverRoute.jobDetail(id))
            }
        case .pickupCodeRequired, .pickupCodeReady, .dropoffNoteChanged, .customerNoteUpdated:
            if let id = notification.relatedJobID {
                appState.selectedTab = .jobs
                if appState.activeJob?.id == id {
                    appState.jobsNavPath.append(DriverRoute.activeJob(id))
                } else {
                    appState.jobsNavPath.append(DriverRoute.jobDetail(id))
                }
            }
        case .cashCollectionReminder:
            if let id = notification.relatedJobID {
                appState.selectedTab = .jobs
                appState.jobsNavPath.append(appState.activeJob?.id == id ? DriverRoute.cashCollection(id) : DriverRoute.jobDetail(id))
            }
        case .payoutUpdate:
            appState.selectedTab = .earnings
        case .verificationUpdate:
            appState.selectedTab = .profile
            appState.profileNavPath.append(DriverRoute.profileDestination(.documents))
        case .incidentUpdate:
            appState.selectedTab = .profile
            appState.profileNavPath.append(DriverRoute.incidentCenter)
        case .safetyReminder:
            appState.selectedTab = .profile
            appState.profileNavPath.append(DriverRoute.safety)
        case .shiftSummary:
            appState.selectedTab = .earnings
        case .general:
            break
        }
    }
}

struct DriverNotificationDetailView: View {
    let notificationID: String
    @EnvironmentObject var appState: DriverAppState

    private var notification: DriverNotification? {
        appState.notifications.first { $0.id == notificationID }
    }

    var body: some View {
        if let notification {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                Image(systemName: notification.type.systemIcon)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(SpotlyDriverColors.primary)
                    .frame(width: 72, height: 72)
                    .background(SpotlyDriverColors.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
                Text(notification.title)
                    .font(SpotlyDriverTypography.title2)
                    .foregroundStyle(SpotlyDriverColors.label)
                Text(notification.message)
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SpotlyDriverSpacing.screenEdge)
            .background(SpotlyDriverColors.groupedBackground)
            .navigationTitle("Notification")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                appState.markNotificationRead(notification.id)
            }
        } else {
            DriverEmptyState(icon: "bell.slash", title: "Notification unavailable", message: "This notification is no longer available.")
                .padding(SpotlyDriverSpacing.screenEdge)
                .background(SpotlyDriverColors.groupedBackground)
        }
    }
}
