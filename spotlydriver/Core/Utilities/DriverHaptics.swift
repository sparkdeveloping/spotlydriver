import UIKit

enum DriverHaptics {
    static func light() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }

    static func medium() {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
    }

    static func heavy() {
        let gen = UIImpactFeedbackGenerator(style: .heavy)
        gen.impactOccurred()
    }

    static func success() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
    }

    static func warning() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.warning)
    }

    static func error() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.error)
    }

    static func selection() {
        let gen = UISelectionFeedbackGenerator()
        gen.selectionChanged()
    }
}
