import SwiftUI

struct SplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.primary.opacity(0.95), AppTheme.accent.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "timer.circle.fill")
                    .font(.system(size: iconSize))
                    .foregroundColor(.white)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animate)

                Text("FocusFlow")
                    .font(.system(size: titleSize, weight: .bold))
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.white)

                Text("Plan • Focus • Improve")
                    .font(.subheadline)
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
            return 28
        }
        return 34
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
