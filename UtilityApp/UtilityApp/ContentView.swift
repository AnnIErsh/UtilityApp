import SwiftUI

private enum RootRoute {
    case splash
    case main
}

struct ContentView: View {
    let container: AppContainer
    @State private var route: RootRoute = .splash

    var body: some View {
        rootContent
            .task {
                try? await Task.sleep(nanoseconds: 1_800_000_000)
                withAnimation(.easeInOut(duration: 0.3)) {
                    route = .main
                }
            }
    }

    @ViewBuilder
    private var rootContent: some View {
        switch route {
        case .splash:
            SplashView()
        case .main:
            MainTabView(locator: container.locator)
        }
    }
}
