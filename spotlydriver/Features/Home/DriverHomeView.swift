import SwiftUI

struct DriverHomeView: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var showNotifications = false
    @State private var showActiveJob = false

    var body: some View {
        NavigationStack(path: $appState.homeNavPath) {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: SpotlyDriverSpacing.lg) {
                        headerSection
                        statusSection
                        activeJobSection
                        offeredJobSection
                        metricsSection
                        safetyBanner
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                    .padding(.top, SpotlyDriverSpacing.md)
                }
                .background(SpotlyDriverColors.groupedBackground)

                // Bottom CTA
                VStack(spacing: 0) {
                    Divider()
                    availabilityToggle
                        .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                        .padding(.top, SpotlyDriverSpacing.md)
                        .padding(.bottom, SpotlyDriverSpacing.md)
                        .background(SpotlyDriverColors.background.ignoresSafeArea(edges: .bottom))
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(SpotlyDriverColors.primary)
                        Text(appState.profile.city)
                            .font(SpotlyDriverTypography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(SpotlyDriverColors.label)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showNotifications = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(SpotlyDriverColors.label)
                            if appState.unreadNotificationCount > 0 {
                                Circle()
                                    .fill(SpotlyDriverColors.destructive)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationDestination(for: DriverRoute.self) { route in
                destinationView(for: route)
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
            .onChange(of: appState.activeJob) { _, newJob in
                if newJob != nil && newJob?.status != .delivered {
                    showActiveJob = true
                }
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(appState.profile.firstName)")
                    .font(SpotlyDriverTypography.title2)
                    .foregroundStyle(SpotlyDriverColors.label)
                DriverStatusPill(availability: appState.availability)
            }
            Spacer()
            avatarView
        }
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(SpotlyDriverColors.primaryLight)
                .frame(width: 48, height: 48)
            Text(appState.profile.avatarInitials)
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.primary)
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
            }
        }
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
        .padding(SpotlyDriverSpacing.md)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
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

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: SpotlyDriverSpacing.sm) {
                DriverMetricCard(
                    title: "Earnings",
                    value: DriverFormatters.price(appState.earningsSummary.todayEarnings),
                    icon: "dollarsign.circle"
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
                    icon: "percent"
                )
                DriverMetricCard(
                    title: "Online",
                    value: DriverFormatters.onlineHours(appState.earningsSummary.onlineHours),
                    subtitle: "hours",
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
            case .online, .paused:
                HStack(spacing: SpotlyDriverSpacing.sm) {
                    DriverButton(title: "Pause", style: .secondary, height: 50) {
                        appState.pauseRequests()
                    }
                    .frame(width: 100)
                    DriverButton(title: "Go Offline", style: .destructive, height: 50) {
                        withAnimation(SpotlyDriverMotion.spring) {
                            appState.goOffline()
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
