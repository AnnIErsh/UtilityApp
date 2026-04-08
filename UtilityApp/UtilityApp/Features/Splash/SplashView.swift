import SwiftUI

struct SplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            AppTheme.splashGradient
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "timer.circle.fill")
                    .font(.system(size: iconSize))
                    .foregroundColor(.white)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animate)

                Text("Focus Flow")
                    .font(AppTypography.hero(titleSize))
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.white)

                Text("Plan • Focus • Improve")
                    .font(.system(size: subtitleSize, weight: .semibold, design: .rounded))
                    .tracking(0.4)
                    .foregroundColor(.white.opacity(0.86))
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

    private var subtitleSize: CGFloat {
        if LayoutMetrics.isSmallDevice {
            return 12
        }
        return 13
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
