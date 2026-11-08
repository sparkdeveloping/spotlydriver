import SwiftUI

struct JobDetailView: View {
    let job: DeliveryJob
    @EnvironmentObject var appState: DriverAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                DriverJobCard(
                    job: job,
                    onAccept: job.status == .offered ? { appState.acceptJob(jobID: job.id) } : nil,
                    onDecline: job.status == .offered ? { appState.declineJob(jobID: job.id) } : nil,
                    onContinue: job.status.isActive ? {} : nil
                )

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
                    ("Cash to collect", DriverFormatters.price(job.cashToCollect)),
                    ("Earnings", DriverFormatters.price(job.totalEarnings))
                ])

                if let notes = job.notes, !notes.isEmpty {
                    DriverInfoBanner(icon: "info.circle.fill", message: notes, style: .info)
                }
            }
            .padding(SpotlyDriverSpacing.screenEdge)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .navigationTitle(job.businessName)
        .navigationBarTitleDisplayMode(.inline)
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
        case .newJob, .jobCancelled:
            if let id = notification.relatedJobID {
                appState.selectedTab = .jobs
                appState.jobsNavPath.append(DriverRoute.jobDetail(id))
            }
        case .payoutUpdate:
            appState.selectedTab = .earnings
        case .verificationUpdate:
            appState.selectedTab = .profile
            appState.profileNavPath.append(DriverRoute.profileDestination(.documents))
        case .safetyReminder:
            appState.selectedTab = .profile
            appState.profileNavPath.append(DriverRoute.safety)
        case .general:
            break
        }
    }
}
