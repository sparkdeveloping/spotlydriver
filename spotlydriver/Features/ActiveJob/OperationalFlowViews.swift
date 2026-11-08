import SwiftUI

struct ShoppingListView: View {
    let jobID: String
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) private var dismiss
    @State private var substitutionItemID: String?
    @State private var substitutionText = ""

    private var job: DeliveryJob? { appState.activeJob?.id == jobID ? appState.activeJob : appState.job(withID: jobID) }

    var body: some View {
        Group {
            if let job {
                ScrollView {
                    VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                        DriverSectionHeader(title: job.businessName)
                        progressCard(job)
                        DriverInfoBanner(icon: "text.bubble.fill", message: "Customer note: choose close substitutions where possible and keep cold items separate.", style: .info)
                        DriverInfoBanner(icon: "arrow.triangle.2.circlepath", message: job.substitutionsAllowed ? "Substitutions are allowed for this order." : "No substitutions for this order.", style: .info)
                        ForEach(shoppingSections(for: job), id: \.0) { section, items in
                            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                                Text(section)
                                    .font(SpotlyDriverTypography.headline)
                                    .foregroundStyle(SpotlyDriverColors.label)
                                ForEach(items) { item in
                                    itemRow(item, job: job)
                                }
                            }
                        }
                        shoppingSummary(job)
                        DriverInfoBanner(icon: "receipt.fill", message: "Receipt upload will be enabled before launch.", style: .info)
                    }
                    .padding(SpotlyDriverSpacing.screenEdge)
                    .padding(.bottom, SpotlyDriverSpacing.bottomSafePadding)
                }
                .background(SpotlyDriverColors.groupedBackground)
                .safeAreaInset(edge: .bottom) {
                    DriverBottomActionBar {
                        DriverButton(title: "Finish Shopping", style: .primary, icon: "checkmark.circle.fill", isDisabled: !job.items.allSatisfy(\.isHandled)) {
                            appState.finishShopping()
                            dismiss()
                        }
                    }
                }
            } else {
                JobUnavailableView()
            }
        }
        .navigationTitle("Shopping List")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Substitute item", isPresented: Binding(get: { substitutionItemID != nil }, set: { if !$0 { substitutionItemID = nil } })) {
            TextField("Substitution", text: $substitutionText)
            Button("Save") {
                if let itemID = substitutionItemID, !substitutionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    appState.addSubstitution(jobID: jobID, itemID: itemID, substitution: substitutionText)
                }
                substitutionItemID = nil
                substitutionText = ""
            }
            Button("Cancel", role: .cancel) {
                substitutionItemID = nil
                substitutionText = ""
            }
        }
    }

    private func progressCard(_ job: DeliveryJob) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("\(job.handledItemCount) of \(job.itemCount) items handled")
                .font(SpotlyDriverTypography.headline)
            ProgressView(value: Double(job.handledItemCount), total: Double(max(job.itemCount, 1)))
                .tint(SpotlyDriverColors.primary)
            Text(job.substitutionsAllowed ? "Substitutions allowed" : "No substitutions")
                .font(SpotlyDriverTypography.caption1)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private func shoppingSections(for job: DeliveryJob) -> [(String, [DeliveryItem])] {
        let sections = Dictionary(grouping: job.items) { item -> String in
            let name = item.name.lowercased()
            if name.contains("tomato") || name.contains("apple") || name.contains("banana") || name.contains("lettuce") || name.contains("avocado") { return "Produce" }
            if name.contains("milk") || name.contains("egg") || name.contains("chicken") { return "Cold items" }
            if name.contains("bread") { return "Pantry" }
            return "Other"
        }
        let order = ["Produce", "Pantry", "Cold items", "Other"]
        return order.compactMap { key in
            guard let items = sections[key], !items.isEmpty else { return nil }
            return (key, items)
        }
    }

    private func shoppingSummary(_ job: DeliveryJob) -> some View {
        let substituted = job.items.filter { $0.substitution != nil }.count
        let unavailable = job.items.filter(\.isUnavailable).count
        let found = job.items.filter(\.isFound).count
        return VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text("Shopping summary")
                .font(SpotlyDriverTypography.headline)
            HStack {
                summaryPill("\(found) found", color: SpotlyDriverColors.primary)
                summaryPill("\(substituted) substituted", color: SpotlyDriverColors.warning)
                summaryPill("\(unavailable) unavailable", color: SpotlyDriverColors.destructive)
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }

    private func summaryPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(SpotlyDriverTypography.caption1)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }

    private func itemRow(_ item: DeliveryItem, job: DeliveryJob) -> some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(item.quantity) \(item.name)")
                        .font(SpotlyDriverTypography.headline)
                    if let notes = item.notes {
                        Text(notes)
                            .font(SpotlyDriverTypography.caption1)
                            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    }
                    if let substitution = item.substitution {
                        Text("Substitute: \(substitution)")
                            .font(SpotlyDriverTypography.caption1)
                            .foregroundStyle(SpotlyDriverColors.warning)
                    } else if item.isFound {
                        Text("Found")
                            .font(SpotlyDriverTypography.caption1)
                            .foregroundStyle(SpotlyDriverColors.primary)
                    } else if item.isUnavailable {
                        Text("Unavailable")
                            .font(SpotlyDriverTypography.caption1)
                            .foregroundStyle(SpotlyDriverColors.destructive)
                    }
                }
                Spacer()
            }
            HStack(spacing: SpotlyDriverSpacing.sm) {
                DriverButton(title: "Found", style: item.isFound ? .primary : .secondary, height: 42) {
                    appState.markItemFound(jobID: job.id, itemID: item.id)
                }
                DriverButton(title: "Unavailable", style: item.isUnavailable ? .destructive : .secondary, height: 42) {
                    appState.markItemUnavailable(jobID: job.id, itemID: item.id)
                }
                if job.substitutionsAllowed {
                    DriverButton(title: "Sub", style: item.substitution == nil ? .outline : .primary, height: 42) {
                        substitutionItemID = item.id
                    }
                    .frame(width: 82)
                }
            }
        }
        .padding(SpotlyDriverSpacing.md)
        .background(SpotlyDriverColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        .driverCardShadow()
    }
}

struct PickupCodeView: View {
    let jobID: String
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if let job = appState.job(withID: jobID) {
            OperationalConfirmationView(
                icon: "number.square.fill",
                title: job.pickupRequirement == .confirmOrderNumber ? "Confirm order number" : "Pickup code",
                value: job.pickupCode ?? job.orderNumber ?? job.orderID,
                message: job.pickupRequirement == .confirmOrderNumber ? "Confirm this order number with the merchant before leaving." : "Show this code to the merchant.",
                buttonTitle: "Confirm pickup"
            ) {
                appState.confirmPickupCode()
                dismiss()
            }
        } else {
            JobUnavailableView()
        }
    }
}

struct CustomerPINView: View {
    let jobID: String
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) private var dismiss
    @State private var pin = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: SpotlyDriverSpacing.xl) {
            Spacer()
            Image(systemName: "number.circle.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(SpotlyDriverColors.primary)
            Text("Enter customer PIN")
                .font(SpotlyDriverTypography.title2)
            Text("Ask the customer for their Spotly delivery PIN before marking this job delivered.")
                .font(SpotlyDriverTypography.subheadline)
                .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                .multilineTextAlignment(.center)
            TextField("PIN", text: $pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .font(SpotlyDriverTypography.title1)
                .multilineTextAlignment(.center)
                .padding()
                .background(SpotlyDriverColors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
            if showError {
                Text("PIN does not match this demo order.")
                    .font(SpotlyDriverTypography.caption1)
                    .foregroundStyle(SpotlyDriverColors.destructive)
            }
            Spacer()
        }
        .padding(SpotlyDriverSpacing.screenEdge)
        .safeAreaInset(edge: .bottom) {
            DriverBottomActionBar {
                DriverButton(title: "Confirm PIN", style: .primary, icon: "checkmark.seal.fill", isDisabled: pin.isEmpty) {
                    if appState.verifyCustomerPIN(pin) {
                        dismiss()
                    } else {
                        showError = true
                    }
                }
            }
        }
        .navigationTitle("Customer PIN")
        .navigationBarTitleDisplayMode(.inline)
        .background(SpotlyDriverColors.groupedBackground)
    }
}

struct CashCollectionView: View {
    let jobID: String
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmCollection = false

    var body: some View {
        if let job = appState.job(withID: jobID) {
            VStack(spacing: SpotlyDriverSpacing.xl) {
                Spacer()
                Image(systemName: "banknote.fill")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(SpotlyDriverColors.primary)
                VStack(spacing: SpotlyDriverSpacing.sm) {
                    Text("Collect cash")
                        .font(SpotlyDriverTypography.title2)
                    Text(DriverFormatters.price(job.cashToCollect))
                        .font(SpotlyDriverTypography.largeTitle)
                        .foregroundStyle(SpotlyDriverColors.primary)
                    Text("Collect the full amount before confirming delivery. Cash collected is tracked separately from driver earnings.")
                        .font(SpotlyDriverTypography.subheadline)
                        .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                        .multilineTextAlignment(.center)
                }
                VStack(spacing: SpotlyDriverSpacing.sm) {
                    DriverButton(title: "Customer cannot pay", style: .outline, icon: "exclamationmark.triangle") {
                        appState.reportIssue(jobID: jobID, type: .paymentIssue, notes: "Customer cannot pay cash amount.")
                    }
                    DriverButton(title: "Wrong amount", style: .outline, icon: "banknote") {
                        appState.reportIssue(jobID: jobID, type: .paymentIssue, notes: "Customer offered wrong cash amount.")
                    }
                    DriverButton(title: "Safety concern", style: .destructive, icon: "shield.lefthalf.filled") {
                        appState.reportIssue(jobID: jobID, type: .safetyConcern, notes: "Safety concern during cash collection.")
                    }
                }
                Spacer()
            }
            .padding(SpotlyDriverSpacing.screenEdge)
            .background(SpotlyDriverColors.groupedBackground)
            .safeAreaInset(edge: .bottom) {
                DriverBottomActionBar {
                    DriverButton(title: "I collected cash", style: .primary, icon: "checkmark.circle.fill") {
                        showConfirmCollection = true
                    }
                }
            }
            .alert("Confirm cash collected?", isPresented: $showConfirmCollection) {
                Button("Confirm") {
                    appState.markCashCollected()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Confirm you collected \(DriverFormatters.price(job.cashToCollect)) before continuing.")
            }
            .navigationTitle("Collect cash")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            JobUnavailableView()
        }
    }
}

struct ProofOfDeliveryPlaceholderView: View {
    let jobID: String
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        OperationalConfirmationView(
            icon: "camera.fill",
            title: "Proof of delivery",
            value: "Photo proof",
            message: "Photo proof will be enabled before launch. For this demo, submit the placeholder to continue.",
            buttonTitle: "Submit proof placeholder"
        ) {
            appState.submitProofPlaceholder()
            dismiss()
        }
    }
}

struct CustomerUnavailableView: View {
    let jobID: String
    @EnvironmentObject var appState: DriverAppState
    @Environment(\.dismiss) private var dismiss
    @State private var resolution: String?

    private var job: DeliveryJob? { appState.job(withID: jobID) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpotlyDriverSpacing.lg) {
                if let job {
                    VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(SpotlyDriverColors.warning)
                            .frame(width: 58, height: 58)
                            .background(SpotlyDriverColors.warning.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
                        Text("Customer unavailable")
                            .font(SpotlyDriverTypography.title2)
                        Text("Use this local exception flow when the customer cannot be reached at drop-off.")
                            .font(SpotlyDriverTypography.subheadline)
                            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SpotlyDriverSpacing.md)
                    .background(SpotlyDriverColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
                    .driverCardShadow()

                    DriverJobCard(job: job)
                    DriverInfoBanner(icon: "phone.fill", message: "Try customer contact first. Customer contact will be proxied for privacy.", style: .info)
                    resolutionButton("Leave at door with proof", icon: "camera.fill", notes: "Customer unavailable: leave-at-door proof selected.")
                    resolutionButton("Return to merchant", icon: "arrow.uturn.left.circle.fill", notes: "Customer unavailable: return to merchant selected.")
                    resolutionButton("Contact operations", icon: "headphones", notes: "Customer unavailable: operations contact requested.")
                    resolutionButton("Mark failed", icon: "xmark.octagon.fill", notes: "Customer unavailable: delivery marked failed.", destructive: true)

                    if let resolution {
                        DriverInfoBanner(icon: "checkmark.circle.fill", message: resolution, style: .info)
                    }
                } else {
                    JobUnavailableView()
                }
            }
            .padding(SpotlyDriverSpacing.screenEdge)
            .padding(.bottom, SpotlyDriverSpacing.bottomSafePadding)
        }
        .background(SpotlyDriverColors.groupedBackground)
        .navigationTitle("Customer unavailable")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func resolutionButton(_ title: String, icon: String, notes: String, destructive: Bool = false) -> some View {
        DriverButton(title: title, style: destructive ? .destructive : .secondary, icon: icon) {
            appState.reportIssue(jobID: jobID, type: .customerUnavailable, notes: notes)
            appState.recordTimelineEvent(title: "Customer unavailable", subtitle: title, icon: icon)
            resolution = "Saved incident and timeline event: \(title)."
            if destructive {
                appState.cancelActiveJob(reason: title)
                dismiss()
            }
        }
    }
}

struct OperationalConfirmationView: View {
    let icon: String
    let title: String
    let value: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: SpotlyDriverSpacing.xl) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(SpotlyDriverColors.primary)
            VStack(spacing: SpotlyDriverSpacing.sm) {
                Text(title)
                    .font(SpotlyDriverTypography.title2)
                Text(value)
                    .font(SpotlyDriverTypography.largeTitle)
                    .foregroundStyle(SpotlyDriverColors.primary)
                Text(message)
                    .font(SpotlyDriverTypography.subheadline)
                    .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(SpotlyDriverSpacing.screenEdge)
        .background(SpotlyDriverColors.groupedBackground)
        .safeAreaInset(edge: .bottom) {
            DriverBottomActionBar {
                DriverButton(title: buttonTitle, style: .primary, icon: "checkmark.circle.fill") {
                    action()
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
