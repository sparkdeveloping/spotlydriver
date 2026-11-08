import SwiftUI

enum SpotlyDriverTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let title3 = Font.system(size: 17, weight: .semibold, design: .default)
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 13, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 12, weight: .medium, design: .default)

    static let metricLarge = Font.system(size: 36, weight: .bold, design: .default)
    static let metricMedium = Font.system(size: 30, weight: .bold, design: .default)
    static let metricStandard = metricMedium

    static let ctaLabel = Font.system(size: 16, weight: .semibold, design: .default)
    static let tabLabel = Font.system(size: 12, weight: .medium, design: .default)
}

typealias SpotlyTypography = SpotlyDriverTypography
