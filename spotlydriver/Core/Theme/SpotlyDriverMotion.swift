import SwiftUI

enum SpotlyDriverMotion {
    static let quick = Animation.easeInOut(duration: 0.18)
    static let standard = Animation.easeInOut(duration: 0.28)
    static let spring = Animation.spring(response: 0.38, dampingFraction: 0.72)
    static let springBouncy = Animation.spring(response: 0.42, dampingFraction: 0.65)
}
