import SwiftUI

struct EarningsView: View {
    @EnvironmentObject var appState: DriverAppState

    private let chartValues: [Double] = [8.50, 12.25, 6.75, 15.00, 9.50, 3.25, 13.00]
    private let chartLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Today"]

    var body: some View {
        NavigationStack(path: $appState.earningsNavPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sectionSpacing) {
                    SpotlyPageHeader(
                        title: "Earnings",
                        subtitle: "Today, weekly activity, payouts, and cash reconciliation.",
                        variant: .large
                    )
                    summaryHeader
                    metricsGrid
                    weeklyChart
                    shiftSummary
                    walletSection
                    payoutSection
                    transactionsSection
                    recentJobs
                }
                .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                .padding(.top, SpotlyDriverSpacing.md)
                .padding(.bottom, SpotlyDriverSpacing.tabBarPadding)
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

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Today")
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            Text(DriverFormatters.price(appState.earningsSummary.todayEarnings))
                .font(SpotlyDriverTypography.largeTitle)
                .foregroundStyle(SpotlyDriverColors.label)
            Text("Pending payout: \(DriverFormatters.price(appState.earningsSummary.pendingPayout))")
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpotlyDriverSpacing.lg)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.heroCard))
        .driverCardShadow()
    }

    private var metricsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: SpotlyDriverSpacing.md),
                GridItem(.flexible(), spacing: SpotlyDriverSpacing.md)
            ],
            spacing: SpotlyDriverSpacing.md
        ) {
            DriverMetricCard(title: "Weekly", value: DriverFormatters.price(appState.earningsSummary.weeklyEarnings), subtitle: "this week", icon: "calendar")
            DriverMetricCard(title: "Completed", value: "\(appState.earningsSummary.completedToday)", subtitle: "today", icon: "checkmark.circle")
            DriverMetricCard(title: "Online", value: DriverFormatters.onlineHours(appState.earningsSummary.onlineHours), subtitle: "shift time", icon: "clock")
            DriverMetricCard(title: "Acceptance", value: DriverFormatters.acceptanceRate(appState.earningsSummary.acceptanceRate), subtitle: "requests", icon: "percent")
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            Text("Weekly activity")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)

            HStack(alignment: .bottom, spacing: SpotlyDriverSpacing.sm) {
                ForEach(Array(chartValues.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index == chartValues.count - 1 ? SpotlyDriverColors.primary : SpotlyDriverColors.primaryLight)
                            .frame(height: max(18, CGFloat(value / 15.0) * 120))
                        Text(index < chartLabels.count ? chartLabels[index] : "")
                            .font(SpotlyDriverTypography.caption2)
                            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private var payoutSection: some View {
        DriverInfoBanner(
            icon: "creditcard.fill",
            message: "Payouts will be enabled with verified driver accounts before launch. EcoCash, bank transfer, and wallet options are placeholders.",
            actionLabel: "Payout setup",
            action: {
                appState.earningsNavPath.append(DriverRoute.profileDestination(.payoutMethod))
            },
            style: .info
        )
    }

    private var walletSection: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Wallet")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)
            detailRow("Available balance", DriverFormatters.price(0))
            detailRow("Pending payout", DriverFormatters.price(appState.earningsSummary.pendingPayout))
            detailRow("Base fares", DriverFormatters.price(appState.walletTransactions.filter { $0.type == .deliveryCompleted }.reduce(0) { $0 + $1.amount }))
            detailRow("Tips", DriverFormatters.price(appState.walletTransactions.filter { $0.type == .tipReceived }.reduce(0) { $0 + $1.amount }))
            detailRow("Cash recorded", DriverFormatters.price(appState.walletTransactions.filter { $0.type == .cashCollected }.reduce(0) { $0 + $1.amount }))
            detailRow("Bonuses", "Coming soon")
            DriverInfoBanner(icon: "banknote.fill", message: "Cash reconciliation workflow will be enabled for launch operations.", style: .warning)
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Transactions")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)
            if appState.walletTransactions.isEmpty {
                DriverEmptyState(icon: "list.bullet.rectangle", title: "No transactions", message: "Completed deliveries, tips, cash records, and payouts will appear here.")
                    .frame(minHeight: 220)
            } else {
                ForEach(appState.walletTransactions.prefix(8)) { transaction in
                    Button {
                        appState.earningsNavPath.append(DriverRoute.transactionDetail(transaction.id))
                    } label: {
                        transactionRow(transaction.type.displayLabel, "\(transaction.type == .cashCollected ? "" : "+")\(DriverFormatters.price(transaction.amount))", transaction.notes)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private var shiftSummary: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Today's shift")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)
            if let shift = appState.currentShift {
                detailRow("Zone", shift.zone)
                detailRow("Shift started", DriverFormatters.formattedTime(shift.startedAt))
                detailRow("Shift earnings", DriverFormatters.price(shift.totalEarnings))
                detailRow("Shift jobs", "\(shift.completedJobs)")
            } else {
                DriverInfoBanner(icon: "clock.fill", message: "Go online to start a driver shift for today.", style: .info)
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
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
    }

    private func transactionRow(_ title: String, _ amount: String, _ subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SpotlyDriverTypography.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }
            Spacer()
            Text(amount)
                .font(SpotlyDriverTypography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(SpotlyDriverColors.primary)
        }
        .padding(.vertical, 6)
    }

    private var recentJobs: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Recent completed jobs")
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)

            if appState.completedJobs.isEmpty {
                DriverEmptyState(icon: "tray", title: "No earnings yet", message: "Completed deliveries will appear here.")
                    .frame(minHeight: 240)
            } else {
                ForEach(appState.completedJobs.prefix(5)) { job in
                    HStack(spacing: SpotlyDriverSpacing.sm) {
                        Image(systemName: job.categoryIcon)
                            .foregroundStyle(SpotlyDriverColors.primary)
                            .frame(width: 32, height: 32)
                            .background(SpotlyDriverColors.primaryLight)
                            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.sm))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(job.businessName)
                                .font(SpotlyDriverTypography.subheadline)
                                .fontWeight(.semibold)
                            Text("\(job.pickupArea) to \(job.dropoffArea)")
                                .font(SpotlyDriverTypography.caption1)
                                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                        }
                        Spacer()
                        Text(DriverFormatters.price(job.totalEarnings))
                            .font(SpotlyDriverTypography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(SpotlyDriverColors.primary)
                    }
                    .padding(SpotlyDriverSpacing.md)
                    .background(SpotlyDriverColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
                    .driverCardShadow()
                }
            }
        }
    }
}

struct TransactionDetailView: View {
    let transactionID: String
    @EnvironmentObject var appState: DriverAppState

    private var transaction: WalletTransaction? {
        appState.walletTransactions.first { $0.id == transactionID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                if let transaction {
                    VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                        Image(systemName: icon(for: transaction.type))
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(SpotlyDriverColors.primary)
                            .frame(width: 56, height: 56)
                            .background(SpotlyDriverColors.primaryLight)
                            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
                        Text(transaction.type.displayLabel)
                            .font(SpotlyDriverTypography.title2)
                        Text(DriverFormatters.price(transaction.amount))
                            .font(SpotlyDriverTypography.largeTitle)
                            .foregroundStyle(transaction.type == .cashCollected ? SpotlyDriverColors.warning : SpotlyDriverColors.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SpotlyDriverSpacing.md)
                    .background(SpotlyDriverColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
                    .driverCardShadow()

                    detailCard(transaction)

                    if let jobID = transaction.relatedJobID, let job = appState.job(withID: jobID) {
                        DriverJobCard(job: job)
                    }
                } else {
                    DriverEmptyState(icon: "list.bullet.rectangle", title: "Transaction unavailable", message: "This local transaction could not be found after the demo state changed.")
                        .frame(minHeight: 360)
                }
            }
            .padding(SpotlyDriverSpacing.screenEdge)
            .padding(.bottom, SpotlyDriverSpacing.tabBarPadding)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailCard(_ transaction: WalletTransaction) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            detailRow("Status", transaction.status)
            detailRow("Date", DriverFormatters.formattedDate(transaction.createdAt))
            detailRow("Time", DriverFormatters.formattedTime(transaction.createdAt))
            detailRow("Related job", transaction.relatedJobID ?? "None")
            DriverInfoBanner(icon: "info.circle.fill", message: transaction.notes, style: transaction.type == .cashCollected ? .warning : .info)
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
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
    }

    private func icon(for type: WalletTransactionType) -> String {
        switch type {
        case .deliveryCompleted: return "checkmark.circle.fill"
        case .tipReceived: return "heart.fill"
        case .cashCollected: return "banknote.fill"
        case .payoutPending: return "clock.fill"
        case .adjustment: return "slider.horizontal.3"
        }
    }
}
