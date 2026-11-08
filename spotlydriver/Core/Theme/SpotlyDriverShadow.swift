import SwiftUI

struct SpotlyDriverShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let card = SpotlyDriverShadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    static let elevated = SpotlyDriverShadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    static let hero = SpotlyDriverShadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 4)
    static let subtle = SpotlyDriverShadow(color: .black.opacity(0.035), radius: 5, x: 0, y: 1)
}

extension View {
    func driverCardShadow() -> some View {
        shadow(color: SpotlyDriverShadow.card.color,
               radius: SpotlyDriverShadow.card.radius,
               x: SpotlyDriverShadow.card.x,
               y: SpotlyDriverShadow.card.y)
    }

    func driverElevatedShadow() -> some View {
        shadow(color: SpotlyDriverShadow.elevated.color,
               radius: SpotlyDriverShadow.elevated.radius,
               x: SpotlyDriverShadow.elevated.x,
               y: SpotlyDriverShadow.elevated.y)
    }

    func spotlyCardShell(radius: CGFloat = SpotlyDriverRadius.card, shadow: SpotlyDriverShadow? = .card) -> some View {
        background(SpotlyDriverColors.cardBackground)
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(SpotlyDriverColors.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .modifier(SpotlyOptionalShadow(shadow: shadow))
    }
}

private struct SpotlyOptionalShadow: ViewModifier {
    let shadow: SpotlyDriverShadow?

    func body(content: Content) -> some View {
        if let shadow {
            content.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
        } else {
            content
        }
    }
}

typealias SpotlyShadow = SpotlyDriverShadow
