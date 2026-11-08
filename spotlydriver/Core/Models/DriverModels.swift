import Foundation
import CoreLocation

// MARK: - Verification Status
enum DriverVerificationStatus: String, Codable, CaseIterable, Hashable {
    case notStarted = "not_started"
    case pending
    case verified
    case rejected

    var displayLabel: String {
        switch self {
        case .notStarted: return "Not Started"
        case .pending: return "Pending Review"
        case .verified: return "Verified"
        case .rejected: return "Rejected"
        }
    }
}

// MARK: - Vehicle Type
enum DriverVehicleType: String, Codable, CaseIterable, Hashable {
    case bike
    case motorbike
    case car
    case van
    case walker

    var displayLabel: String {
        switch self {
        case .bike: return "Bicycle"
        case .motorbike: return "Motorbike"
        case .car: return "Car"
        case .van: return "Van"
        case .walker: return "On Foot"
        }
    }

    var systemIcon: String {
        switch self {
        case .bike: return "bicycle"
        case .motorbike: return "motorcycle"
        case .car: return "car.fill"
        case .van: return "van.fill"
        case .walker: return "figure.walk"
        }
    }
}

// MARK: - Vehicle
struct DriverVehicle: Codable, Hashable {
    var type: DriverVehicleType
    var make: String
    var model: String
    var plateNumber: String
    var color: String

    var displaySummary: String {
        "\(color) \(make) \(model) · \(plateNumber)"
    }
}

// MARK: - Availability
enum DriverAvailability: String, Codable, CaseIterable, Hashable {
    case offline
    case online
    case onJob = "on_job"
    case paused
    case verificationRequired = "verification_required"
    case zoneUnavailable = "zone_unavailable"

    var displayLabel: String {
        switch self {
        case .offline: return "Offline"
        case .online: return "Online"
        case .onJob: return "On Delivery"
        case .paused: return "Paused"
        case .verificationRequired: return "Verification Required"
        case .zoneUnavailable: return "Zone Unavailable"
        }
    }
}

enum DriverShiftStatus: String, Codable, Hashable {
    case active
    case paused
    case ended

    var displayLabel: String {
        switch self {
        case .active: return "Active"
        case .paused: return "Paused"
        case .ended: return "Ended"
        }
    }
}

struct DriverShift: Identifiable, Codable, Hashable {
    let id: String
    var startedAt: Date
    var endedAt: Date?
    var city: String
    var zone: String
    var onlineDurationMinutes: Int
    var completedJobs: Int
    var totalEarnings: Double
    var status: DriverShiftStatus
}

enum DeliveryZoneDemandLevel: String, Codable, CaseIterable, Hashable {
    case low
    case normal
    case high

    var displayLabel: String {
        switch self {
        case .low: return "Low demand"
        case .normal: return "Normal demand"
        case .high: return "High demand"
        }
    }
}

struct DeliveryZone: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var city: String
    var areas: [String]
    var isActive: Bool
    var demandLevel: DeliveryZoneDemandLevel
    var estimatedRequests: Int
    var notes: String
}

enum DispatchRequestPriority: String, Codable, Hashable {
    case normal
    case high
}

enum DispatchRequestStatus: String, Codable, Hashable {
    case pending
    case accepted
    case declined
    case expired
    case cancelled
}

struct DispatchRequest: Identifiable, Codable, Hashable {
    let id: String
    let jobID: String
    let receivedAt: Date
    var expiresAt: Date?
    var priority: DispatchRequestPriority
    var recommendationReason: String
    var status: DispatchRequestStatus
}

enum WalletTransactionType: String, Codable, Hashable {
    case deliveryCompleted
    case tipReceived
    case cashCollected
    case payoutPending
    case adjustment

    var displayLabel: String {
        switch self {
        case .deliveryCompleted: return "Delivery completed"
        case .tipReceived: return "Tip received"
        case .cashCollected: return "Cash collected"
        case .payoutPending: return "Payout pending"
        case .adjustment: return "Adjustment"
        }
    }
}

struct WalletTransaction: Identifiable, Codable, Hashable {
    let id: String
    let type: WalletTransactionType
    let amount: Double
    let relatedJobID: String?
    let createdAt: Date
    var status: String
    var notes: String
}

// MARK: - Driver Profile
struct DriverProfile: Identifiable, Codable, Hashable {
    let id: String
    var fullName: String
    var phone: String
    var email: String
    var city: String
    var avatarInitials: String
    var verificationStatus: DriverVerificationStatus
    var vehicle: DriverVehicle
    var rating: Double
    var completedJobs: Int
    var joinedAt: Date
    // Legacy/mock snapshots predate the country engine. Real onboarding/profile writes an explicit country.
    var countryCode: SpotlyCountryCode = .ZW

    var firstName: String {
        fullName.components(separatedBy: " ").first ?? fullName
    }
}

// MARK: - Operational Job Types
enum DeliveryJobType: String, Codable, CaseIterable, Hashable {
    case preparedFoodPickup
    case groceryShopAndDeliver
    case preparedPickup
    case shopAndDeliver
    case pickupCodeRequired
    case pharmacyVerifiedPickup
    case giftDelivery
    case cashCollectionDelivery
    case eventVendorDelivery
    case eventVendorSupport
    case cashCollection
    case mixed

    var displayLabel: String {
        switch self {
        case .preparedFoodPickup: return "Ready for pickup"
        case .groceryShopAndDeliver: return "Shop & deliver"
        case .preparedPickup: return "Ready for pickup"
        case .shopAndDeliver: return "Shop & deliver"
        case .pickupCodeRequired: return "Pickup code required"
        case .pharmacyVerifiedPickup: return "Pharmacy verified"
        case .giftDelivery: return "Gift delivery"
        case .cashCollectionDelivery: return "Collect cash"
        case .eventVendorDelivery: return "Vendor support"
        case .eventVendorSupport: return "Vendor support"
        case .cashCollection: return "Cash collection"
        case .mixed: return "Mixed workflow"
        }
    }
}

enum FulfillmentMode: String, Codable, CaseIterable, Hashable {
    case merchantPrepared
    case driverShop
    case pickupFromCounter
    case pickupCodeRequired
    case pickupWithCode
    case orderNumberConfirmation
    case pharmacyVerified
    case giftPrepared
    case eventPack

    var displayLabel: String {
        switch self {
        case .merchantPrepared: return "Merchant prepared"
        case .driverShop: return "Driver shops order"
        case .pickupFromCounter: return "Counter pickup"
        case .pickupCodeRequired: return "Pickup code required"
        case .pickupWithCode: return "Pickup with code"
        case .orderNumberConfirmation: return "Order number confirmation"
        case .pharmacyVerified: return "Verified pharmacy package"
        case .giftPrepared: return "Gift prepared"
        case .eventPack: return "Event pack"
        }
    }
}

enum PickupRequirement: String, Codable, CaseIterable, Hashable {
    case none
    case showPickupCode
    case scanMerchantQRPlaceholder
    case confirmOrderNumber
    case collectPackage
    case collectSealedPackage
    case collectGiftPackage
    case shopItems
    case receiptUploadPlaceholder
    case uploadReceiptPlaceholder

    var displayLabel: String {
        switch self {
        case .none: return "No pickup check"
        case .showPickupCode: return "Show pickup code"
        case .scanMerchantQRPlaceholder: return "Merchant QR"
        case .confirmOrderNumber: return "Confirm order number"
        case .collectPackage: return "Collect package"
        case .collectSealedPackage: return "Collect sealed package"
        case .collectGiftPackage: return "Collect gift package"
        case .shopItems: return "Shop items"
        case .receiptUploadPlaceholder: return "Receipt proof"
        case .uploadReceiptPlaceholder: return "Receipt proof"
        }
    }
}

enum DropoffRequirement: String, Codable, CaseIterable, Hashable {
    case handToCustomer
    case leaveAtDoor
    case meetCustomer
    case customerPIN
    case customerQRPlaceholder
    case signaturePlaceholder
    case collectCash
    case photoProofPlaceholder

    var displayLabel: String {
        switch self {
        case .handToCustomer: return "Hand to customer"
        case .leaveAtDoor: return "Leave at door"
        case .meetCustomer: return "Meet customer"
        case .customerPIN: return "Customer PIN required"
        case .customerQRPlaceholder: return "Customer QR"
        case .signaturePlaceholder: return "Signature proof"
        case .collectCash: return "Collect cash"
        case .photoProofPlaceholder: return "Photo proof"
        }
    }
}

enum PaymentHandling: Codable, Hashable {
    case prepaid
    case cashOnDelivery(amount: Double)
    case payAtVenue
    case noCollection

    var displayLabel: String {
        switch self {
        case .prepaid: return "Prepaid"
        case .cashOnDelivery(let amount): return "Collect cash: \(DriverFormatters.price(amount))"
        case .payAtVenue: return "Pay at venue"
        case .noCollection: return "No collection"
        }
    }

    var cashAmount: Double {
        if case .cashOnDelivery(let amount) = self { return amount }
        return 0
    }

    var requiresAction: Bool {
        switch self {
        case .cashOnDelivery, .payAtVenue: return true
        case .prepaid, .noCollection: return false
        }
    }
}

enum PaymentCollectionType: String, Codable, Hashable {
    case prepaid = "prepaid"
    case cashOnDelivery = "cash_on_delivery"
    case payAtVenue = "pay_at_venue"
    case none = "none"

    var displayLabel: String {
        switch self {
        case .prepaid: return "Prepaid"
        case .cashOnDelivery: return "Collect Cash"
        case .payAtVenue: return "Pay at Venue"
        case .none: return "No Payment"
        }
    }

    var requiresAction: Bool {
        self == .cashOnDelivery || self == .payAtVenue
    }
}

struct DeliveryItem: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var quantity: String
    var notes: String?
    var isFound: Bool
    var isUnavailable: Bool
    var substitution: String?
    var price: Double?

    var isHandled: Bool { isFound || isUnavailable || substitution != nil }
}

enum DeliveryProofStatus: String, Codable, Hashable {
    case notRequired
    case pending
    case placeholderSubmitted
}

struct JobTimelineEvent: Identifiable, Codable, Hashable {
    let id: String
    let jobID: String
    let title: String
    let subtitle: String
    let timestamp: Date
    let status: DeliveryJobStatus
    let iconName: String
}

// MARK: - Job Status
enum DeliveryJobStatus: String, Codable, CaseIterable, Hashable {
    case offered
    case accepted
    case enRouteToPickup = "en_route_to_pickup"
    case arrivedAtPickup = "arrived_at_pickup"
    case shopping
    case readyForCheckout = "ready_for_checkout"
    case pickedUp = "picked_up"
    case enRouteToDropoff = "en_route_to_dropoff"
    case arrivedAtDropoff = "arrived_at_dropoff"
    case awaitingCustomerPIN = "awaiting_customer_pin"
    case delivered
    case cancelled
    case failed

    var displayLabel: String {
        switch self {
        case .offered: return "New Request"
        case .accepted: return "Accepted"
        case .enRouteToPickup: return "To Pickup"
        case .arrivedAtPickup: return "At Pickup"
        case .shopping: return "Shopping"
        case .readyForCheckout: return "Ready for Checkout"
        case .pickedUp: return "Picked Up"
        case .enRouteToDropoff: return "To Drop-off"
        case .arrivedAtDropoff: return "At Drop-off"
        case .awaitingCustomerPIN: return "Customer PIN"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        case .failed: return "Failed"
        }
    }

    var stepIndex: Int {
        switch self {
        case .offered: return 0
        case .accepted, .enRouteToPickup: return 1
        case .arrivedAtPickup, .shopping, .readyForCheckout: return 2
        case .pickedUp, .enRouteToDropoff: return 3
        case .arrivedAtDropoff, .awaitingCustomerPIN: return 4
        case .delivered: return 5
        case .cancelled, .failed: return -1
        }
    }

    var nextStepCTA: String {
        switch self {
        case .offered: return "Accept Job"
        case .accepted, .enRouteToPickup: return "I've Arrived at Pickup"
        case .arrivedAtPickup: return "Confirm Pickup"
        case .shopping: return "Open Shopping List"
        case .readyForCheckout: return "Continue to Receipt"
        case .pickedUp, .enRouteToDropoff: return "I've Arrived at Drop-off"
        case .arrivedAtDropoff: return "Complete Delivery"
        case .awaitingCustomerPIN: return "Enter Customer PIN"
        case .delivered: return "Done"
        case .cancelled, .failed: return ""
        }
    }

    var isActive: Bool {
        switch self {
        case .accepted, .enRouteToPickup, .arrivedAtPickup, .shopping, .readyForCheckout, .pickedUp, .enRouteToDropoff, .arrivedAtDropoff, .awaitingCustomerPIN:
            return true
        default:
            return false
        }
    }
}

// MARK: - Delivery Job
struct DeliveryJob: Identifiable, Codable, Hashable {
    let id: String
    let orderID: String
    let businessID: String
    let businessName: String
    let businessCategory: String
    var jobType: DeliveryJobType
    var fulfillmentMode: FulfillmentMode
    var pickupRequirement: PickupRequirement
    var dropoffRequirement: DropoffRequirement
    var paymentHandling: PaymentHandling
    let pickupAddress: String
    let pickupArea: String
    let dropoffAddress: String
    let dropoffArea: String
    let customerName: String
    let maskedPhone: String
    var items: [DeliveryItem]
    var substitutionsAllowed: Bool
    var pickupCode: String?
    var customerPIN: String?
    var orderNumber: String?
    let distanceKM: Double
    let estimatedDurationMinutes: Int
    let pickupTimeWindow: String
    let earnings: Double
    let tip: Double
    var status: DeliveryJobStatus
    let createdAt: Date
    var acceptedAt: Date?
    var completedAt: Date?
    var notes: String?
    var proofStatus: DeliveryProofStatus?
    var timeline: [JobTimelineEvent]? = nil
    var pickupLatitude: Double?
    var pickupLongitude: Double?
    var dropoffLatitude: Double?
    var dropoffLongitude: Double?

    var customerPhoneMasked: String { maskedPhone }
    var itemCount: Int { items.count }
    var itemsSummary: String { items.map { "\($0.name) \($0.quantity)" }.joined(separator: ", ") }
    var totalEarnings: Double { earnings + tip }
    var cashToCollect: Double { paymentHandling.cashAmount }

    var paymentCollectionType: PaymentCollectionType {
        switch paymentHandling {
        case .prepaid: return .prepaid
        case .cashOnDelivery: return .cashOnDelivery
        case .payAtVenue: return .payAtVenue
        case .noCollection: return .none
        }
    }

    var handledItemCount: Int { items.filter(\.isHandled).count }
    var needsCustomerPIN: Bool { dropoffRequirement == .customerPIN || customerPIN != nil }
    var needsProof: Bool { dropoffRequirement == .photoProofPlaceholder || dropoffRequirement == .signaturePlaceholder || proofStatus == .pending }
    var needsShopping: Bool { fulfillmentMode == .driverShop || pickupRequirement == .shopItems }
    var requiresPickupCode: Bool { pickupRequirement == .showPickupCode || pickupRequirement == .confirmOrderNumber || pickupCode != nil || orderNumber != nil }

    var operationalBadge: String { jobType.displayLabel }

    var recommendationReason: String {
        if cashToCollect > 0 { return "Cash collection" }
        if jobType == .pharmacyVerifiedPickup { return "Pharmacy verified" }
        if needsShopping { return "Shop & deliver" }
        if totalEarnings >= 5.5 { return "High earnings" }
        if estimatedDurationMinutes <= 18 { return "Quick pickup" }
        if distanceKM <= 3.5 { return "Low distance" }
        return "Best nearby"
    }

    var categoryIcon: String {
        let cat = businessCategory.lowercased()
        if cat.contains("food") || cat.contains("restaurant") || cat.contains("braai") || cat.contains("nando") { return "fork.knife" }
        if cat.contains("grocery") || cat.contains("spar") || cat.contains("market") { return "cart.fill" }
        if cat.contains("pharmacy") || cat.contains("wellness") { return "cross.fill" }
        if cat.contains("flower") || cat.contains("gift") || cat.contains("petal") { return "gift.fill" }
        if cat.contains("event") || cat.contains("vendor") { return "calendar.badge.clock" }
        return "shippingbox.fill"
    }
}

// MARK: - Earnings Summary
struct DriverEarningsSummary: Codable, Hashable {
    var todayEarnings: Double
    var weeklyEarnings: Double
    var completedToday: Int
    var acceptanceRate: Double
    var onlineHours: Double
    var pendingPayout: Double
}

// MARK: - Notification Type
enum DriverNotificationType: String, Codable, CaseIterable, Hashable {
    case newJobRequest = "new_job_request"
    case pickupCodeReady = "pickup_code_ready"
    case customerNoteUpdated = "customer_note_updated"
    case cashCollectionReminder = "cash_collection_reminder"
    case incidentUpdate = "incident_update"
    case shiftSummary = "shift_summary"
    case newJob = "new_job"
    case pickupCodeRequired = "pickup_code_required"
    case dropoffNoteChanged = "dropoff_note_changed"
    case jobCancelled = "job_cancelled"
    case payoutUpdate = "payout_update"
    case verificationUpdate = "verification_update"
    case safetyReminder = "safety_reminder"
    case general

    var systemIcon: String {
        switch self {
        case .newJobRequest: return "shippingbox.fill"
        case .pickupCodeReady: return "number.square.fill"
        case .customerNoteUpdated: return "text.bubble.fill"
        case .cashCollectionReminder: return "banknote.fill"
        case .incidentUpdate: return "exclamationmark.bubble.fill"
        case .shiftSummary: return "clock.badge.checkmark.fill"
        case .newJob: return "shippingbox.fill"
        case .pickupCodeRequired: return "number.square.fill"
        case .dropoffNoteChanged: return "text.bubble.fill"
        case .jobCancelled: return "xmark.circle.fill"
        case .payoutUpdate: return "dollarsign.circle.fill"
        case .verificationUpdate: return "checkmark.shield.fill"
        case .safetyReminder: return "exclamationmark.triangle.fill"
        case .general: return "bell.fill"
        }
    }
}

// MARK: - Driver Notification
struct DriverNotification: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let message: String
    let type: DriverNotificationType
    let createdAt: Date
    var isRead: Bool
    let relatedJobID: String?
}

// MARK: - Incident Type
enum DriverIncidentType: String, Codable, CaseIterable, Hashable {
    case storeNotReady = "store_not_ready"
    case customerUnavailable = "customer_unavailable"
    case addressProblem = "address_problem"
    case vehicleIssue = "vehicle_issue"
    case paymentIssue = "payment_issue"
    case safetyConcern = "safety_concern"
    case other

    var displayLabel: String {
        switch self {
        case .storeNotReady: return "Store Not Ready"
        case .customerUnavailable: return "Customer Unavailable"
        case .addressProblem: return "Address Problem"
        case .vehicleIssue: return "Vehicle Issue"
        case .paymentIssue: return "Payment Issue"
        case .safetyConcern: return "Safety Concern"
        case .other: return "Other"
        }
    }
}

// MARK: - Incident Status
enum DriverIncidentStatus: String, Codable, Hashable {
    case open
    case underReview = "under_review"
    case resolved
}

// MARK: - Driver Incident
struct DriverIncident: Identifiable, Codable, Hashable {
    let id: String
    let jobID: String
    let type: DriverIncidentType
    let notes: String
    let createdAt: Date
    var status: DriverIncidentStatus
}

// MARK: - Auth State
enum DriverAuthState: Hashable {
    case splash
    case welcome
    case signIn
    case onboarding
    case main
}

// MARK: - Canonical Spotly work contract
extension DeliveryJob {
    /// The current Driver prototype models merchant delivery jobs only. Ride and Send
    /// gain their own runtime models in later phases, but all three share this wire enum.
    var contractWorkType: SpotlyDriverWorkType { .delivery }
}
