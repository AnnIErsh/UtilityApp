import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page: Int = 0

    private let items: [OnboardingItem] = [
        OnboardingItem(
            title: "Capture What Matters",
            subtitle: "Keep your priorities clear with quick task planning.",
            imageName: "onboarding1"
        ),
        OnboardingItem(
            title: "Build Better Habits",
            subtitle: "Track weekly consistency and make progress visible.",
            imageName: "onboarding2"
        ),
        OnboardingItem(
            title: "Protect Focus Time",
            subtitle: "Run focus sessions with reliable recovery and notifications.",
            imageName: "onboarding3"
        )
    ]

    var body: some View {
        GeometryReader { proxy in
            let isCompact = proxy.size.height < 760
            let contentSpacing: CGFloat = isCompact ? 14 : 20
            let cardHeight: CGFloat = proxy.size.height * (isCompact ? 0.66 : 0.7)

            ZStack {
                AppTheme.screenBackground.ignoresSafeArea()

                VStack(spacing: contentSpacing) {
                    TabView(selection: $page) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            pageCard(item, isCompact: isCompact)
                                .tag(index)
                        }
                    }
                    .frame(height: cardHeight)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .padding(.horizontal, LayoutMetrics.contentHorizontalPadding + 8)

                    indicators

                    primaryButton(isCompact: isCompact)
                }
                .padding(.top, isCompact ? 10 : 18)
                .padding(.bottom, isCompact ? 8 : 16)
            }
            .overlay(alignment: .topTrailing) {
                Button("Skip") {
                    onFinish()
                }
                .buttonStyle(.plain)
                .font(AppTypography.body(15))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.trailing, LayoutMetrics.contentHorizontalPadding + 8)
                .padding(.top, isCompact ? 18 : 26)
            }
        }
    }

    private func pageCard(_ item: OnboardingItem, isCompact: Bool) -> some View {
        GeometryReader { geo in
            let imageHeight = geo.size.height * (isCompact ? 0.74 : 0.76)

            VStack(spacing: 0) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: imageHeight)
                    .frame(maxWidth: .infinity)
                    .clipped()

                VStack(spacing: isCompact ? 6 : 8) {
                    Text(item.title)
                        .font(AppTypography.title(isCompact ? 27 : 30))
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppTheme.textPrimary)

                    Text(item.subtitle)
                        .font(AppTypography.body(isCompact ? 14 : 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }
                .padding(.horizontal, 18)
                .padding(.top, isCompact ? 12 : 14)
                .padding(.bottom, isCompact ? 12 : 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(AppTheme.card.opacity(0.96))
            }
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(AppTheme.cardStroke.opacity(0.85), lineWidth: 1.2)
            }
            .shadow(color: AppTheme.cardShadow.opacity(0.35), radius: 12, x: 0, y: 6)
        }
        .padding(.vertical, isCompact ? 0 : 4)
    }

    private var indicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<items.count, id: \.self) { index in
                Capsule()
                    .fill(index == page ? AppTheme.primary : AppTheme.textSecondary.opacity(0.25))
                    .frame(width: index == page ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: page)
            }
        }
    }

    private func primaryButton(isCompact: Bool) -> some View {
        Button {
            if page == items.count - 1 {
                onFinish()
            } else {
                page += 1
            }
        } label: {
            Text(page == items.count - 1 ? "Get Started" : "Next")
                .font(AppTypography.section(17))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .frame(height: isCompact ? 50 : 54)
        .background(
            LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(14)
        .padding(.horizontal, LayoutMetrics.contentHorizontalPadding)
    }
}

private struct OnboardingItem {
    let title: String
    let subtitle: String
    let imageName: String
}
