import SwiftUI

enum SpotlyLayout {
    static let rootTabContentInset: CGFloat = 0
}

enum SpotlyDriverCardVariant {
    case sectionSurface, standard, operational, metric, elevated, hero, warning, compact

    var radius: CGFloat {
        switch self {
        case .hero: return SpotlyDriverRadius.heroCard
        default: return SpotlyDriverRadius.card
        }
    }

    var padding: CGFloat {
        switch self {
        case .compact: return SpotlyDriverSpacing.sm
        default: return SpotlyDriverSpacing.cardPadding
        }
    }

    var shadow: SpotlyDriverShadow? {
        switch self {
        case .sectionSurface: return nil
        case .elevated, .metric, .operational: return .elevated
        case .hero: return .hero
        default: return .card
        }
    }
}

struct SpotlyRootScreen<Content: View>: View {
    var background: Color = SpotlyDriverColors.groupedBackground
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            content()
        }
    }
}

struct SpotlyScrollableScreen<Content: View>: View {
    var bottomPadding: CGFloat = SpotlyDriverSpacing.bottomSafePadding
    var showsIndicators = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        SpotlyRootScreen {
            ScrollView(showsIndicators: showsIndicators) {
                VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sectionSpacing) {
                    content()
                }
                .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                .padding(.top, SpotlyDriverSpacing.md)
                .padding(.bottom, bottomPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollContentBackground(.hidden)
            .background(SpotlyDriverColors.groupedBackground)
        }
    }
}

struct SpotlyDriverCard<Content: View>: View {
    var variant: SpotlyDriverCardVariant = .standard
    @ViewBuilder let content: () -> Content

    var body: some View {
        cardBody
            .modifier(SpotlyCardShadowModifier(shadow: variant.shadow))
    }

    private var cardBody: some View {
        content()
            .padding(variant.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SpotlyDriverColors.cardBackground)
            .overlay(RoundedRectangle(cornerRadius: variant.radius).stroke(SpotlyDriverColors.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: variant.radius))
    }
}

private struct SpotlyCardShadowModifier: ViewModifier {
    let shadow: SpotlyDriverShadow?

    func body(content: Content) -> some View {
        if let shadow {
            content.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
        } else {
            content
        }
    }
}

struct SpotlyPageHeader<Trailing: View>: View {
    enum Variant { case greeting, large, compact, operational }

    let title: String
    var subtitle: String? = nil
    var location: String? = nil
    var status: String? = nil
    var avatarInitials: String? = nil
    var variant: Variant = .large
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            HStack(alignment: .center, spacing: SpotlyDriverSpacing.sm) {
                VStack(alignment: .leading, spacing: SpotlyDriverSpacing.xs) {
                    if let location {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text(location)
                                .font(SpotlyDriverTypography.caption1.weight(.semibold))
                                .lineLimit(1)
                        }
                        .foregroundStyle(SpotlyDriverColors.accent)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(SpotlyDriverColors.accentMuted)
                        .clipShape(Capsule())
                    }

                    Text(title)
                        .font(titleFont)
                        .foregroundStyle(SpotlyDriverColors.label)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .accessibilityAddTraits(.isHeader)

                    if let subtitle {
                        Text(subtitle)
                            .font(SpotlyDriverTypography.subheadline)
                            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let status {
                        Text(status)
                            .font(SpotlyDriverTypography.caption2)
                            .foregroundStyle(SpotlyDriverColors.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(SpotlyDriverColors.accentSoft)
                            .clipShape(Capsule())
                    }
                }

                Spacer(minLength: SpotlyDriverSpacing.sm)

                HStack(spacing: SpotlyDriverSpacing.xs) {
                    trailing()
                    if let avatarInitials {
                        Text(avatarInitials)
                            .font(SpotlyDriverTypography.headline)
                            .foregroundStyle(SpotlyDriverColors.accent)
                            .frame(width: 52, height: 52)
                            .background(SpotlyDriverColors.accentSoft)
                            .clipShape(Circle())
                            .accessibilityLabel("Driver avatar, \(avatarInitials)")
                    }
                }
            }
        }
    }

    private var titleFont: Font {
        switch variant {
        case .greeting, .compact, .operational: return SpotlyDriverTypography.title1
        case .large: return SpotlyDriverTypography.largeTitle
        }
    }
}

extension SpotlyPageHeader where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, location: String? = nil, status: String? = nil, avatarInitials: String? = nil, variant: Variant = .large) {
        self.title = title
        self.subtitle = subtitle
        self.location = location
        self.status = status
        self.avatarInitials = avatarInitials
        self.variant = variant
        self.trailing = { EmptyView() }
    }
}

struct SpotlyIconButton: View {
    let icon: String
    var tint: Color = SpotlyDriverColors.label
    var background: Color = SpotlyDriverColors.cardBackground
    var badge: Int = 0
    let action: () -> Void

    var body: some View {
        Button {
            DriverHaptics.light()
            action()
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(background)
                    .overlay(RoundedRectangle(cornerRadius: SpotlyDriverRadius.md).stroke(SpotlyDriverColors.border, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.md))
                if badge > 0 {
                    Text(badge > 9 ? "9+" : "\(badge)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(SpotlyDriverColors.destructive)
                        .clipShape(Capsule())
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(icon == "bell.fill" ? "Notifications, \(badge) unread" : icon)
    }
}

struct SpotlyListSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: SpotlyDriverSpacing.sm) {
            Text(title)
                .font(SpotlyDriverTypography.headline)
                .foregroundStyle(SpotlyDriverColors.label)
            VStack(spacing: 0) { content() }
                .background(SpotlyDriverColors.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card).stroke(SpotlyDriverColors.border, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.card))
        }
    }
}

struct SpotlyListRow: View {
    let title: String
    var subtitle: String? = nil
    let icon: String
    var tint: Color = SpotlyDriverColors.accent
    var showChevron = true
    var isDestructive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SpotlyDriverSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 40, height: 40)
                    .background(tint.opacity(0.11))
                    .clipShape(RoundedRectangle(cornerRadius: SpotlyDriverRadius.sm))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(SpotlyDriverTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(isDestructive ? SpotlyDriverColors.destructive : SpotlyDriverColors.label)
                    if let subtitle {
                        Text(subtitle)
                            .font(SpotlyDriverTypography.caption1)
                            .foregroundStyle(SpotlyDriverColors.secondaryLabel)
                    }
                }
                Spacer(minLength: SpotlyDriverSpacing.sm)
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(SpotlyDriverColors.tertiaryLabel)
                }
            }
            .padding(.horizontal, SpotlyDriverSpacing.md)
            .padding(.vertical, 10)
            .frame(minHeight: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
