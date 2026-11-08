import SwiftUI

struct DriverBottomActionBar<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
                .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                .padding(.vertical, SpotlyDriverSpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .background(SpotlyDriverColors.background.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) { Divider().background(SpotlyDriverColors.divider) }
    }
}
