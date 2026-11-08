import Foundation
import FirebaseCore

@MainActor
enum DriverFirebaseBootstrap {
    static let expectedBundleID = "com.denzeltinashe.spotlydriver"
    static let projectID = "spotly-africa"
    static let googleAppID = "1:14197555543:ios:f36df313de211670c3be12"
    static let senderID = "14197555543"

    static var isReady: Bool {
        guard let options = FirebaseApp.app()?.options else { return false }
        return matches(options)
    }

    static func configureIfPossible() {
        guard FirebaseApp.app() == nil else { return }
        guard Bundle.main.bundleIdentifier == expectedBundleID else {
            diagnose("Driver bundle identifier does not match the registered Firebase app.")
            return
        }
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path),
              matches(options) else {
            diagnose("Driver GoogleService-Info.plist is missing or targets another Firebase app.")
            return
        }
        FirebaseApp.configure(options: options)
        if !isReady { diagnose("Firebase initialized with unexpected Driver options.") }
    }

    private static func matches(_ options: FirebaseOptions) -> Bool {
        options.projectID == projectID &&
        options.googleAppID == googleAppID &&
        options.gcmSenderID == senderID &&
        options.bundleID == expectedBundleID
    }

    private static func diagnose(_ message: String) {
        #if DEBUG
        print("Spotly Driver Firebase setup: \(message)")
        #endif
    }
}
