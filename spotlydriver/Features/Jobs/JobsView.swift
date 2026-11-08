import SwiftUI

private enum JobsFilter: String, CaseIterable, Hashable {
    case active = "Active"
    case available = "Available"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

private enum JobsRequestFilter: String, CaseIterable, Hashable {
    case all = "All"
    case nearby = "Nearby"
    case highestPay = "Highest pay"
    case quickPickup = "Quick pickup"
    case shop = "Shop"
    case cash = "Cash"
    case pharmacy = "Pharmacy"
    case batch = "Batch"
}

struct JobsView: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var filter: JobsFilter = .available
    @State private var requestFilter: JobsRequestFilter = .all

    private var jobsSubtitle: String {
        if let activeJob = appState.activeJob {
            return "Active delivery for \(activeJob.businessName)."
        }
        if appState.offeredJobs.isEmpty {
            return appState.availability == .offline ? "Go online to receive requests." : "Waiting for new Spotly requests."
        }
        return "\(appState.offeredJobs.count) requests available."
    }

    var body: some View {
        NavigationStack(path: $appState.jobsNavPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sectionSpacing) {
                    SpotlyPageHeader(
                        title: "Jobs",
                        subtitle: jobsSubtitle,
                        location: appState.selectedZone?.name ?? appState.profile.city,
                        variant: .large
                    )
                    Picker("Job status", selection: $filter) {
                        ForEach(JobsFilter.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    content
                }
                .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                .padding(.top, SpotlyDriverSpacing.md)
                .padding(.bottom, SpotlyDriverSpacing.bottomSafePadding)
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

    @ViewBuilder
    private var content: some View {
        switch filter {
        case .active:
            if let job = appState.activeJob {
                DriverJobCard(job: job, onContinue: {
                    appState.jobsNavPath.append(DriverRoute.activeJob(job.id))
                }, onTap: {
                    appState.jobsNavPath.append(DriverRoute.activeJob(job.id))
                })
            } else {
                DriverEmptyState(icon: "shippingbox", title: "No active job", message: "Accept a delivery request to start a live job.", ctaLabel: "Go Online") {
                    appState.selectedTab = .home
                    appState.goOnline()
                }
                .frame(minHeight: 260)
            }
        case .available:
            if appState.activeJob != nil {
                DriverEmptyState(icon: "shippingbox.fill", title: "Delivery in progress", message: "Finish your current delivery before accepting another request.", ctaLabel: "Continue Delivery") {
                    if let id = appState.activeJob?.id {
                        appState.jobsNavPath.append(DriverRoute.activeJob(id))
                    }
                }
                .frame(minHeight: 260)
            } else if appState.offeredJobs.isEmpty {
                DriverEmptyState(icon: "dot.radiowaves.left.and.right", title: appState.availability == .offline ? "Go online to receive requests" : "Waiting for requests", message: appState.availability == .offline ? "Go online in \(appState.selectedZone?.name ?? "your zone") to receive Spotly delivery requests." : "You're online. New requests will appear here.", ctaLabel: appState.availability == .offline ? "Go Online" : nil) {
                    appState.goOnline()
                }
                .frame(minHeight: 260)
            } else {
                availableQueue
            }
        case .completed:
            if appState.completedJobs.isEmpty {
                DriverEmptyState(icon: "checkmark.seal", title: "No completed jobs", message: "Completed deliveries will appear here.")
                    .frame(minHeight: 260)
            } else {
                jobList(appState.completedJobs)
            }
        case .cancelled:
            if appState.cancelledJobs.isEmpty {
                DriverEmptyState(icon: "xmark.circle", title: "No cancelled jobs", message: "Cancelled or failed jobs will appear here.")
                    .frame(minHeight: 260)
            } else {
                jobList(appState.cancelledJobs)
            }
        }
    }

    private var availableQueue: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(filteredOffers.count) available request\(filteredOffers.count == 1 ? "" : "s")")
                        .font(SpotlyDriverTypography.headline)
                        .foregroundStyle(SpotlyDriverColors.label)
                    Text(appState.selectedZone?.name ?? appState.profile.city)
                        .font(SpotlyDriverTypography.caption1)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                }
                Spacer()
                Text("\(appState.pendingDispatchRequests.count) pending")
                    .font(SpotlyDriverTypography.caption1)
                    .fontWeight(.semibold)
                    .foregroundStyle(SpotlyDriverColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(SpotlyDriverColors.primaryLight)
                    .clipShape(Capsule())
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpotlyDriverSpacing.xs) {
                    ForEach(JobsRequestFilter.allCases, id: \.self) { option in
                        Button {
                            requestFilter = option
                        } label: {
                            Text(option.rawValue)
                                .font(SpotlyDriverTypography.caption1)
                                .fontWeight(.semibold)
                                .foregroundStyle(requestFilter == option ? .white : SpotlyDriverColors.secondaryLabel)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(requestFilter == option ? SpotlyDriverColors.primary : SpotlyDriverColors.cardBackground)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
            if filteredOffers.isEmpty {
                DriverEmptyState(icon: "line.3.horizontal.decrease.circle", title: "No matching requests", message: "Try another filter or wait for new dispatch requests.")
                    .frame(minHeight: 260)
            } else {
                jobList(filteredOffers)
            }
        }
    }

    private var filteredOffers: [DeliveryJob] {
        switch requestFilter {
        case .all:
            return appState.offeredJobs
        case .nearby:
            return appState.offeredJobs.filter { $0.distanceKM <= 4.5 }
        case .highestPay:
            return appState.offeredJobs.sorted { $0.totalEarnings > $1.totalEarnings }
        case .quickPickup:
            return appState.offeredJobs.filter { $0.estimatedDurationMinutes <= 18 }
        case .shop:
            return appState.offeredJobs.filter(\.needsShopping)
        case .cash:
            return appState.offeredJobs.filter { $0.cashToCollect > 0 }
        case .pharmacy:
            return appState.offeredJobs.filter { $0.jobType == .pharmacyVerifiedPickup }
        case .batch:
            return []
        }
    }

    private func jobList(_ jobs: [DeliveryJob]) -> some View {
        LazyVStack(spacing: SpotlyDriverSpacing.md) {
            ForEach(jobs) { job in
                DriverJobCard(
                    job: job,
                    onAccept: job.status == .offered ? {
                        appState.acceptJob(jobID: job.id)
                        appState.jobsNavPath.append(DriverRoute.activeJob(job.id))
                    } : nil,
                    onDecline: job.status == .offered ? { appState.declineJob(jobID: job.id) } : nil,
                    onContinue: job.status.isActive ? { appState.jobsNavPath.append(DriverRoute.activeJob(job.id)) } : nil,
                    onTap: { appState.jobsNavPath.append(route(for: job)) }
                )
            }
        }
    }

    private func route(for job: DeliveryJob) -> DriverRoute {
        if job.status.isActive { return .activeJob(job.id) }
        if job.status == .delivered || job.status == .cancelled || job.status == .failed { return .jobSummary(job.id) }
        return .jobDetail(job.id)
    }
}

struct JobsRouteDestination: View {
    let route: DriverRoute
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        Group {
            switch route {
        case .activeJob(let id):
            ActiveJobView(jobID: id)
        case .jobDetail(let id):
            if let job = jobFor(id) {
                JobDetailView(job: job)
            } else {
                JobUnavailableView()
            }
        case .jobSummary(let id):
            if let job = jobFor(id) {
                JobSummaryView(job: job)
            } else {
                JobUnavailableView()
            }
        case .shoppingList(let id):
            ShoppingListView(jobID: id)
        case .pickupCode(let id):
            PickupCodeView(jobID: id)
        case .customerPIN(let id):
            CustomerPINView(jobID: id)
        case .cashCollection(let id):
            CashCollectionView(jobID: id)
        case .proofOfDelivery(let id):
            ProofOfDeliveryPlaceholderView(jobID: id)
        case .customerUnavailable(let id):
            CustomerUnavailableView(jobID: id)
        case .transactionDetail(let id):
            TransactionDetailView(transactionID: id)
        case .shiftHistory:
            ShiftHistoryView()
        case .shiftSummary(let id):
            ShiftSummaryView(shiftID: id)
        case .notificationDetail(let id):
            DriverNotificationDetailView(notificationID: id)
        case .deliveryZones:
            DeliveryZonesView()
        case .incidentCenter:
            IncidentCenterView()
        case .incidentDetail(let id):
            IncidentDetailView(incidentID: id)
        case .reportIssue(let jobID):
            ReportIssueView(jobID: jobID)
        case .support:
            SupportCenterView()
        case .safety:
            SafetyCenterView()
        case .earningsDetail:
            EarningsView()
        case .profileDestination(let destination):
            ProfileDestinationView(destination: destination)
        case .notifications:
            DriverNotificationsView()
        case .verification:
            DriverOnboardingView()
        case .jobUnavailable:
            JobUnavailableView()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private func jobFor(_ id: String) -> DeliveryJob? {
        if let activeJob = appState.activeJob, activeJob.id == id { return activeJob }
        return (appState.offeredJobs + appState.completedJobs + appState.cancelledJobs).first { $0.id == id }
    }
}
