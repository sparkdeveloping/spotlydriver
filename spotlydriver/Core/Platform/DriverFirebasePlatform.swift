import Foundation
import FirebaseDatabase
import FirebaseFunctions

struct DriverPlatformFoundationStatus: Equatable, Sendable {
    let projectID: String
    let functionsRegion: String
    let contractVersion: String
    let contractSHA256: String
    let countryContractVersion: String
    let countryContractSHA256: String
}

@MainActor
enum DriverFirebasePlatform {
    static let functionsRegion = "europe-west1"
    static let databaseURL = "https://spotly-africa-default-rtdb.europe-west1.firebasedatabase.app"

    private static var functionsEmulatorConnected = false
    private static var databaseEmulatorConnected = false

    static func functions() -> Functions {
        DriverFirebaseBootstrap.configureIfPossible()
        let instance = Functions.functions(region: functionsRegion)
        if useEmulators && !functionsEmulatorConnected {
            instance.useEmulator(withHost: emulatorHost, port: 5001)
            functionsEmulatorConnected = true
        }
        return instance
    }

    static func realtimeDatabase() -> Database {
        DriverFirebaseBootstrap.configureIfPossible()
        let instance = Database.database(url: databaseURL)
        if useEmulators && !databaseEmulatorConnected {
            instance.useEmulator(withHost: emulatorHost, port: 9000)
            databaseEmulatorConnected = true
        }
        return instance
    }

    static func foundationStatus() async throws -> DriverPlatformFoundationStatus {
        let result = try await functions().httpsCallable("platformFoundation").call()
        guard let envelope = result.data as? [String: Any], envelope["ok"] as? Bool == true,
              let data = envelope["data"] as? [String: Any],
              let projectID = data["projectId"] as? String,
              let region = data["functionsRegion"] as? String,
              let contractVersion = data["contractVersion"] as? String,
              let contractSHA256 = data["contractSHA256"] as? String,
              let countryContractVersion = data["countryContractVersion"] as? String,
              let countryContractSHA256 = data["countryContractSHA256"] as? String else {
            throw NSError(domain: "SpotlyDriverFirebasePlatform", code: 1, userInfo: [NSLocalizedDescriptionKey: "Spotly Driver could not verify the Firebase platform foundation."])
        }
        guard projectID == DriverFirebaseBootstrap.projectID,
              region == functionsRegion,
              contractVersion == SpotlyContractMetadata.version,
              contractSHA256 == SpotlyContractMetadata.manifestSHA256,
              countryContractVersion == SpotlyCountryContractMetadata.version,
              countryContractSHA256 == SpotlyCountryContractMetadata.manifestSHA256 else {
            throw NSError(domain: "SpotlyDriverFirebasePlatform", code: 2, userInfo: [NSLocalizedDescriptionKey: "This Spotly Driver build and Firebase platform are not compatible."])
        }
        return DriverPlatformFoundationStatus(projectID: projectID, functionsRegion: region, contractVersion: contractVersion, contractSHA256: contractSHA256, countryContractVersion: countryContractVersion, countryContractSHA256: countryContractSHA256)
    }

    private static var useEmulators: Bool {
        ProcessInfo.processInfo.environment["SPOTLY_FIREBASE_USE_EMULATORS"] == "1"
    }

    private static var emulatorHost: String {
        ProcessInfo.processInfo.environment["SPOTLY_FIREBASE_EMULATOR_HOST"] ?? "127.0.0.1"
    }
}
