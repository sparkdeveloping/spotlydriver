import SwiftUI

struct EarningsView: View {
    @EnvironmentObject var appState: DriverAppState

    private let chartValues: [Double] = [8.50, 12.25, 6.75, 15.00, 9.50, 3.25, 13.00]
    private let chartLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Today"]

    var body: some View {
        NavigationStack(path: $appState.earningsNavPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                    summaryHeader
                    metricsGrid
                    weeklyChart
                    payoutSection
                    recentJobs
                }
                .padding(SpotlyDriverSpacing.screenEdge)
            }
            .background(SpotlyDriverColors.groupedBackground)
            .navigationTitle("Earnings")
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
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: SpotlyDriverSpacing.sm) {
            DriverMetricCard(title: "Weekly", value: DriverFormatters.price(appState.earningsSummary.weeklyEarnings), icon: "calendar")
            DriverMetricCard(title: "Completed", value: "\(appState.earningsSummary.completedToday)", subtitle: "today", icon: "checkmark.circle")
            DriverMetricCard(title: "Online", value: DriverFormatters.onlineHours(appState.earningsSummary.onlineHours), icon: "clock")
            DriverMetricCard(title: "Acceptance", value: DriverFormatters.acceptanceRate(appState.earningsSummary.acceptanceRate), icon: "percent")
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
                        Text(chartLabels[index])
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
            action: {},
            style: .info
        )
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
