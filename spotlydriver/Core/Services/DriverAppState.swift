import Foundation
import Combine
import SwiftUI

@MainActor
final class DriverAppState: ObservableObject {
    @Published var authState: DriverAuthState = .splash
    @Published var profile: DriverProfile = DriverMockData.profile
    @Published var availability: DriverAvailability = .offline
    @Published var activeJobID: String? = nil
    @Published var activeJob: DeliveryJob? = nil
    @Published var offeredJobs: [DeliveryJob] = []
    @Published var completedJobs: [DeliveryJob] = DriverMockData.completedJobs
    @Published var cancelledJobs: [DeliveryJob] = DriverMockData.cancelledJobs
    @Published var earningsSummary: DriverEarningsSummary = DriverMockData.earningsSummary
    @Published var notifications: [DriverNotification] = DriverMockData.notifications
    @Published var incidents: [DriverIncident] = []
    @Published var dispatchRequests: [DispatchRequest] = []
    @Published var declinedDispatchRequests: [DispatchRequest] = []
    @Published var walletTransactions: [WalletTransaction] = DriverMockData.walletTransactions
    @Published var pastShifts: [DriverShift] = []
    @Published var deliveryZones: [DeliveryZone] = DriverMockData.zones
    @Published var selectedZoneID: String = DriverMockData.zones.first?.id ?? "zone-harare-north"
    @Published var currentShift: DriverShift? = nil
    @Published var payoutPreference: String = "EcoCash"
    @Published var preferredJobTypes: Set<DeliveryJobType> = [.preparedFoodPickup, .groceryShopAndDeliver, .pharmacyVerifiedPickup]
    @Published var maxDeliveryDistanceKM: Double = 8
    @Published var quietHoursEnabled: Bool = false
    @Published var selectedTab: DriverTab = .home
    @Published var homeNavPath = NavigationPath()
    @Published var jobsNavPath = NavigationPath()
    @Published var earningsNavPath = NavigationPath()
    @Published var profileNavPath = NavigationPath()
    @Published var showJobOffer: Bool = false
    @Published var showCompletionSummary: Bool = false
    @Published var completedJobSummary: DeliveryJob? = nil

    private enum StorageKey {
        static let selectedZoneID = "spotlydriver.selectedZoneID"
        static let payoutPreference = "spotlydriver.payoutPreference"
        static let profileFullName = "spotlydriver.profile.fullName"
        static let profilePhone = "spotlydriver.profile.phone"
        static let profileEmail = "spotlydriver.profile.email"
        static let profileCity = "spotlydriver.profile.city"
        static let profileCountry = "spotlydriver.profile.country"
        static let vehicleType = "spotlydriver.vehicle.type"
        static let vehicleMake = "spotlydriver.vehicle.make"
        static let vehicleModel = "spotlydriver.vehicle.model"
        static let vehiclePlate = "spotlydriver.vehicle.plate"
        static let vehicleColor = "spotlydriver.vehicle.color"
        static let maxDistance = "spotlydriver.maxDistance"
        static let quietHours = "spotlydriver.quietHours"

        static let all = [
            selectedZoneID,
            payoutPreference,
            profileFullName,
            profilePhone,
            profileEmail,
            profileCity,
            profileCountry,
            vehicleType,
            vehicleMake,
            vehicleModel,
            vehiclePlate,
            vehicleColor,
            maxDistance,
            quietHours
        ]
    }

    init() {
        loadPersistedSettings()
    }

    var unreadNotificationCount: Int { notifications.filter { !$0.isRead }.count }
    var currentOfferedJob: DeliveryJob? { offeredJobs.first }
    var pendingDispatchRequests: [DispatchRequest] { dispatchRequests.filter { $0.status == .pending } }
    var selectedZone: DeliveryZone? { deliveryZones.first { $0.id == selectedZoneID } }
    var canGoOnline: Bool { profile.verificationStatus == .verified && selectedZone?.isActive == true }
    var goOnlineErrorReason: String? {
        if profile.verificationStatus != .verified { return "Your documents must be verified before going online." }
        if selectedZone?.isActive != true { return "Launch partner zone coming soon. Select an active zone to receive requests." }
        return nil
    }
    var shiftSummaryText: String {
        guard let currentShift else { return "No active shift" }
        return "\(currentShift.zone) · \(DriverFormatters.onlineHours(Double(max(currentShift.onlineDurationMinutes, 1)) / 60.0)) online"
    }

    func job(withID id: String) -> DeliveryJob? {
        if let activeJob, activeJob.id == id { return activeJob }
        return (offeredJobs + completedJobs + cancelledJobs).first { $0.id == id }
    }

    func goOnline() {
        guard canGoOnline else {
            availability = profile.verificationStatus == .verified ? .zoneUnavailable : .verificationRequired
            DriverHaptics.warning()
            return
        }
        startShift()
        availability = activeJob == nil ? .online : .onJob
        if offeredJobs.isEmpty {
            offeredJobs = DriverMockData.offeredJobs
        }
        syncDispatchRequests()
        DriverHaptics.success()
    }

    func goOffline() {
        guard activeJob == nil else { return }
        endShift()
        availability = .offline
        offeredJobs = []
        dispatchRequests = []
        showJobOffer = false
        DriverHaptics.medium()
    }

    func pauseRequests() {
        guard activeJob == nil else { return }
        pauseShift()
        availability = .paused
        DriverHaptics.medium()
    }

    func resumeRequests() {
        guard activeJob == nil else { return }
        guard canGoOnline else {
            availability = profile.verificationStatus == .verified ? .zoneUnavailable : .verificationRequired
            return
        }
        resumeShift()
        availability = .online
        if offeredJobs.isEmpty { offeredJobs = DriverMockData.offeredJobs }
        syncDispatchRequests()
        DriverHaptics.medium()
    }

    func acceptJob(jobID: String) {
        guard let idx = offeredJobs.firstIndex(where: { $0.id == jobID }) else { return }
        var job = offeredJobs.remove(at: idx)
        job.status = .accepted
        job.acceptedAt = Date()
        appendTimeline(to: &job, title: "Accepted", subtitle: "Driver accepted the request.", status: .accepted, icon: "checkmark.circle.fill")
        updateDispatchRequest(jobID: jobID, status: .accepted)
        activeJob = job
        activeJobID = job.id
        availability = .onJob
        DriverHaptics.success()
    }

    func declineJob(jobID: String) {
        if let index = dispatchRequests.firstIndex(where: { $0.jobID == jobID }) {
            var request = dispatchRequests.remove(at: index)
            request.status = .declined
            declinedDispatchRequests.insert(request, at: 0)
        }
        offeredJobs.removeAll { $0.id == jobID }
        DriverHaptics.medium()
    }

    func cancelActiveJob(reason: String = "Cancelled by driver") {
        guard var job = activeJob else { return }
        job.status = .cancelled
        job.notes = reason
        appendTimeline(to: &job, title: "Cancelled", subtitle: reason, status: .cancelled, icon: "xmark.circle.fill")
        cancelledJobs.insert(job, at: 0)
        activeJob = nil
        activeJobID = nil
        availability = .online
        DriverHaptics.warning()
    }

    func setActiveJobStatus(_ status: DeliveryJobStatus) {
        guard var job = activeJob else { return }
        job.status = status
        appendTimeline(to: &job, title: status.displayLabel, subtitle: timelineSubtitle(for: status, job: job), status: status, icon: timelineIcon(for: status))
        activeJob = job
    }

    func advanceActiveJob() {
        guard let job = activeJob else { return }
        switch job.status {
        case .accepted, .enRouteToPickup:
            markArrivedAtPickup()
        case .arrivedAtPickup:
            if job.needsShopping {
                startShopping()
            } else if job.requiresPickupCode {
                confirmPickupCode()
            } else {
                markPickedUp()
            }
        case .shopping:
            break
        case .readyForCheckout:
            submitProofPlaceholder()
        case .pickedUp, .enRouteToDropoff:
            markArrivedAtDropoff()
        case .arrivedAtDropoff:
            if job.paymentHandling.requiresAction {
                markCashCollected()
            } else if job.needsCustomerPIN {
                setActiveJobStatus(.awaitingCustomerPIN)
            } else if job.needsProof {
                submitProofPlaceholder()
            } else {
                markDelivered()
            }
        case .awaitingCustomerPIN:
            break
        default:
            break
        }
        DriverHaptics.medium()
    }

    func markArrivedAtPickup() { setActiveJobStatus(.arrivedAtPickup) }
    func startShopping() { setActiveJobStatus(.shopping) }

    func markItemFound(jobID: String, itemID: String) {
        updateItem(jobID: jobID, itemID: itemID) { item in
            item.isFound = true
            item.isUnavailable = false
            item.substitution = nil
        }
    }

    func markItemUnavailable(jobID: String, itemID: String) {
        updateItem(jobID: jobID, itemID: itemID) { item in
            item.isFound = false
            item.isUnavailable = true
            item.substitution = nil
        }
    }

    func addSubstitution(jobID: String, itemID: String, substitution: String) {
        updateItem(jobID: jobID, itemID: itemID) { item in
            item.isFound = false
            item.isUnavailable = false
            item.substitution = substitution
        }
    }

    func finishShopping() {
        guard let job = activeJob, job.items.allSatisfy(\.isHandled) else { return }
        setActiveJobStatus(.readyForCheckout)
    }

    func confirmPickupCode() { markPickedUp() }
    func confirmOrderNumber() { markPickedUp() }

    func markPickedUp() {
        guard var job = activeJob else { return }
        job.status = .pickedUp
        activeJob = job
    }

    func markArrivedAtDropoff() { setActiveJobStatus(.arrivedAtDropoff) }

    func verifyCustomerPIN(_ pin: String) -> Bool {
        guard let job = activeJob else { return false }
        guard let expected = job.customerPIN, !expected.isEmpty else {
            markDelivered()
            return true
        }
        if pin == expected {
            if job.needsProof {
                setActiveJobStatus(.arrivedAtDropoff)
            } else {
                markDelivered()
            }
            DriverHaptics.success()
            return true
        }
        DriverHaptics.warning()
        return false
    }

    func markCashCollected() {
        guard let job = activeJob else { return }
        appendActiveTimeline(title: "Cash collected", subtitle: DriverFormatters.price(job.cashToCollect), status: .arrivedAtDropoff, icon: "banknote.fill")
        if job.needsCustomerPIN {
            setActiveJobStatus(.awaitingCustomerPIN)
        } else if job.needsProof {
            submitProofPlaceholder()
        } else {
            markDelivered()
        }
    }

    func submitProofPlaceholder() {
        guard var job = activeJob else { return }
        job.proofStatus = .placeholderSubmitted
        if job.status == .readyForCheckout {
            job.status = .pickedUp
        } else {
            activeJob = job
            markDelivered()
            return
        }
        activeJob = job
    }

    func markDelivered() {
        guard var job = activeJob else { return }
        job.status = .delivered
        job.completedAt = Date()
        appendTimeline(to: &job, title: "Delivered", subtitle: "Delivery completed successfully.", status: .delivered, icon: "checkmark.seal.fill")
        completedJobSummary = job
        activeJob = job
        finalizeDelivery(job: job)
        DriverHaptics.success()
    }

    func completeActiveJob() {
        markDelivered()
    }

    private func updateItem(jobID: String, itemID: String, mutate: (inout DeliveryItem) -> Void) {
        guard activeJob?.id == jobID, var job = activeJob, let index = job.items.firstIndex(where: { $0.id == itemID }) else { return }
        mutate(&job.items[index])
        activeJob = job
    }

    private func finalizeDelivery(job: DeliveryJob) {
        if !completedJobs.contains(where: { $0.id == job.id }) {
            completedJobs.insert(job, at: 0)
            earningsSummary.todayEarnings += job.totalEarnings
            earningsSummary.weeklyEarnings += job.totalEarnings
            earningsSummary.completedToday += 1
            earningsSummary.pendingPayout += job.totalEarnings
            profile.completedJobs += 1
            walletTransactions.insert(WalletTransaction(id: "txn-\(job.id)-fare", type: .deliveryCompleted, amount: job.earnings, relatedJobID: job.id, createdAt: Date(), status: "Pending payout", notes: "Base fare for \(job.businessName)."), at: 0)
            if job.tip > 0 {
                walletTransactions.insert(WalletTransaction(id: "txn-\(job.id)-tip", type: .tipReceived, amount: job.tip, relatedJobID: job.id, createdAt: Date(), status: "Pending payout", notes: "Customer tip."), at: 0)
            }
            if job.cashToCollect > 0 {
                walletTransactions.insert(WalletTransaction(id: "txn-\(job.id)-cash", type: .cashCollected, amount: job.cashToCollect, relatedJobID: job.id, createdAt: Date(), status: "Recorded", notes: "Operational cash collection, not driver earnings."), at: 0)
            }
            updateCurrentShift(after: job)
        }
        showCompletionSummary = true
    }

    func dismissCompletionSummary() {
        activeJob = nil
        activeJobID = nil
        completedJobSummary = nil
        showCompletionSummary = false
        availability = .online
    }

    func reportIssue(jobID: String, type: DriverIncidentType, notes: String) {
        let incident = DriverIncident(
            id: "incident-\(incidents.count + 1)",
            jobID: jobID,
            type: type,
            notes: notes,
            createdAt: Date(),
            status: .open
        )
        incidents.insert(incident, at: 0)
        appendActiveTimeline(title: "Issue reported", subtitle: type.displayLabel, status: activeJob?.status ?? .accepted, icon: "exclamationmark.triangle.fill")
        DriverHaptics.warning()
    }

    func markIncidentResolved(_ incidentID: String) {
        if let index = incidents.firstIndex(where: { $0.id == incidentID }) {
            incidents[index].status = .resolved
        }
    }

    func selectZone(_ zoneID: String) {
        guard let zone = deliveryZones.first(where: { $0.id == zoneID }), zone.isActive else { return }
        selectedZoneID = zoneID
        UserDefaults.standard.set(zoneID, forKey: StorageKey.selectedZoneID)
        if selectedZone?.isActive == false, activeJob == nil {
            availability = .zoneUnavailable
            offeredJobs = []
        } else if availability == .zoneUnavailable {
            availability = .offline
        }
    }

    func updateProfile(fullName: String, phone: String, email: String, country: SpotlyCountryCode, city: String) throws {
        profile.fullName = fullName
        profile.phone = try DriverCountryEngine.normalizePhone(phone, country: country)
        profile.email = email
        profile.countryCode = country
        profile.city = city
        profile.avatarInitials = fullName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
        UserDefaults.standard.set(fullName, forKey: StorageKey.profileFullName)
        UserDefaults.standard.set(profile.phone, forKey: StorageKey.profilePhone)
        UserDefaults.standard.set(email, forKey: StorageKey.profileEmail)
        UserDefaults.standard.set(city, forKey: StorageKey.profileCity)
        UserDefaults.standard.set(country.rawValue, forKey: StorageKey.profileCountry)
    }

    func updateVehicle(type: DriverVehicleType, make: String, model: String, plateNumber: String, color: String) {
        profile.vehicle = DriverVehicle(type: type, make: make, model: model, plateNumber: plateNumber, color: color)
        UserDefaults.standard.set(type.rawValue, forKey: StorageKey.vehicleType)
        UserDefaults.standard.set(make, forKey: StorageKey.vehicleMake)
        UserDefaults.standard.set(model, forKey: StorageKey.vehicleModel)
        UserDefaults.standard.set(plateNumber, forKey: StorageKey.vehiclePlate)
        UserDefaults.standard.set(color, forKey: StorageKey.vehicleColor)
    }

    func updatePayoutPreference(_ method: String) {
        payoutPreference = method
        UserDefaults.standard.set(method, forKey: StorageKey.payoutPreference)
    }

    func updateAvailabilityPreferences(maxDistance: Double, quietHours: Bool) {
        maxDeliveryDistanceKM = maxDistance
        quietHoursEnabled = quietHours
        UserDefaults.standard.set(maxDistance, forKey: StorageKey.maxDistance)
        UserDefaults.standard.set(quietHours, forKey: StorageKey.quietHours)
    }

    func seedAvailableJobs() {
        offeredJobs = DriverMockData.offeredJobs
        syncDispatchRequests()
        if canGoOnline {
            startShift()
            availability = activeJob == nil ? .online : .onJob
        }
    }

    func seedJobs(ofType type: DeliveryJobType) {
        let matching = DriverMockData.offeredJobs.filter { $0.jobType == type }
        offeredJobs = matching.isEmpty ? DriverMockData.offeredJobs : matching
        syncDispatchRequests()
        if canGoOnline {
            startShift()
            availability = activeJob == nil ? .online : .onJob
        }
    }

    func clearActiveJob() {
        activeJob = nil
        activeJobID = nil
        availability = currentShift?.status == .active ? .online : .offline
    }

    func setVerificationStatus(_ status: DriverVerificationStatus) {
        profile.verificationStatus = status
    }

    func simulateCustomerUnavailable() {
        let jobID = activeJob?.id ?? "general"
        reportIssue(jobID: jobID, type: .customerUnavailable, notes: "Customer unavailable during local demo flow.")
        if activeJob != nil {
            setActiveJobStatus(.failed)
        }
    }

    func simulateMerchantNotReady() {
        reportIssue(jobID: activeJob?.id ?? "general", type: .storeNotReady, notes: "Merchant not ready during local demo flow.")
    }

    func recordTimelineEvent(title: String, subtitle: String, icon: String = "text.bubble.fill") {
        appendActiveTimeline(title: title, subtitle: subtitle, status: activeJob?.status ?? .accepted, icon: icon)
    }

    func startShift() {
        if currentShift == nil || currentShift?.status == .ended {
            let zone = selectedZone
            currentShift = DriverShift(
                id: "shift-\(Int(Date().timeIntervalSince1970))",
                startedAt: Date(),
                endedAt: nil,
                city: zone?.city ?? profile.city,
                zone: zone?.name ?? (profile.city.isEmpty ? "Selected city" : profile.city),
                onlineDurationMinutes: Int(earningsSummary.onlineHours * 60),
                completedJobs: 0,
                totalEarnings: 0,
                status: .active
            )
        } else {
            currentShift?.status = .active
        }
    }

    func endShift() {
        guard currentShift != nil else { return }
        currentShift?.endedAt = Date()
        currentShift?.status = .ended
        if let shift = currentShift, !pastShifts.contains(where: { $0.id == shift.id }) {
            pastShifts.insert(shift, at: 0)
        }
    }

    func pauseShift() {
        currentShift?.status = .paused
    }

    func resumeShift() {
        currentShift?.status = .active
    }

    func markNotificationRead(_ id: String) {
        if let idx = notifications.firstIndex(where: { $0.id == id }) {
            notifications[idx].isRead = true
        }
    }

    func markAllNotificationsRead() {
        for idx in notifications.indices { notifications[idx].isRead = true }
    }

    func completeVerificationDemo() {
        profile.verificationStatus = .pending
        authState = .main
        DriverHaptics.success()
    }

    func skipToMain() { authState = .main }

    func resetDemoData() {
        StorageKey.all.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        activeJob = nil
        activeJobID = nil
        offeredJobs = []
        dispatchRequests = []
        declinedDispatchRequests = []
        completedJobs = DriverMockData.completedJobs
        cancelledJobs = DriverMockData.cancelledJobs
        earningsSummary = DriverMockData.earningsSummary
        notifications = DriverMockData.notifications
        incidents = []
        walletTransactions = DriverMockData.walletTransactions
        pastShifts = []
        deliveryZones = DriverMockData.zones
        selectedZoneID = DriverMockData.zones.first?.id ?? "zone-harare-north"
        currentShift = nil
        payoutPreference = "EcoCash"
        preferredJobTypes = [.preparedFoodPickup, .groceryShopAndDeliver, .pharmacyVerifiedPickup]
        maxDeliveryDistanceKM = 8
        quietHoursEnabled = false
        availability = .offline
        profile = DriverMockData.profile
        showJobOffer = false
        showCompletionSummary = false
        completedJobSummary = nil
        selectedTab = .home
        homeNavPath = NavigationPath()
        jobsNavPath = NavigationPath()
        earningsNavPath = NavigationPath()
        profileNavPath = NavigationPath()
        DriverHaptics.success()
    }

    func signOut() {
        resetDemoData()
        authState = .welcome
    }

    private func loadPersistedSettings() {
        let defaults = UserDefaults.standard
        if let zoneID = defaults.string(forKey: StorageKey.selectedZoneID),
           deliveryZones.contains(where: { $0.id == zoneID }) {
            selectedZoneID = zoneID
        }
        if let payout = defaults.string(forKey: StorageKey.payoutPreference) {
            payoutPreference = payout
        }
        if let fullName = defaults.string(forKey: StorageKey.profileFullName) {
            profile.fullName = fullName
        }
        if let phone = defaults.string(forKey: StorageKey.profilePhone) {
            profile.phone = phone
        }
        if let email = defaults.string(forKey: StorageKey.profileEmail) {
            profile.email = email
        }
        if let city = defaults.string(forKey: StorageKey.profileCity) { profile.city = city }
        if let raw = defaults.string(forKey: StorageKey.profileCountry), let country = SpotlyCountryCode(rawValue: raw) { profile.countryCode = country }
        if let typeRaw = defaults.string(forKey: StorageKey.vehicleType),
           let type = DriverVehicleType(rawValue: typeRaw) {
            profile.vehicle.type = type
        }
        if let make = defaults.string(forKey: StorageKey.vehicleMake) {
            profile.vehicle.make = make
        }
        if let model = defaults.string(forKey: StorageKey.vehicleModel) {
            profile.vehicle.model = model
        }
        if let plate = defaults.string(forKey: StorageKey.vehiclePlate) {
            profile.vehicle.plateNumber = plate
        }
        if let color = defaults.string(forKey: StorageKey.vehicleColor) {
            profile.vehicle.color = color
        }
        let savedDistance = defaults.double(forKey: StorageKey.maxDistance)
        if savedDistance > 0 {
            maxDeliveryDistanceKM = savedDistance
        }
        quietHoursEnabled = defaults.bool(forKey: StorageKey.quietHours)
    }

    private func updateCurrentShift(after job: DeliveryJob) {
        guard currentShift != nil else { return }
        currentShift?.completedJobs += 1
        currentShift?.totalEarnings += job.totalEarnings
        currentShift?.onlineDurationMinutes = max(currentShift?.onlineDurationMinutes ?? 0, Int(earningsSummary.onlineHours * 60))
    }

    private func syncDispatchRequests() {
        let existingByJob = Dictionary(uniqueKeysWithValues: dispatchRequests.map { ($0.jobID, $0) })
        dispatchRequests = offeredJobs.map { job in
            existingByJob[job.id] ?? DispatchRequest(
                id: "dispatch-\(job.id)",
                jobID: job.id,
                receivedAt: job.createdAt,
                expiresAt: Calendar.current.date(byAdding: .minute, value: 10, to: Date()),
                priority: job.totalEarnings >= 5.5 || job.jobType == .pharmacyVerifiedPickup ? .high : .normal,
                recommendationReason: job.recommendationReason,
                status: .pending
            )
        }
    }

    private func updateDispatchRequest(jobID: String, status: DispatchRequestStatus) {
        if let index = dispatchRequests.firstIndex(where: { $0.jobID == jobID }) {
            dispatchRequests[index].status = status
        }
    }

    private func appendActiveTimeline(title: String, subtitle: String, status: DeliveryJobStatus, icon: String) {
        guard var job = activeJob else { return }
        appendTimeline(to: &job, title: title, subtitle: subtitle, status: status, icon: icon)
        activeJob = job
    }

    private func appendTimeline(to job: inout DeliveryJob, title: String, subtitle: String, status: DeliveryJobStatus, icon: String) {
        var timeline = job.timeline ?? [
            JobTimelineEvent(id: "\(job.id)-offered", jobID: job.id, title: "Job offered", subtitle: job.businessName, timestamp: job.createdAt, status: .offered, iconName: "shippingbox.fill")
        ]
        timeline.append(
            JobTimelineEvent(
                id: "\(job.id)-event-\(timeline.count + 1)-\(Int(Date().timeIntervalSince1970))",
                jobID: job.id,
                title: title,
                subtitle: subtitle,
                timestamp: Date(),
                status: status,
                iconName: icon
            )
        )
        job.timeline = timeline
    }

    private func timelineSubtitle(for status: DeliveryJobStatus, job: DeliveryJob) -> String {
        switch status {
        case .arrivedAtPickup: return job.pickupArea
        case .shopping: return "Shopping started"
        case .readyForCheckout: return "Shopping finished"
        case .pickedUp: return "Pickup confirmed"
        case .arrivedAtDropoff: return job.dropoffArea
        case .awaitingCustomerPIN: return "Customer PIN required"
        case .cancelled: return "Delivery cancelled"
        case .failed: return "Delivery failed"
        default: return job.businessName
        }
    }

    private func timelineIcon(for status: DeliveryJobStatus) -> String {
        switch status {
        case .arrivedAtPickup: return "mappin.circle.fill"
        case .shopping: return "cart.fill"
        case .readyForCheckout: return "receipt.fill"
        case .pickedUp: return "shippingbox.fill"
        case .arrivedAtDropoff: return "house.fill"
        case .awaitingCustomerPIN: return "number.circle.fill"
        case .delivered: return "checkmark.seal.fill"
        case .cancelled, .failed: return "xmark.circle.fill"
        default: return "circle.fill"
        }
    }
}

// MARK: - Tab Enum
enum DriverTab: String, CaseIterable {
    case home = "home"
    case jobs = "jobs"
    case earnings = "earnings"
    case profile = "profile"

    var label: String {
        switch self {
        case .home: return "Home"
        case .jobs: return "Jobs"
        case .earnings: return "Earnings"
        case .profile: return "Profile"
        }
    }

    var systemIcon: String {
        switch self {
        case .home: return "house.fill"
        case .jobs: return "shippingbox.fill"
        case .earnings: return "dollarsign.circle.fill"
        case .profile: return "person.fill"
        }
    }
}
