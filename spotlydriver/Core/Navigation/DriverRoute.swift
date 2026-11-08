import Foundation

enum DriverRoute: Hashable {
    case activeJob(String)
    case jobDetail(String)
    case shoppingList(String)
    case pickupCode(String)
    case customerPIN(String)
    case cashCollection(String)
    case proofOfDelivery(String)
    case earningsDetail
    case notificationDetail(String)
    case profileDestination(DriverProfileDestination)
    case support
    case safety
    case reportIssue(String?)
    case verification
    case notifications
    case jobUnavailable
}

enum DriverProfileDestination: String, Hashable, CaseIterable {
    case personalDetails
    case vehicleDetails
    case documents
    case payoutMethod
    case availabilityPreferences
    case deliveryZones
    case jobHistory
    case performance
    case helpSupport
    case safetyCenter
    case reportIssue
    case terms
    case privacy
    case about
    case appearance

    var displayTitle: String {
        switch self {
        case .personalDetails: return "Personal Details"
        case .vehicleDetails: return "Vehicle Details"
        case .documents: return "Documents"
        case .payoutMethod: return "Payout Method"
        case .availabilityPreferences: return "Availability Preferences"
        case .deliveryZones: return "Delivery Zones"
        case .jobHistory: return "Job History"
        case .performance: return "Performance"
        case .helpSupport: return "Help & Support"
        case .safetyCenter: return "Safety Center"
        case .reportIssue: return "Report Issue"
        case .terms: return "Terms of Service"
        case .privacy: return "Privacy Policy"
        case .about: return "About Spotly Driver"
        case .appearance: return "Appearance"
        }
    }
}
