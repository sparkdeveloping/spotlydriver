import SwiftUI

struct ActiveJobView: View {
    let jobID: String
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) var dismiss
    @State private var showReportIssue = false
    @State private var showCancelAlert = false
    @State private var showDirectionsAlert = false

    private var job: DeliveryJob? {
        if let active = appState.activeJob, active.id == jobID { return active }
        return appState.completedJobs.first(where: { $0.id == jobID })
    }

    var body: some View {
        Group {
            if let job {
                if appState.showCompletionSummary, let summary = appState.completedJobSummary, summary.id == jobID {
                    DeliveryCompletionView(job: summary) {
                        appState.dismissCompletionSummary()
                        dismiss()
                    }
                } else {
                    activeJobContent(job: job)
                }
            } else {
                JobUnavailableView()
            }
        }
        .sheet(isPresented: $showReportIssue) {
            ReportIssueView(jobID: jobID)
                .environmentObject(appState)
        }
    }

    @ViewBuilder
    private func activeJobContent(job: DeliveryJob) -> some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: SpotlyDriverSpacing.lg) {
                        statusStepperSection(job: job)
                        jobInfoSection(job: job)
                        routeSection(job: job)
                        itemsSection(job: job)
                        paymentSection(job: job)
                        secondaryActionsSection(job: job)
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                    .padding(.top, SpotlyDriverSpacing.md)
                }
                .background(SpotlyDriverColors.groupedBackground)

                DriverBottomActionBar {
                    DriverButton(title: job.status.nextStepCTA, style: .primary, icon: nextStepIcon(job.status)) {
                        appState.advanceActiveJob()
                    }
                }
            }
            .navigationTitle(job.businessName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(SpotlyDriverColors.label)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { showReportIssue = true }) {
                            Label("Report Issue", systemImage: "exclamationmark.triangle")
                        }
                        Button(role: .destructive, action: { showCancelAlert = true }) {
                            Label("Cancel Delivery", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(SpotlyDriverColors.label)
                    }
                }
            }
            .alert("Cancel Delivery?", isPresented: $showCancelAlert) {
                Button("Cancel Delivery", role: .destructive) {
                    dismiss()
                    appState.goOffline()
                    appState.activeJob = nil
                    appState.goOnline()
                }
                Button("Keep Going", role: .cancel) {}
            } message: {
                Text("This will cancel the delivery and notify the customer. Only cancel if there is a genuine issue.")
            }
        }
    }

    @ViewBuilder
    private func statusStepperSection(job: DeliveryJob) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Delivery Progress")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)

            let steps: [(String, String)] = [
                ("Job Accepted", "Head to \(job.pickupArea)"),
                ("Arrived at Pickup", "Collect from \(job.businessName)"),
                ("Picked Up", "Head to \(job.dropoffArea)"),
                ("Arrived at Drop-off", "Deliver to \(job.customerName)"),
                ("Delivered", "Job complete")
            ]
            let currentIdx = max(0, job.status.stepIndex - 1)

            VStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                    DriverJobStepRow(
                        step: i + 1,
                        title: step.0,
                        subtitle: step.1,
                        isCurrent: i == currentIdx,
                        isCompleted: i < currentIdx,
                        isLast: i == steps.count - 1
                    )
                }
            }
            .padding(SpotlyDriverSpacing.md)
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()
        }
    }

    @ViewBuilder
    private func jobInfoSection(job: DeliveryJob) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Job Details")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)

            VStack(spacing: 0) {
                infoRow(label: "Business", value: job.businessName)
                Divider().padding(.horizontal, SpotlyDriverSpacing.md)
                infoRow(label: "Customer", value: job.customerName)
                Divider().padding(.horizontal, SpotlyDriverSpacing.md)
                infoRow(label: "Order ID", value: "#\(job.orderID)")
                Divider().padding(.horizontal, SpotlyDriverSpacing.md)
                infoRow(label: "Items", value: "\(job.itemCount) item\(job.itemCount == 1 ? "" : "s")")
                Divider().padding(.horizontal, SpotlyDriverSpacing.md)
                infoRow(label: "Earnings", value: DriverFormatters.price(job.totalEarnings), valueColor: SpotlyDriverColors.primary)
            }
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()
        }
    }

    @ViewBuilder
    private func routeSection(job: DeliveryJob) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Route")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)

            VStack(spacing: 0) {
                routeRow(
                    icon: "mappin.circle.fill",
                    iconColor: SpotlyDriverColors.primary,
                    label: "Pickup",
                    address: job.pickupAddress,
                    area: job.pickupArea
                ) {
                    DriverExternalLinks.openMapsAddress(job.pickupAddress)
                }

                Divider().padding(.horizontal, SpotlyDriverSpacing.md)

                routeRow(
                    icon: "mappin.circle.fill",
                    iconColor: SpotlyDriverColors.destructive,
                    label: "Drop-off",
                    address: job.dropoffAddress,
                    area: job.dropoffArea
                ) {
                    DriverExternalLinks.openMapsAddress(job.dropoffAddress)
                }
            }
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()

            HStack(spacing: SpotlyDriverSpacing.sm) {
                statChip(icon: "location", value: DriverFormatters.distance(job.distanceKM))
                statChip(icon: "clock", value: DriverFormatters.duration(job.estimatedDurationMinutes))
                Spacer()
                Button(action: {
                    DriverExternalLinks.openMapsAddress(
                        job.status.stepIndex <= 2 ? job.pickupAddress : job.dropoffAddress
                    )
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Directions")
                            .font(SpotlyDriverTypography.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(SpotlyDriverColors.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func itemsSection(job: DeliveryJob) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Items")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)

            HStack(spacing: SpotlyDriverSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: SpotlyDriverRadius.sm)
                        .fill(SpotlyDriverColors.primaryLight)
                        .frame(width: 40, height: 40)
                    Image(systemName: job.categoryIcon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(SpotlyDriverColors.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(job.itemsSummary)
                        .font(SpotlyDriverTypography.subheadline)
                        .foregroundStyle(SpotlyDriverColors.label)
                    Text("\(job.itemCount) item\(job.itemCount == 1 ? "" : "s") · \(job.pickupTimeWindow)")
                        .font(SpotlyDriverTypography.caption1)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                }
                Spacer()
            }
            .padding(SpotlyDriverSpacing.md)
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()

            if let notes = job.notes, !notes.isEmpty {
                DriverInfoBanner(icon: "info.circle.fill", message: notes, style: .info)
            }
        }
    }

    @ViewBuilder
    private func paymentSection(job: DeliveryJob) -> some View {
        if job.paymentCollectionType.requiresAction || job.cashToCollect > 0 {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                Text("Payment")
                    .font(SpotlyDriverTypography.headline)
                    .foregroundStyle(SpotlyDriverColors.label)

                DriverInfoBanner(
                    icon: "banknote.fill",
                    message: job.cashToCollect > 0
                        ? "Collect \(DriverFormatters.price(job.cashToCollect)) cash from customer at delivery."
                        : job.paymentCollectionType.displayLabel,
                    style: .warning
                )
            }
        }
    }

    @ViewBuilder
    private func secondaryActionsSection(job: DeliveryJob) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Quick Actions")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)

            HStack(spacing: SpotlyDriverSpacing.sm) {
                actionButton(icon: "phone.fill", label: "Call Customer") {
                    DriverExternalLinks.callPhone(job.customerPhoneMasked)
                }
                actionButton(icon: "exclamationmark.triangle.fill", label: "Report Issue", color: SpotlyDriverColors.warning) {
                    showReportIssue = true
                }
            }
        }
    }

    @ViewBuilder
    private func actionButton(icon: String, label: String, color: Color = SpotlyDriverColors.primary, action: @escaping () -> Void) -> some View {
        Button(action: {
            DriverHaptics.light()
            action()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: SpotlyDriverRadius.sm)
                        .fill(color.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(SpotlyDriverTypography.caption1)
                    .fontWeight(.medium)
                    .foregroundStyle(SpotlyDriverColors.label)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(SpotlyDriverSpacing.md)
            .background(SpotlyDriverColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            .driverCardShadow()
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func infoRow(label: String, value: String, valueColor: Color = SpotlyDriverColors.label) -> some View {
        HStack {
            Text(label)
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            Spacer()
            Text(value)
                .font(SpotlyDriverTypography.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, SpotlyDriverSpacing.md)
        .padding(.vertical, SpotlyDriverSpacing.sm)
        .frame(minHeight: 44)
    }

    @ViewBuilder
    private func routeRow(icon: String, iconColor: Color, label: String, address: String, area: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: SpotlyDriverSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(SpotlyDriverTypography.caption2)
                        .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Text(address)
                        .font(SpotlyDriverTypography.subheadline)
                        .foregroundStyle(SpotlyDriverColors.label)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "arrow.triangle.turn.up.right.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpotlyDriverColors.primary)
            }
            .padding(.horizontal, SpotlyDriverSpacing.md)
            .padding(.vertical, SpotlyDriverSpacing.sm)
            .frame(minHeight: 56)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func statChip(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
            Text(value)
                .font(SpotlyDriverTypography.caption1)
                .fontWeight(.medium)
        }
        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
    }

    private func nextStepIcon(_ status: DeliveryJobStatus) -> String? {
        switch status {
        case .accepted: return "mappin.circle.fill"
        case .arrivedAtPickup: return "checkmark.circle.fill"
        case .pickedUp: return "car.fill"
        case .arrivedAtDropoff: return "checkmark.seal.fill"
        default: return nil
        }
    }
}

// MARK: - Completion View
struct DeliveryCompletionView: View {
    let job: DeliveryJob
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: SpotlyDriverSpacing.xl) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(SpotlyDriverColors.primaryLight)
                        .frame(width: 110, height: 110)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundStyle(SpotlyDriverColors.primary)
                }

                VStack(spacing: SpotlyDriverSpacing.sm) {
                    Text("Delivery Complete!")
                        .font(SpotlyDriverTypography.title2)
                        .foregroundStyle(SpotlyDriverColors.label)
                    Text("Great work. Your earnings have been updated.")
                        .font(SpotlyDriverTypography.subheadline)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: SpotlyDriverSpacing.sm) {
                    summaryRow(label: "Earnings", value: DriverFormatters.price(job.totalEarnings), highlight: true)
                    if job.tip > 0 {
                        summaryRow(label: "Tip", value: DriverFormatters.price(job.tip))
                    }
                    summaryRow(label: "Distance", value: DriverFormatters.distance(job.distanceKM))
                    summaryRow(label: "Order ID", value: "#\(job.orderID)")
                    summaryRow(label: "Delivered to", value: job.dropoffArea)
                }
                .padding(SpotlyDriverSpacing.md)
                .background(SpotlyDriverColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
                .driverCardShadow()
                .padding(.horizontal, SpotlyDriverSpacing.screenEdge)

                Spacer()
            }
            .background(SpotlyDriverColors.background)
            .safeAreaInset(edge: .bottom) {
                DriverBottomActionBar {
                    DriverButton(title: "Done", style: .primary) {
                        DriverHaptics.success()
                        onDone()
                    }
                }
            }
            .navigationTitle("Delivery Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func summaryRow(label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            Spacer()
            Text(value)
                .font(highlight ? SpotlyDriverTypography.title3 : SpotlyDriverTypography.subheadline)
                .fontWeight(highlight ? .bold : .medium)
                .foregroundStyle(highlight ? SpotlyDriverColors.primary : SpotlyDriverColors.label)
        }
    }
}
