import SwiftUI

struct DriverHomeView: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var showNotifications = false
    @State private var showActiveJob = false
    @State private var showEndShiftConfirmation = false

    var body: some View {
        NavigationStack(path: $appState.homeNavPath) {
            ScrollView {
                VStack(spacing: SpotlyDriverSpacing.lg) {
                    DriverPageHeader(
                        city: appState.selectedZone?.name ?? appState.profile.city,
                        name: appState.profile.firstName,
                        initials: appState.profile.avatarInitials,
                        availability: appState.availability,
                        unreadCount: appState.unreadNotificationCount
                    ) {
                        showNotifications = true
                    }
                    statusSection
                    shiftSection
                    activeJobSection
                    offeredJobSection
                    metricsSection
                    safetyBanner
                }
                .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                .padding(.top, SpotlyDriverSpacing.md)
                .padding(.bottom, SpotlyDriverSpacing.bottomSafePadding)
            }
            .background(SpotlyDriverColors.groupedBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: DriverRoute.self) { route in
                destinationView(for: route)
                    .toolbar(.hidden, for: .tabBar)
            }
            .sheet(isPresented: $showNotifications) {
                DriverNotificationsView()
                    .environmentObject(appState)
            }
            .fullScreenCover(isPresented: $showActiveJob) {
                if let job = appState.activeJob {
                    ActiveJobView(jobID: job.id)
                        .environmentObject(appState)
                }
            }
            .alert("End shift?", isPresented: $showEndShiftConfirmation) {
                Button("End Shift", role: .destructive) {
                    appState.goOffline()
                }
                Button("Stay Online", role: .cancel) {}
            } message: {
                Text("You completed \(appState.currentShift?.completedJobs ?? 0) deliveries and earned \(DriverFormatters.price(appState.currentShift?.totalEarnings ?? 0)) on this shift.")
            }
            .onChange(of: appState.activeJob) { _, newJob in
                if newJob != nil && newJob?.status != .delivered {
                    showActiveJob = true
                }
            }
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            switch appState.availability {
            case .offline:
                statusCard(
                    icon: "moon.fill",
                    iconColor: SpotlyDriverColors.statusOffline,
                    title: "You're Offline",
                    subtitle: "Go online to receive Spotly delivery requests.",
                    background: SpotlyDriverColors.secondaryBackground
                )
            case .online:
                statusCard(
                    icon: "checkmark.circle.fill",
                    iconColor: SpotlyDriverColors.primary,
                    title: "You're Online",
                    subtitle: offeredJobsSubtitle,
                    background: SpotlyDriverColors.primaryLight
                )
            case .onJob:
                statusCard(
                    icon: "shippingbox.fill",
                    iconColor: SpotlyDriverColors.warning,
                    title: "On Delivery",
                    subtitle: "Complete your current delivery to receive new requests.",
                    background: SpotlyDriverColors.warning.opacity(0.12)
                )
            case .paused:
                statusCard(
                    icon: "pause.circle.fill",
                    iconColor: SpotlyDriverColors.warning,
                    title: "Requests Paused",
                    subtitle: "You won't receive new delivery requests while paused.",
                    background: SpotlyDriverColors.warning.opacity(0.12)
                )
            case .verificationRequired:
                statusCard(
                    icon: "checkmark.shield.fill",
                    iconColor: SpotlyDriverColors.destructive,
                    title: "Verification Required",
                    subtitle: appState.goOnlineErrorReason ?? "Complete verification before going online.",
                    background: SpotlyDriverColors.destructive.opacity(0.1)
                )
            case .zoneUnavailable:
                statusCard(
                    icon: "map.fill",
                    iconColor: SpotlyDriverColors.warning,
                    title: "Zone Unavailable",
                    subtitle: appState.goOnlineErrorReason ?? "Select an active launch zone to receive requests.",
                    background: SpotlyDriverColors.warning.opacity(0.12)
                )
            }
        }
    }

    private var shiftSection: some View {
        Button {
            appState.homeNavPath.append(DriverRoute.deliveryZones)
        } label: {
            HStack(spacing: SpotlyDriverSpacing.md) {
                Image(systemName: "map.fill")
                    .foregroundStyle(SpotlyDriverColors.primary)
                    .frame(width: 36, height: 36)
                    .background(SpotlyDriverColors.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.small))
                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.currentShift?.status == .active ? "Online in \(appState.selectedZone?.name ?? "selected zone")" : "Selected zone")
                        .font(SpotlyDriverTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(SpotlyDriverColors.label)
                    Text(shiftSubtitle)
                        .font(SpotlyDriverTypography.caption1)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
            }
            .padding(SpotlyDriverSpacing.md)
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()
        }
        .buttonStyle(.plain)
    }

    private var shiftSubtitle: String {
        if let shift = appState.currentShift {
            return "Shift started \(DriverFormatters.formattedTime(shift.startedAt)) · \(appState.shiftSummaryText)"
        }
        return "\(appState.selectedZone?.city ?? appState.profile.city) · \(appState.selectedZone?.demandLevel.displayLabel ?? "Select zone")"
    }

    private var offeredJobsSubtitle: String {
        if appState.offeredJobs.isEmpty {
            return "Waiting for delivery requests in \(appState.profile.city)..."
        }
        return "\(appState.offeredJobs.count) delivery request\(appState.offeredJobs.count == 1 ? "" : "s") available."
    }

    @ViewBuilder
    private func statusCard(icon: String, iconColor: Color, title: String, subtitle: String, background: Color) -> some View {
        HStack(spacing: SpotlyDriverSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SpotlyDriverTypography.headline)
                    .foregroundStyle(SpotlyDriverColors.label)
                Text(subtitle)
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(SpotlyDriverSpacing.cardPadding)
        .background(SpotlyDriverColors.cardBackground)
        .overlay(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card).stroke(SpotlyDriverColors.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    @ViewBuilder
    private var activeJobSection: some View {
        if let job = appState.activeJob, job.status.isActive {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                Text("Active Delivery")
                    .font(SpotlyDriverTypography.headline)
                    .foregroundStyle(SpotlyDriverColors.label)

                DriverJobCard(job: job, onContinue: {
                    showActiveJob = true
                })
            }
        }
    }

    @ViewBuilder
    private var offeredJobSection: some View {
        if appState.availability == .online || appState.availability == .paused,
           let offered = appState.currentOfferedJob {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                HStack {
                    Text("New Request")
                        .font(SpotlyDriverTypography.headline)
                        .foregroundStyle(SpotlyDriverColors.label)
                    Spacer()
                    Button("View all") {
                        appState.selectedTab = .jobs
                    }
                    .font(SpotlyDriverTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(SpotlyDriverColors.primary)
                    Text(DriverFormatters.timeAgo(offered.createdAt))
                        .font(SpotlyDriverTypography.caption1)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                }

                DriverJobCard(
                    job: offered,
                    onAccept: {
                        appState.acceptJob(jobID: offered.id)
                        showActiveJob = true
                    },
                    onDecline: {
                        appState.declineJob(jobID: offered.id)
                    },
                    onTap: {
                        appState.homeNavPath.append(DriverRoute.jobDetail(offered.id))
                    }
                )
            }
        }
    }

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Today")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: SpotlyDriverSpacing.md),
                    GridItem(.flexible(), spacing: SpotlyDriverSpacing.md)
                ],
                spacing: SpotlyDriverSpacing.md
            ) {
                DriverMetricCard(
                    title: "Earnings",
                    value: DriverFormatters.price(appState.earningsSummary.todayEarnings),
                    subtitle: "today",
                    icon: "dollarsign.circle",
                    trend: .up("+\(appState.earningsSummary.completedToday) jobs")
                )
                DriverMetricCard(
                    title: "Deliveries",
                    value: "\(appState.earningsSummary.completedToday)",
                    subtitle: "completed",
                    icon: "checkmark.circle"
                )
                DriverMetricCard(
                    title: "Acceptance",
                    value: DriverFormatters.acceptanceRate(appState.earningsSummary.acceptanceRate),
                    subtitle: "requests",
                    icon: "percent"
                )
                DriverMetricCard(
                    title: "Online",
                    value: DriverFormatters.onlineHours(appState.earningsSummary.onlineHours),
                    subtitle: "shift time",
                    icon: "clock"
                )
            }
        }
    }

    private var safetyBanner: some View {
        DriverInfoBanner(
            icon: "exclamationmark.triangle.fill",
            message: "For emergencies, contact local emergency services first.",
            actionLabel: "Safety",
            action: {
                appState.homeNavPath.append(DriverRoute.safety)
            },
            style: .safety
        )
    }

    private var availabilityToggle: some View {
        Group {
            switch appState.availability {
            case .offline:
                DriverButton(title: "Go Online", style: .primary, icon: "power") {
                    withAnimation(SpotlyDriverMotion.spring) {
                        appState.goOnline()
                    }
                }
            case .verificationRequired, .zoneUnavailable:
                DriverButton(title: appState.availability == .zoneUnavailable ? "Change Zone" : "Open Verification", style: .primary, icon: appState.availability == .zoneUnavailable ? "map.fill" : "checkmark.shield.fill") {
                    if appState.availability == .zoneUnavailable {
                        appState.homeNavPath.append(DriverRoute.deliveryZones)
                    } else {
                        appState.homeNavPath.append(DriverRoute.profileDestination(.documents))
                    }
                }
            case .online:
                HStack(spacing: SpotlyDriverSpacing.sm) {
                    DriverButton(title: "Pause", style: .secondary, height: 50) {
                        appState.pauseRequests()
                    }
                    .frame(width: 100)
                    DriverButton(title: "Go Offline", style: .destructive, height: 50) {
                        if (appState.currentShift?.completedJobs ?? 0) > 0 {
                            showEndShiftConfirmation = true
                        } else {
                            withAnimation(SpotlyDriverMotion.spring) {
                                appState.goOffline()
                            }
                        }
                    }
                }
            case .paused:
                HStack(spacing: SpotlyDriverSpacing.sm) {
                    DriverButton(title: "Resume", style: .primary, height: 50) {
                        appState.resumeRequests()
                    }
                    DriverButton(title: "Go Offline", style: .destructive, height: 50) {
                        if (appState.currentShift?.completedJobs ?? 0) > 0 {
                            showEndShiftConfirmation = true
                        } else {
                            withAnimation(SpotlyDriverMotion.spring) {
                                appState.goOffline()
                            }
                        }
                    }
                }
            case .onJob:
                DriverButton(title: "Continue Delivery", style: .primary, icon: "arrow.right.circle.fill") {
                    showActiveJob = true
                }
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: DriverRoute) -> some View {
        switch route {
        case .jobDetail(let id):
            if let job = jobFor(id) {
                JobDetailView(job: job)
                    .environmentObject(appState)
            } else {
                JobUnavailableView()
            }
        case .activeJob:
            if let job = appState.activeJob {
                ActiveJobView(jobID: job.id)
                    .environmentObject(appState)
            } else {
                JobUnavailableView()
            }
        case .shoppingList(let id):
            ShoppingListView(jobID: id)
                .environmentObject(appState)
        case .pickupCode(let id):
            PickupCodeView(jobID: id)
                .environmentObject(appState)
        case .customerPIN(let id):
            CustomerPINView(jobID: id)
                .environmentObject(appState)
        case .cashCollection(let id):
            CashCollectionView(jobID: id)
                .environmentObject(appState)
        case .proofOfDelivery(let id):
            ProofOfDeliveryPlaceholderView(jobID: id)
                .environmentObject(appState)
        case .customerUnavailable(let id):
            CustomerUnavailableView(jobID: id)
                .environmentObject(appState)
        case .transactionDetail(let id):
            TransactionDetailView(transactionID: id)
                .environmentObject(appState)
        case .shiftHistory:
            ShiftHistoryView()
                .environmentObject(appState)
        case .shiftSummary(let id):
            ShiftSummaryView(shiftID: id)
                .environmentObject(appState)
        case .jobSummary(let id):
            if let job = jobFor(id) {
                JobSummaryView(job: job)
                    .environmentObject(appState)
            } else {
                JobUnavailableView()
            }
        case .notificationDetail(let id):
            DriverNotificationDetailView(notificationID: id)
                .environmentObject(appState)
        case .deliveryZones:
            DeliveryZonesView()
                .environmentObject(appState)
        case .incidentCenter:
            IncidentCenterView()
                .environmentObject(appState)
        case .incidentDetail(let id):
            IncidentDetailView(incidentID: id)
                .environmentObject(appState)
        case .support:
            SupportCenterView()
                .environmentObject(appState)
        case .safety:
            SafetyCenterView()
                .environmentObject(appState)
        case .reportIssue(let jobID):
            ReportIssueView(jobID: jobID)
                .environmentObject(appState)
        case .notifications:
            DriverNotificationsView()
                .environmentObject(appState)
        case .verification:
            DriverOnboardingView()
                .environmentObject(appState)
        case .earningsDetail:
            EarningsView()
                .environmentObject(appState)
        case .profileDestination(let dest):
            ProfileDestinationView(destination: dest)
                .environmentObject(appState)
        case .jobUnavailable:
            JobUnavailableView()
        }
    }

    private func jobFor(_ id: String) -> DeliveryJob? {
        if let job = appState.activeJob, job.id == id { return job }
        if let job = appState.offeredJobs.first(where: { $0.id == id }) { return job }
        if let job = appState.completedJobs.first(where: { $0.id == id }) { return job }
        if let job = appState.cancelledJobs.first(where: { $0.id == id }) { return job }
        return nil
    }
}
