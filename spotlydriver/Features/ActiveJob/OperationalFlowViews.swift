import SwiftUI

struct ShoppingListView: View {
    let jobID: String
    @EnvironmentObject var appState: DriverAppState
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
                        ForEach(job.items) { item in
                            itemRow(item, job: job)
                        }
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

    var body: some View {
        if let job = appState.job(withID: jobID) {
            OperationalConfirmationView(
                icon: "banknote.fill",
                title: "Collect cash",
                value: DriverFormatters.price(job.cashToCollect),
                message: "Collect the full cash amount before confirming delivery. Do not capture payment in this demo build.",
                buttonTitle: "I collected cash"
            ) {
                appState.markCashCollected()
                dismiss()
            }
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
