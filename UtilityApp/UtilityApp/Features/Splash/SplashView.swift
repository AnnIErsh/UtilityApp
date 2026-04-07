import SwiftUI

struct SplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            AppTheme.splashGradient
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "timer.circle.fill")
                    .font(.system(size: iconSize))
                    .foregroundColor(.white)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animate)

                Text("FocusFlow")
                    .font(AppTypography.hero(titleSize))
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.white)

                Text("Plan • Focus • Improve")
                    .font(AppTypography.body(14))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, LayoutMetrics.contentHorizontalPadding)
        }
        .onAppear {
            animate = true
        }
    }

    private var iconSize: CGFloat {
        if LayoutMetrics.isSmallDevice {
            return 68
        }
        return 84
    }

    private var titleSize: CGFloat {
        if LayoutMetrics.isSmallDevice {
            return 30
        }
        return 36
    }

    private var iconScale: CGFloat {
        if animate {
            return 1.0
        }
        return 0.7
    }

    private var iconOpacity: Double {
        if animate {
            return 1
        }
        return 0.5
    }
}
