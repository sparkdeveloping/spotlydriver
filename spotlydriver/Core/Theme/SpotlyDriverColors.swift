import SwiftUI

private extension Color {
    init(light: String, dark: String) {
        self.init(UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(hex: String) {
        var value = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if value.count == 3 {
            value = value.map { "\($0)\($0)" }.joined()
        }
        var int: UInt64 = 0
        Scanner(string: value).scanHexInt64(&int)
        let red = CGFloat((int >> 16) & 0xFF) / 255
        let green = CGFloat((int >> 8) & 0xFF) / 255
        let blue = CGFloat(int & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

enum SpotlyDriverColors {
    static let accent = Color(light: "#2563EB", dark: "#60A5FA")
    static let accentStrong = Color(light: "#1D4ED8", dark: "#93C5FD")
    static let accentSoft = Color(light: "#EAF1FF", dark: "#172B4D")
    static let accentMuted = Color(light: "#F4F7FF", dark: "#111F37")
    static let textOnAccent = Color.white

    static let primary = accent
    static let primaryDark = accentStrong
    static let primaryLight = accentSoft
    static let primaryMuted = accentMuted
    static let textOnPrimary = textOnAccent

    static let background = Color(light: "#FFFFFF", dark: "#0B0F14")
    static let groupedBackground = Color(light: "#F7F8FA", dark: "#111827")
    static let secondaryBackground = Color(light: "#F3F4F6", dark: "#1F2937")
    static let surface = Color(light: "#FFFFFF", dark: "#151C27")
    static let elevatedSurface = Color(light: "#FFFFFF", dark: "#1B2430")
    static let cardBackground = surface

    static let label = Color(light: "#111827", dark: "#F9FAFB")
    static let textPrimary = label
    static let secondaryLabel = Color(light: "#6B7280", dark: "#D1D5DB")
    static let textSecondary = secondaryLabel
    static let tertiaryLabel = Color(light: "#9CA3AF", dark: "#9CA3AF")
    static let textTertiary = tertiaryLabel
    static let placeholder = Color(light: "#9CA3AF", dark: "#9CA3AF")
    static let disabled = Color(light: "#C7CBD1", dark: "#4B5563")

    static let separator = Color(light: "#E7E9E8", dark: "#2E3744")
    static let border = Color(light: "#E5E7EB", dark: "#374151")
    static let divider = separator

    static let destructive = Color(light: "#DC2626", dark: "#F87171")
    static let destructiveSoft = Color(light: "#FEE2E2", dark: "#3F1717")
    static let warning = Color(light: "#F59E0B", dark: "#FBBF24")
    static let warningSoft = Color(light: "#FEF3C7", dark: "#3A2B0B")
    static let info = Color(light: "#2563EB", dark: "#60A5FA")
    static let infoSoft = Color(light: "#DBEAFE", dark: "#172B4D")
    static let success = Color(light: "#16A34A", dark: "#4ADE80")
    static let successSoft = Color(light: "#DCFCE7", dark: "#12351E")
    static let neutralSoft = secondaryBackground

    static let statusOnline = success
    static let statusOffline = destructive
    static let statusBusy = warning

    static let cardShadow = Color.black.opacity(0.05)
    static let offerCardBackground = surface
    static let offerCardText = label
}

typealias SpotlyColors = SpotlyDriverColors
typealias SpotlyDriverPalette = SpotlyDriverColors
