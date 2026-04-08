import SwiftUI

private enum RootRoute {
    case splash
    case onboarding
    case main
}

struct ContentView: View {
    let container: AppContainer
    @State private var route: RootRoute = .splash
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        rootContent
            .dismissKeyboardOnGlobalTap()
            .task {
                try? await Task.sleep(nanoseconds: 1_800_000_000)
                withAnimation(.easeInOut(duration: 0.3)) {
                    route = hasSeenOnboarding ? .main : .onboarding
                }
            }
    }

    @ViewBuilder
    private var rootContent: some View {
        switch route {
        case .splash:
            SplashView()
        case .onboarding:
            OnboardingView {
                hasSeenOnboarding = true
                withAnimation(.easeInOut(duration: 0.25)) {
                    route = .main
                }
            }
        case .main:
            MainTabView(locator: container.locator)
        }
    }
}
