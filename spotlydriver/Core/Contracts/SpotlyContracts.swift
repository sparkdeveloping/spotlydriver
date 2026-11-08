// GENERATED from Spotly Web contracts/spotly-contracts.v1.json. Do not edit by hand.
import Foundation

nonisolated enum SpotlyContractMetadata {
    static let version = "1.0.0"
    static let manifestSHA256 = "753652a6e58d51dc05d11e10640e2b1adef67fe865e734b0c5af389ae735535a"
}

nonisolated enum SpotlyServiceID: String, CaseIterable, Codable, Hashable, Sendable {
    case eat = "eat"
    case shop = "shop"
    case ride = "ride"
    case book = "book"
    case events = "events"
    case send = "send"
}

nonisolated enum SpotlyCountryCode: String, CaseIterable, Codable, Hashable, Sendable {
    case ZW = "ZW"
    case MW = "MW"
}

nonisolated enum SpotlyCurrencyCode: String, CaseIterable, Codable, Hashable, Sendable {
    case USD = "USD"
    case ZWG = "ZWG"
    case MWK = "MWK"
}

nonisolated enum SpotlyActivityKind: String, CaseIterable, Codable, Hashable, Sendable {
    case order = "order"
    case appointment = "appointment"
    case booking = "booking"
    case ticket = "ticket"
    case ride = "ride"
    case send = "send"
    case assistShopping = "assist_shopping"
    case assistBooking = "assist_booking"
}

nonisolated enum SpotlyTransactionKind: String, CaseIterable, Codable, Hashable, Sendable {
    case order = "order"
    case appointment = "appointment"
    case booking = "booking"
    case ticket = "ticket"
    case ride = "ride"
    case send = "send"
    case independentShopping = "independent_shopping"
    case assistedBooking = "assisted_booking"
}

nonisolated enum SpotlyDriverWorkType: String, CaseIterable, Codable, Hashable, Sendable {
    case delivery = "delivery"
    case ride = "ride"
    case send = "send"
}

nonisolated enum SpotlyRideServiceTypeID: String, CaseIterable, Codable, Hashable, Sendable {
    case economy = "economy"
    case comfort = "comfort"
    case xl = "xl"
}

nonisolated enum SpotlyParcelSize: String, CaseIterable, Codable, Hashable, Sendable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case bulky = "bulky"
}

nonisolated enum SpotlyPaymentMethod: String, CaseIterable, Codable, Hashable, Sendable {
    case cash = "cash"
    case paynow = "paynow"
    case ecocash = "ecocash"
    case onemoney = "onemoney"
    case card = "card"
    case bankTransfer = "bank_transfer"
    case payLater = "pay_later"
    case superadminTest = "superadmin_test"
}

nonisolated enum SpotlyPaymentState: String, CaseIterable, Codable, Hashable, Sendable {
    case notRequired = "not_required"
    case notInitiated = "not_initiated"
    case unpaid = "unpaid"
    case dueAtPickup = "due_at_pickup"
    case awaitingTransfer = "awaiting_transfer"
    case cashDue = "cash_due"
    case initiated = "initiated"
    case pending = "pending"
    case paid = "paid"
    case paidHeld = "paid_held"
    case reconciled = "reconciled"
    case paymentReviewRequired = "payment_review_required"
    case refundPending = "refund_pending"
    case refunded = "refunded"
    case refundFailed = "refund_failed"
    case failed = "failed"
    case actionRequired = "action_required"
    case awaitingPayment = "awaiting_payment"
    case payLater = "pay_later"
    case testPaid = "test_paid"
    case cashDriverAttested = "cash_driver_attested"
}

nonisolated enum SpotlyPrimaryAction: String, CaseIterable, Codable, Hashable, Sendable {
    case pay = "pay"
    case track = "track"
    case open = "open"
    case support = "support"
    case reviewQuote = "review_quote"
    case reviewAlternative = "review_alternative"
    case reviewSubstitution = "review_substitution"
}

nonisolated enum SpotlyPickupMode: String, CaseIterable, Codable, Hashable, Sendable {
    case now = "now"
    case scheduled = "scheduled"
}

typealias SpotlyServiceKind = SpotlyServiceID

nonisolated struct SpotlyMoney: Codable, Hashable, Sendable {
    let amount: Double
    let currency: SpotlyCurrencyCode
}

nonisolated struct SpotlyLocationPoint: Codable, Hashable, Sendable {
    let lat: Double
    let lng: Double
    let accuracy: Double?
    let country: SpotlyCountryCode
    let label: String?
    let formattedAddress: String?
    let area: String?
    let city: String?

    init(lat: Double, lng: Double, accuracy: Double? = nil, country: SpotlyCountryCode, label: String? = nil, formattedAddress: String? = nil, area: String? = nil, city: String? = nil) {
        self.lat = lat
        self.lng = lng
        self.accuracy = accuracy
        self.country = country
        self.label = label
        self.formattedAddress = formattedAddress
        self.area = area
        self.city = city
    }
}

nonisolated struct SpotlyQuoteLock: Codable, Hashable, Sendable {
    let quotedTotal: Double
    let quotedCurrency: SpotlyCurrencyCode
}

nonisolated struct SpotlyAPIErrorEnvelope: Codable, Hashable, Sendable {
    let ok: Bool
    let error: String
    let code: String?
    let retryable: Bool?
}

nonisolated struct SpotlyDriverWorkOfferContract: Codable, Hashable, Sendable {
    let id: String
    let workType: SpotlyDriverWorkType
    let state: String
    let currency: SpotlyCurrencyCode
    let estimatedEarnings: Double
    let pickup: SpotlyLocationPoint?
    let dropoff: SpotlyLocationPoint?
    let expiresAt: String?
}
