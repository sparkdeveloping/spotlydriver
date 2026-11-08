import Foundation

enum DriverMockData {
    private static func minutesAgo(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: -value, to: Date()) ?? Date()
    }

    private static func hoursAgo(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: -value, to: Date()) ?? Date()
    }

    static let profile = DriverProfile(
        id: "driver-001",
        fullName: "Denzel Moyo",
        phone: "+263 77 234 5678",
        email: "denzel.moyo@example.com",
        city: "Harare",
        avatarInitials: "DM",
        verificationStatus: .verified,
        vehicle: DriverVehicle(type: .motorbike, make: "Honda", model: "CG125", plateNumber: "ADE 1234", color: "Black"),
        rating: 4.8,
        completedJobs: 127,
        joinedAt: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date()
    )

    static let zones: [DeliveryZone] = [
        DeliveryZone(id: "zone-harare-north", name: "Harare North", city: "Harare", areas: ["Borrowdale", "Avondale", "Highlands", "Mount Pleasant"], isActive: true, demandLevel: .high, estimatedRequests: 12, notes: "Best coverage for grocery, pharmacy, food, and gift requests."),
        DeliveryZone(id: "zone-harare-cbd", name: "Harare CBD", city: "Harare", areas: ["CBD", "Avenues", "Milton Park"], isActive: true, demandLevel: .normal, estimatedRequests: 7, notes: "Strong lunch and pharmacy pickup demand."),
        DeliveryZone(id: "zone-bulawayo-central", name: "Bulawayo Central", city: "Bulawayo", areas: ["City Centre", "Suburbs", "Famona"], isActive: false, demandLevel: .low, estimatedRequests: 0, notes: "Launch partner zone coming soon."),
        DeliveryZone(id: "zone-vic-falls", name: "Victoria Falls launch zone", city: "Victoria Falls", areas: ["Town Centre", "Falls Drive"], isActive: false, demandLevel: .low, estimatedRequests: 0, notes: "Launch partner zone coming soon."),
        DeliveryZone(id: "zone-mutare", name: "Mutare launch zone", city: "Mutare", areas: ["City Centre", "Murambi"], isActive: false, demandLevel: .low, estimatedRequests: 0, notes: "Launch partner zone coming soon.")
    ]

    static let offeredJobs: [DeliveryJob] = [
        DeliveryJob(
            id: "job-002",
            orderID: "ORD-10482",
            businessID: "biz-spar",
            businessName: "Spar Avondale",
            businessCategory: "Grocery",
            jobType: .groceryShopAndDeliver,
            fulfillmentMode: .driverShop,
            pickupRequirement: .shopItems,
            dropoffRequirement: .meetCustomer,
            paymentHandling: .prepaid,
            pickupAddress: "Spar Avondale, King George Road",
            pickupArea: "Avondale",
            dropoffAddress: "45 Milton Park Drive, Milton Park",
            dropoffArea: "Milton Park",
            customerName: "F. Chikwanda",
            maskedPhone: "+263 71 *** 8832",
            items: [
                DeliveryItem(id: "item-spar-bread", name: "Bread", quantity: "x1", notes: nil, isFound: false, isUnavailable: false, substitution: nil, price: 1.20),
                DeliveryItem(id: "item-spar-milk", name: "Milk", quantity: "x2", notes: "Full cream if available", isFound: false, isUnavailable: false, substitution: nil, price: 2.40),
                DeliveryItem(id: "item-spar-eggs", name: "Eggs", quantity: "x1", notes: "Tray of 12", isFound: false, isUnavailable: false, substitution: nil, price: 3.10),
                DeliveryItem(id: "item-spar-tomatoes", name: "Tomatoes", quantity: "x1 bag", notes: "Firm tomatoes", isFound: false, isUnavailable: false, substitution: nil, price: 1.80),
                DeliveryItem(id: "item-spar-chicken", name: "Chicken pack", quantity: "x1", notes: "Fresh pack if available", isFound: false, isUnavailable: false, substitution: nil, price: 5.20)
            ],
            substitutionsAllowed: true,
            pickupCode: nil,
            customerPIN: nil,
            orderNumber: "SPT-10482",
            distanceKM: 3.1,
            estimatedDurationMinutes: 14,
            pickupTimeWindow: "Shop now",
            earnings: 4.25,
            tip: 0.50,
            status: .offered,
            createdAt: minutesAgo(1),
            notes: "Substitutions allowed. Receipt upload will be enabled before launch.",
            proofStatus: .pending
        ),
        DeliveryJob(
            id: "job-001",
            orderID: "ORD-10481",
            businessID: "biz-braai",
            businessName: "The Braai House",
            businessCategory: "Restaurant",
            jobType: .preparedFoodPickup,
            fulfillmentMode: .orderNumberConfirmation,
            pickupRequirement: .confirmOrderNumber,
            dropoffRequirement: .customerPIN,
            paymentHandling: .prepaid,
            pickupAddress: "14 Borrowdale Road, Borrowdale",
            pickupArea: "Borrowdale",
            dropoffAddress: "32 Avondale Shopping Centre, Avondale",
            dropoffArea: "Avondale",
            customerName: "T. Mutasa",
            maskedPhone: "+263 77 *** 4521",
            items: [DeliveryItem(id: "item-braai-combo", name: "Chicken combo, sadza & stew", quantity: "x1", notes: nil, isFound: true, isUnavailable: false, substitution: nil, price: nil)],
            substitutionsAllowed: false,
            pickupCode: nil,
            customerPIN: "4821",
            orderNumber: "SPT-2148",
            distanceKM: 4.2,
            estimatedDurationMinutes: 18,
            pickupTimeWindow: "Ready in ~5 min",
            earnings: 4.50,
            tip: 0.00,
            status: .offered,
            createdAt: minutesAgo(2)
        ),
        DeliveryJob(
            id: "job-004",
            orderID: "ORD-10484",
            businessID: "biz-booties",
            businessName: "Booties Pharmacy",
            businessCategory: "Pharmacy",
            jobType: .pharmacyVerifiedPickup,
            fulfillmentMode: .pharmacyVerified,
            pickupRequirement: .collectSealedPackage,
            dropoffRequirement: .customerPIN,
            paymentHandling: .prepaid,
            pickupAddress: "Booties Pharmacy, Nelson Mandela Ave, CBD",
            pickupArea: "Harare CBD",
            dropoffAddress: "67 Mount Pleasant Heights, Mount Pleasant",
            dropoffArea: "Mount Pleasant",
            customerName: "R. Sibanda",
            maskedPhone: "+263 77 *** 9104",
            items: [DeliveryItem(id: "item-rx-package", name: "Verified pharmacy package", quantity: "x1", notes: "Sealed package", isFound: true, isUnavailable: false, substitution: nil, price: nil)],
            substitutionsAllowed: false,
            pickupCode: "RX-6021",
            customerPIN: "7294",
            orderNumber: "ORD-10484",
            distanceKM: 6.4,
            estimatedDurationMinutes: 26,
            pickupTimeWindow: "Ready in ~15 min",
            earnings: 5.75,
            tip: 0.00,
            status: .offered,
            createdAt: minutesAgo(5),
            notes: "Customer verification completed at checkout. Do not list package contents."
        ),
        DeliveryJob(
            id: "job-003",
            orderID: "ORD-10483",
            businessID: "biz-petal",
            businessName: "Petal & Bow",
            businessCategory: "Flowers & Gifts",
            jobType: .giftDelivery,
            fulfillmentMode: .giftPrepared,
            pickupRequirement: .collectGiftPackage,
            dropoffRequirement: .photoProofPlaceholder,
            paymentHandling: .prepaid,
            pickupAddress: "Borrowdale Village, Shop 12",
            pickupArea: "Borrowdale Village",
            dropoffAddress: "18 Highlands Drive, Highlands",
            dropoffArea: "Highlands",
            customerName: "P. Ndoro",
            maskedPhone: "+263 78 *** 2201",
            items: [DeliveryItem(id: "item-petal-bouquet", name: "Bouquet and gift card", quantity: "x1", notes: "Keep upright", isFound: true, isUnavailable: false, substitution: nil, price: nil)],
            substitutionsAllowed: false,
            pickupCode: nil,
            customerPIN: nil,
            orderNumber: "GFT-10483",
            distanceKM: 5.6,
            estimatedDurationMinutes: 22,
            pickupTimeWindow: "Ready in ~10 min",
            earnings: 5.25,
            tip: 1.00,
            status: .offered,
            createdAt: minutesAgo(3),
            notes: "Keep upright. Do not leave in direct sun.",
            proofStatus: .pending
        ),
        DeliveryJob(
            id: "job-005",
            orderID: "ORD-10485",
            businessID: "biz-nandos",
            businessName: "Nando's Borrowdale",
            businessCategory: "Takeaway",
            jobType: .cashCollection,
            fulfillmentMode: .merchantPrepared,
            pickupRequirement: .confirmOrderNumber,
            dropoffRequirement: .collectCash,
            paymentHandling: .cashOnDelivery(amount: 18.40),
            pickupAddress: "Nando's Borrowdale, Borrowdale Road",
            pickupArea: "Borrowdale",
            dropoffAddress: "14 Msasa Drive, Greendale",
            dropoffArea: "Greendale",
            customerName: "K. Zhou",
            maskedPhone: "+263 78 *** 6302",
            items: [DeliveryItem(id: "item-nandos-takeaway", name: "Family peri-peri meal", quantity: "x1", notes: nil, isFound: true, isUnavailable: false, substitution: nil, price: nil)],
            substitutionsAllowed: false,
            pickupCode: nil,
            customerPIN: "1937",
            orderNumber: "SPT-1840",
            distanceKM: 4.8,
            estimatedDurationMinutes: 21,
            pickupTimeWindow: "Ready for pickup",
            earnings: 4.00,
            tip: 0.00,
            status: .offered,
            createdAt: minutesAgo(4),
            notes: "Collect USD 18.40 before confirming delivery."
        ),
        DeliveryJob(
            id: "job-006",
            orderID: "ORD-10486",
            businessID: "biz-foodlovers-borrowdale",
            businessName: "Food Lovers Market",
            businessCategory: "Grocery",
            jobType: .groceryShopAndDeliver,
            fulfillmentMode: .driverShop,
            pickupRequirement: .shopItems,
            dropoffRequirement: .leaveAtDoor,
            paymentHandling: .prepaid,
            pickupAddress: "Food Lovers Market, Borrowdale",
            pickupArea: "Borrowdale",
            dropoffAddress: "22 Highlands Lane, Highlands",
            dropoffArea: "Highlands",
            customerName: "M. Nyathi",
            maskedPhone: "+263 77 *** 4420",
            items: [
                DeliveryItem(id: "item-flm-apples", name: "Apples", quantity: "x6", notes: nil, isFound: false, isUnavailable: false, substitution: nil, price: nil),
                DeliveryItem(id: "item-flm-bananas", name: "Bananas", quantity: "x1 bunch", notes: "Ripe but firm", isFound: false, isUnavailable: false, substitution: nil, price: nil),
                DeliveryItem(id: "item-flm-lettuce", name: "Lettuce", quantity: "x1", notes: nil, isFound: false, isUnavailable: false, substitution: nil, price: nil),
                DeliveryItem(id: "item-flm-avocados", name: "Avocados", quantity: "x4", notes: "Medium ripe", isFound: false, isUnavailable: false, substitution: nil, price: nil)
            ],
            substitutionsAllowed: true,
            pickupCode: nil,
            customerPIN: nil,
            orderNumber: "SPT-10486",
            distanceKM: 4.0,
            estimatedDurationMinutes: 19,
            pickupTimeWindow: "Shop now",
            earnings: 4.80,
            tip: 0.00,
            status: .offered,
            createdAt: minutesAgo(6),
            notes: "Substitutions allowed. Receipt upload will be enabled before launch.",
            proofStatus: .pending
        )
    ]

    static let completedJobs: [DeliveryJob] = [
        completedJob(id: "job-c001", orderID: "ORD-10471", businessID: "biz-namaste", name: "Namaste Harare", category: "Restaurant", pickup: "Borrowdale", dropoff: "Chisipite", items: "Chicken tikka masala, garlic naan, samosas", earnings: 4.25, tip: 0.75, hoursAgo: 3),
        completedJob(id: "job-c002", orderID: "ORD-10465", businessID: "biz-foodlovers", name: "Food Lovers Market", category: "Grocery", pickup: "Borrowdale Brooke", dropoff: "Gunhill", items: "Mixed groceries bag", earnings: 3.50, tip: 0.00, hoursAgo: 5),
        completedJob(id: "job-c003", orderID: "ORD-10458", businessID: "biz-vertex", name: "Vertex Wellness", category: "Flowers & Gifts", pickup: "Newlands", dropoff: "Vainona", items: "Gift package wellness hamper", earnings: 5.00, tip: 1.50, hoursAgo: 7),
        completedJob(id: "job-c004", orderID: "ORD-10452", businessID: "biz-chicken-inn", name: "Chicken Inn", category: "Takeaway", pickup: "Avondale", dropoff: "Belgravia", items: "Two-piece meal and chips", earnings: 3.25, tip: 0.00, hoursAgo: 9)
    ]

    static let cancelledJobs: [DeliveryJob] = [
        DeliveryJob(
            id: "job-x001",
            orderID: "ORD-10440",
            businessID: "biz-court-zero",
            businessName: "Court Zero Padel",
            businessCategory: "Event Vendor Support",
            jobType: .eventVendorSupport,
            fulfillmentMode: .eventPack,
            pickupRequirement: .collectPackage,
            dropoffRequirement: .meetCustomer,
            paymentHandling: .prepaid,
            pickupAddress: "Court Zero Padel, Borrowdale",
            pickupArea: "Borrowdale",
            dropoffAddress: "Event setup desk, Newlands",
            dropoffArea: "Newlands",
            customerName: "Spotly Ops",
            maskedPhone: "+263 77 *** 0000",
            items: [DeliveryItem(id: "item-event-pack", name: "Vendor support pack", quantity: "x1", notes: nil, isFound: true, isUnavailable: false, substitution: nil, price: nil)],
            substitutionsAllowed: false,
            pickupCode: nil,
            customerPIN: nil,
            orderNumber: "EVT-10440",
            distanceKM: 5.0,
            estimatedDurationMinutes: 20,
            pickupTimeWindow: "Cancelled by ops",
            earnings: 0,
            tip: 0,
            status: .cancelled,
            createdAt: hoursAgo(9),
            notes: "Vendor delivery support cancelled before pickup."
        ),
        DeliveryJob(
            id: "job-x002",
            orderID: "ORD-10438",
            businessID: "biz-customer-unavailable",
            businessName: "Customer unavailable",
            businessCategory: "Support Case",
            jobType: .preparedFoodPickup,
            fulfillmentMode: .merchantPrepared,
            pickupRequirement: .confirmOrderNumber,
            dropoffRequirement: .handToCustomer,
            paymentHandling: .prepaid,
            pickupAddress: "Chicken Inn, Avondale",
            pickupArea: "Avondale",
            dropoffAddress: "Customer address, Mabelreign",
            dropoffArea: "Mabelreign",
            customerName: "Unavailable customer",
            maskedPhone: "+263 77 *** 0188",
            items: [DeliveryItem(id: "item-unavailable-order", name: "Prepared food order", quantity: "x1", notes: nil, isFound: true, isUnavailable: false, substitution: nil, price: nil)],
            substitutionsAllowed: false,
            pickupCode: nil,
            customerPIN: nil,
            orderNumber: "SPT-10338",
            distanceKM: 5.7,
            estimatedDurationMinutes: 24,
            pickupTimeWindow: "Failed at drop-off",
            earnings: 0,
            tip: 0,
            status: .failed,
            createdAt: hoursAgo(11),
            notes: "Customer unavailable after support wait time."
        )
    ]

    static let earningsSummary = DriverEarningsSummary(
        todayEarnings: 13.00,
        weeklyEarnings: 68.25,
        completedToday: 3,
        acceptanceRate: 0.91,
        onlineHours: 4.5,
        pendingPayout: 68.25
    )

    static var walletTransactions: [WalletTransaction] {
        [
            WalletTransaction(id: "txn-001", type: .deliveryCompleted, amount: 4.50, relatedJobID: "job-c001", createdAt: hoursAgo(3), status: "Pending payout", notes: "Base fare for completed restaurant delivery."),
            WalletTransaction(id: "txn-002", type: .tipReceived, amount: 0.50, relatedJobID: "job-c002", createdAt: hoursAgo(5), status: "Pending payout", notes: "Customer tip added after delivery."),
            WalletTransaction(id: "txn-003", type: .cashCollected, amount: 18.40, relatedJobID: "job-005", createdAt: hoursAgo(6), status: "Recorded", notes: "Operational cash amount, not driver earnings."),
            WalletTransaction(id: "txn-004", type: .payoutPending, amount: 68.25, relatedJobID: nil, createdAt: hoursAgo(8), status: "Pending", notes: "Weekly payout will be enabled for verified accounts.")
        ]
    }

    static func dispatchRequests(for jobs: [DeliveryJob]) -> [DispatchRequest] {
        jobs.enumerated().map { index, job in
            DispatchRequest(
                id: "dispatch-\(job.id)",
                jobID: job.id,
                receivedAt: minutesAgo(index + 1),
                expiresAt: Calendar.current.date(byAdding: .minute, value: 10 - min(index, 5), to: Date()),
                priority: job.totalEarnings >= 5.5 || job.jobType == .pharmacyVerifiedPickup ? .high : .normal,
                recommendationReason: job.recommendationReason,
                status: .pending
            )
        }
    }

    static let notifications: [DriverNotification] = [
        DriverNotification(id: "notif-001", title: "New delivery request", message: "Spar Avondale shop & deliver request is available.", type: .newJobRequest, createdAt: minutesAgo(1), isRead: false, relatedJobID: "job-002"),
        DriverNotification(id: "notif-002", title: "Pickup code ready", message: "Booties Pharmacy requires pickup code RX-6021.", type: .pickupCodeReady, createdAt: minutesAgo(5), isRead: false, relatedJobID: "job-004"),
        DriverNotification(id: "notif-003", title: "Customer note updated", message: "Petal & Bow: keep upright and avoid direct sun.", type: .customerNoteUpdated, createdAt: minutesAgo(12), isRead: true, relatedJobID: "job-003"),
        DriverNotification(id: "notif-007", title: "Cash collection reminder", message: "Nando's Borrowdale requires USD18.40 cash collection.", type: .cashCollectionReminder, createdAt: minutesAgo(18), isRead: true, relatedJobID: "job-005"),
        DriverNotification(id: "notif-004", title: "Payout pending", message: "USD 68.25 is pending payout. Setup options arrive before launch.", type: .payoutUpdate, createdAt: hoursAgo(28), isRead: true, relatedJobID: nil),
        DriverNotification(id: "notif-005", title: "Verification pending", message: "Driver verification will be reviewed by the Spotly operations team before launch.", type: .verificationUpdate, createdAt: hoursAgo(32), isRead: true, relatedJobID: nil),
        DriverNotification(id: "notif-006", title: "Safety reminder", message: "For emergencies, contact local emergency services first.", type: .safetyReminder, createdAt: hoursAgo(48), isRead: true, relatedJobID: nil),
        DriverNotification(id: "notif-008", title: "Shift summary", message: "Your current shift summary appears in Earnings.", type: .shiftSummary, createdAt: hoursAgo(2), isRead: true, relatedJobID: nil)
    ]

    private static func completedJob(id: String, orderID: String, businessID: String, name: String, category: String, pickup: String, dropoff: String, items: String, earnings: Double, tip: Double, hoursAgo hour: Int) -> DeliveryJob {
        DeliveryJob(
            id: id,
            orderID: orderID,
            businessID: businessID,
            businessName: name,
            businessCategory: category,
            jobType: category.lowercased().contains("grocery") ? .groceryShopAndDeliver : .preparedFoodPickup,
            fulfillmentMode: category.lowercased().contains("grocery") ? .driverShop : .merchantPrepared,
            pickupRequirement: category.lowercased().contains("grocery") ? .uploadReceiptPlaceholder : .confirmOrderNumber,
            dropoffRequirement: .meetCustomer,
            paymentHandling: .prepaid,
            pickupAddress: "\(name), \(pickup)",
            pickupArea: pickup,
            dropoffAddress: "Customer address, \(dropoff)",
            dropoffArea: dropoff,
            customerName: "Spotly Customer",
            maskedPhone: "+263 77 *** 1122",
            items: [DeliveryItem(id: "\(id)-item", name: items, quantity: "x1", notes: nil, isFound: true, isUnavailable: false, substitution: nil, price: nil)],
            substitutionsAllowed: false,
            pickupCode: nil,
            customerPIN: nil,
            orderNumber: orderID,
            distanceKM: 3.8,
            estimatedDurationMinutes: 16,
            pickupTimeWindow: "Completed",
            earnings: earnings,
            tip: tip,
            status: .delivered,
            createdAt: DriverMockData.hoursAgo(hour),
            acceptedAt: DriverMockData.hoursAgo(hour),
            completedAt: DriverMockData.minutesAgo(hour * 60 - 20)
        )
    }
}
