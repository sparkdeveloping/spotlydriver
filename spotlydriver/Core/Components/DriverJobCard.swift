import SwiftUI

struct DriverJobCard: View {
    let job: DeliveryJob
    var onAccept: (() -> Void)? = nil
    var onDecline: (() -> Void)? = nil
    var onContinue: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.md) {
            header
            badgeRow
            routeBlock
            itemsBlock
            if let notes = job.notes, !notes.isEmpty {
                Label(notes, systemImage: "info.circle.fill")
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
            actionRow
        }
        .padding(SpotlyDriverSpacing.cardPadding)
        .background(SpotlyDriverColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: SpotlyDriverRadius.card)
                .stroke(SpotlyDriverColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: SpotlyDriverSpacing.sm) {
            Image(systemName: job.categoryIcon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(SpotlyDriverColors.primary)
                .frame(width: 44, height: 44)
                .background(SpotlyDriverColors.primaryLight)
                .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.small))

            VStack(alignment: .leading, spacing: 3) {
                Text(job.businessName)
                    .font(SpotlyDriverTypography.headline)
                    .foregroundStyle(SpotlyDriverColors.label)
                Text(job.businessCategory)
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }

            Spacer(minLength: SpotlyDriverSpacing.sm)

            VStack(alignment: .trailing, spacing: 2) {
                Text(DriverFormatters.price(job.totalEarnings))
                    .font(SpotlyDriverTypography.title3)
                    .foregroundStyle(SpotlyDriverColors.primary)
                if job.tip > 0 {
                    Text("+\(DriverFormatters.priceShort(job.tip)) tip")
                        .font(SpotlyDriverTypography.caption2)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                }
            }
        }
    }

    private var badgeRow: some View {
        HStack(spacing: 6) {
            chip(job.operationalBadge, color: SpotlyDriverColors.primary)
            chip(job.paymentHandling.displayLabel, color: job.paymentHandling.requiresAction ? SpotlyDriverColors.warning : SpotlyDriverColors.info)
            chip(scoreBadge, color: scoreBadge == "Higher pay" ? SpotlyDriverColors.warning : SpotlyDriverColors.primary)
            Spacer(minLength: 0)
        }
    }

    private var scoreBadge: String {
        job.recommendationReason == "High earnings" ? "Higher pay" : job.recommendationReason
    }

    private var routeBlock: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.xs) {
            routeRow(icon: "mappin.circle.fill", color: SpotlyDriverColors.primary, label: "Pickup", value: job.pickupArea)
            routeRow(icon: "mappin.circle.fill", color: SpotlyDriverColors.destructive, label: "Drop-off", value: job.dropoffArea)
            HStack(spacing: SpotlyDriverSpacing.md) {
                statChip(icon: "location", value: DriverFormatters.distance(job.distanceKM))
                statChip(icon: "clock", value: DriverFormatters.duration(job.estimatedDurationMinutes))
                statChip(icon: "shippingbox", value: job.fulfillmentMode.displayLabel)
            }
            .padding(.top, 2)
        }
    }

    private var itemsBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(job.itemsSummary)
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.label)
                .lineLimit(2)
            Text("\(job.itemCount) item\(job.itemCount == 1 ? "" : "s") · \(job.pickupTimeWindow)")
                .font(SpotlyDriverTypography.caption1)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
        }
    }

    @ViewBuilder
    private var actionRow: some View {
        if job.status == .offered, onAccept != nil {
            HStack(spacing: SpotlyDriverSpacing.sm) {
                DriverButton(title: "Decline", style: .secondary, height: 48) { onDecline?() }
                DriverButton(title: "Accept", style: .primary, height: 48) { onAccept?() }
            }
        } else if job.status.isActive, onContinue != nil {
            DriverButton(title: "Continue Delivery", style: .primary, icon: "arrow.right.circle.fill", height: 48) { onContinue?() }
        } else if job.status == .delivered {
            HStack {
                chip("Delivered", color: SpotlyDriverColors.primary)
                Spacer()
                Text(DriverFormatters.formattedDate(job.completedAt ?? job.createdAt))
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
            }
        } else if job.status == .cancelled || job.status == .failed {
            chip(job.status.displayLabel, color: SpotlyDriverColors.destructive)
        }
    }

    private func routeRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: SpotlyDriverSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 20)
            Text(label)
                .font(SpotlyDriverTypography.caption2)
                .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
                .textCase(.uppercase)
            Text(value)
                .font(SpotlyDriverTypography.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(SpotlyDriverColors.label)
            Spacer()
        }
    }

    private func statChip(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
            Text(value)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .font(SpotlyDriverTypography.caption1)
        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
    }

    private func chip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(SpotlyDriverTypography.caption1)
            .fontWeight(.semibold)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }
}

typealias DriverJobOfferCard = DriverJobCard
typealias DriverJobListCard = DriverJobCard

struct DriverSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(SpotlyDriverColors.primary)
            }
        }
    }
}

struct DriverPageHeader: View {
    let city: String
    let name: String
    let initials: String
    let availability: DriverAvailability
    let unreadCount: Int
    let notificationsAction: () -> Void

    var body: some View {
        SpotlyPageHeader(
            title: "Hello, \(name)",
            subtitle: "Ready for Spotly delivery operations.",
            location: city,
            avatarInitials: initials,
            variant: .greeting
        ) {
            SpotlyIconButton(icon: "bell.fill", badge: unreadCount, action: notificationsAction)
        }
        .overlay(alignment: .bottomLeading) {
            DriverStatusPill(availability: availability)
                .offset(y: 28)
        }
        .padding(.bottom, 28)
    }
}
