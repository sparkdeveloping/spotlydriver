import UIKit
import CoreLocation

enum DriverExternalLinks {
    static func openMapsDirections(latitude: Double, longitude: Double, label: String) {
        let urlString = "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d"
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    static func openMapsAddress(_ address: String) {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "http://maps.apple.com/?daddr=\(encoded)&dirflg=d"
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    static func callPhone(_ number: String) {
        let cleaned = number.filter { $0.isNumber || $0 == "+" }
        guard let url = URL(string: "tel://\(cleaned)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
