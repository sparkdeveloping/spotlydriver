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
    @Published var selectedTab: DriverTab = .home
    @Published var homeNavPath = NavigationPath()
    @Published var jobsNavPath = NavigationPath()
    @Published var earningsNavPath = NavigationPath()
    @Published var profileNavPath = NavigationPath()
    @Published var showJobOffer: Bool = false
    @Published var showCompletionSummary: Bool = false
    @Published var completedJobSummary: DeliveryJob? = nil

    var unreadNotificationCount: Int { notifications.filter { !$0.isRead }.count }
    var currentOfferedJob: DeliveryJob? { offeredJobs.first }

    func job(withID id: String) -> DeliveryJob? {
        if let activeJob, activeJob.id == id { return activeJob }
        return (offeredJobs + completedJobs + cancelledJobs).first { $0.id == id }
    }

    func goOnline() {
        availability = activeJob == nil ? .online : .onJob
        if offeredJobs.isEmpty {
            offeredJobs = DriverMockData.offeredJobs
        }
        DriverHaptics.success()
    }

    func goOffline() {
        guard activeJob == nil else { return }
        availability = .offline
        offeredJobs = []
        showJobOffer = false
        DriverHaptics.medium()
    }

    func pauseRequests() {
        guard activeJob == nil else { return }
        availability = .paused
        DriverHaptics.medium()
    }

    func resumeRequests() {
        guard activeJob == nil else { return }
        availability = .online
        if offeredJobs.isEmpty { offeredJobs = DriverMockData.offeredJobs }
        DriverHaptics.medium()
    }

    func acceptJob(jobID: String) {
        guard let idx = offeredJobs.firstIndex(where: { $0.id == jobID }) else { return }
        var job = offeredJobs.remove(at: idx)
        job.status = .accepted
        job.acceptedAt = Date()
        activeJob = job
        activeJobID = job.id
        availability = .onJob
        DriverHaptics.success()
    }

    func declineJob(jobID: String) {
        offeredJobs.removeAll { $0.id == jobID }
        DriverHaptics.medium()
    }

    func cancelActiveJob(reason: String = "Cancelled by driver") {
        guard var job = activeJob else { return }
        job.status = .cancelled
        job.notes = reason
        cancelledJobs.insert(job, at: 0)
        activeJob = nil
        activeJobID = nil
        availability = .online
        DriverHaptics.warning()
    }

    func setActiveJobStatus(_ status: DeliveryJobStatus) {
        guard var job = activeJob else { return }
        job.status = status
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
        completedJobSummary = job
        activeJob = job
        finalizeDelivery(job: job)
        DriverHaptics.success()
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
        DriverHaptics.warning()
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
        activeJob = nil
        activeJobID = nil
        offeredJobs = []
        completedJobs = DriverMockData.completedJobs
        cancelledJobs = DriverMockData.cancelledJobs
        earningsSummary = DriverMockData.earningsSummary
        notifications = DriverMockData.notifications
        incidents = []
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
