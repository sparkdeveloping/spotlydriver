import SwiftUI

struct ContentView: View {
    @StateObject private var appState = DriverAppState()

    var body: some View {
        Group {
            switch appState.authState {
            case .splash:
                DriverSplashView()
            case .welcome:
                DriverWelcomeView()
            case .signIn:
                DriverSignInView()
            case .onboarding:
                DriverOnboardingView()
            case .main:
                DriverMainTabView()
            }
        }
        .environmentObject(appState)
        .tint(SpotlyDriverColors.accent)
    }
}

struct DriverMainTabView: View {
    @EnvironmentObject var appState: DriverAppState
    @State private var showActiveJob = false
    @State private var showEndShiftConfirmation = false

    var body: some View {
        tabContent
            .driverTabBottomAccessory(isEnabled: shouldShowAvailabilityAccessory) {
                availabilityAccessory
            }
            .fullScreenCover(isPresented: $showActiveJob) {
                if let job = appState.activeJob {
                    ActiveJobView(jobID: job.id)
                        .environmentObject(appState)
                }
            }
            .alert("End shift?", isPresented: $showEndShiftConfirmation) {
                Button("End Shift", role: .destructive) {
                    appState.goOffline()
                }
                Button("Stay Online", role: .cancel) {}
            } message: {
                Text("You completed \(appState.currentShift?.completedJobs ?? 0) deliveries and earned \(DriverFormatters.price(appState.currentShift?.totalEarnings ?? 0)) on this shift.")
            }
    }

    private var tabContent: some View {
        TabView(selection: $appState.selectedTab) {
            Tab("Home", systemImage: "house", value: DriverTab.home) {
                DriverHomeView()
                    .environmentObject(appState)
            }

            Tab("Jobs", systemImage: "shippingbox", value: DriverTab.jobs) {
                JobsView()
                    .environmentObject(appState)
            }
            .badge(appState.pendingDispatchRequests.count)

            Tab("Earnings", systemImage: "dollarsign.circle", value: DriverTab.earnings) {
                EarningsView()
                    .environmentObject(appState)
            }

            Tab("Profile", systemImage: "person", value: DriverTab.profile) {
                DriverProfileView()
                    .environmentObject(appState)
            }
        }
        .tint(SpotlyDriverColors.accent)
        .background(SpotlyDriverColors.groupedBackground.ignoresSafeArea())
    }

    private var shouldShowAvailabilityAccessory: Bool {
        appState.selectedTab == .home || appState.availability == .onJob
    }

    @ViewBuilder
    private var availabilityAccessory: some View {
        switch appState.availability {
        case .offline:
            DriverButton(title: "Go Online", style: .primary, icon: "power") {
                withAnimation(SpotlyDriverMotion.spring) {
                    appState.goOnline()
                }
            }
        case .verificationRequired, .zoneUnavailable:
            DriverButton(
                title: appState.availability == .zoneUnavailable ? "Change Zone" : "Open Verification",
                style: .primary,
                icon: appState.availability == .zoneUnavailable ? "map.fill" : "checkmark.shield.fill"
            ) {
                if appState.availability == .zoneUnavailable {
                    appState.homeNavPath.append(DriverRoute.deliveryZones)
                } else {
                    appState.homeNavPath.append(DriverRoute.profileDestination(.documents))
                }
                appState.selectedTab = .home
            }
        case .online:
            HStack(spacing: SpotlyDriverSpacing.sm) {
                DriverButton(title: "Pause Requests", style: .secondary, height: SpotlyDriverSpacing.compactButtonHeight) {
                    appState.pauseRequests()
                }
                DriverButton(title: "Go Offline", style: .destructive, height: SpotlyDriverSpacing.compactButtonHeight) {
                    if (appState.currentShift?.completedJobs ?? 0) > 0 {
                        showEndShiftConfirmation = true
                    } else {
                        withAnimation(SpotlyDriverMotion.spring) {
                            appState.goOffline()
                        }
                    }
                }
            }
        case .paused:
            HStack(spacing: SpotlyDriverSpacing.sm) {
                DriverButton(title: "Resume", style: .primary, height: SpotlyDriverSpacing.compactButtonHeight) {
                    appState.resumeRequests()
                }
                DriverButton(title: "Go Offline", style: .destructive, height: SpotlyDriverSpacing.compactButtonHeight) {
                    if (appState.currentShift?.completedJobs ?? 0) > 0 {
                        showEndShiftConfirmation = true
                    } else {
                        withAnimation(SpotlyDriverMotion.spring) {
                            appState.goOffline()
                        }
                    }
                }
            }
        case .onJob:
            DriverButton(title: "Continue Delivery", style: .primary, icon: "arrow.right.circle.fill") {
                showActiveJob = true
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func driverTabBottomAccessory<Accessory: View>(isEnabled: Bool, @ViewBuilder content: @escaping () -> Accessory) -> some View {
        if #available(iOS 26.0, *) {
            self.tabViewBottomAccessory(isEnabled: isEnabled) {
                content()
                    .padding(.horizontal, SpotlyDriverSpacing.screenEdge)
                    .padding(.vertical, SpotlyDriverSpacing.xs)
                    .background(SpotlyDriverColors.background)
            }
        } else {
            self.safeAreaInset(edge: .bottom) {
                if isEnabled {
                    DriverBottomActionBar {
                        content()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
