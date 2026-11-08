import SwiftUI

private enum JobsFilter: String, CaseIterable, Hashable {
    case active = "Active"
    case available = "Available"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

struct JobsView: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var filter: JobsFilter = .available

    var body: some View {
        NavigationStack(path: $appState.jobsNavPath) {
            ScrollView {
                VStack(spacing: SpotlyDriverSpacing.lg) {
                    DriverSegmentedControl(options: JobsFilter.allCases, selected: $filter) { $0.rawValue }
                    content
                }
                .padding(SpotlyDriverSpacing.screenEdge)
            }
            .background(SpotlyDriverColors.groupedBackground)
            .navigationTitle("Jobs")
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
                .frame(minHeight: 420)
            }
        case .available:
            if appState.offeredJobs.isEmpty {
                DriverEmptyState(icon: "dot.radiowaves.left.and.right", title: "No available jobs", message: appState.availability == .offline ? "Go online to receive Spotly delivery requests." : "You are online. New requests will appear here.", ctaLabel: appState.availability == .offline ? "Go Online" : nil) {
                    appState.goOnline()
                }
                .frame(minHeight: 420)
            } else {
                jobList(appState.offeredJobs)
            }
        case .completed:
            if appState.completedJobs.isEmpty {
                DriverEmptyState(icon: "checkmark.seal", title: "No completed jobs", message: "Completed deliveries will appear here.")
                    .frame(minHeight: 420)
            } else {
                jobList(appState.completedJobs)
            }
        case .cancelled:
            if appState.cancelledJobs.isEmpty {
                DriverEmptyState(icon: "xmark.circle", title: "No cancelled jobs", message: "Cancelled or failed jobs will appear here.")
                    .frame(minHeight: 420)
            } else {
                jobList(appState.cancelledJobs)
            }
        }
    }

    private func jobList(_ jobs: [DeliveryJob]) -> some View {
        LazyVStack(spacing: SpotlyDriverSpacing.md) {
            ForEach(jobs) { job in
                DriverJobCard(
                    job: job,
                    onAccept: job.status == .offered ? { appState.acceptJob(jobID: job.id) } : nil,
                    onDecline: job.status == .offered ? { appState.declineJob(jobID: job.id) } : nil,
                    onContinue: job.status.isActive ? { appState.jobsNavPath.append(DriverRoute.activeJob(job.id)) } : nil,
                    onTap: { appState.jobsNavPath.append(job.status.isActive ? DriverRoute.activeJob(job.id) : DriverRoute.jobDetail(job.id)) }
                )
            }
        }
    }
}

struct JobsRouteDestination: View {
    let route: DriverRoute
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        switch route {
        case .activeJob(let id):
            ActiveJobView(jobID: id)
        case .jobDetail(let id):
            if let job = jobFor(id) {
                JobDetailView(job: job)
            } else {
                JobUnavailableView()
            }
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

    private func jobFor(_ id: String) -> DeliveryJob? {
        if let activeJob = appState.activeJob, activeJob.id == id { return activeJob }
        return (appState.offeredJobs + appState.completedJobs + appState.cancelledJobs).first { $0.id == id }
    }
}
