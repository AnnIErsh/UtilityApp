import Combine
import CoreGraphics
import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case tasks
    case focus
    case habits
    case stats

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .focus: return "Focus"
        case .habits: return "Habits"
        case .stats: return "Stats"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist"
        case .focus: return "timer"
        case .habits: return "leaf.fill"
        case .stats: return "chart.bar.fill"
        }
    }
}

struct TabIndicatorMetrics {
    let x: CGFloat
    let width: CGFloat
}

@MainActor
final class MainTabViewModel: ObservableObject {
    @Published private(set) var selectedTab: AppTab = .home
    @Published private(set) var isDraggingIndicator: Bool = false
    @Published private var dragTranslation: CGFloat = 0

    var tabs: [AppTab] {
        AppTab.allCases
    }

    func selectTab(_ tab: AppTab) {
        guard !isDraggingIndicator else { return }
        selectedTab = tab
        dragTranslation = 0
    }

    func updateDrag(translation: CGFloat) {
        isDraggingIndicator = true
        dragTranslation = translation
    }

    func endDrag(totalWidth: CGFloat, predictedTranslation: CGFloat) {
        let tabWidth = widthPerTab(totalWidth: totalWidth)
        let minX: CGFloat = 4
        let maxX = CGFloat(tabs.count - 1) * tabWidth + 4
        let predictedX = clamp(baseX(tabWidth: tabWidth) + predictedTranslation, min: minX, max: maxX)

        let index = Int(round((predictedX - 4) / tabWidth))
        let clampedIndex = max(0, min(index, tabs.count - 1))
        if let target = AppTab(rawValue: clampedIndex) {
            selectedTab = target
        }

        dragTranslation = 0
        isDraggingIndicator = false
    }

    func indicatorMetrics(totalWidth: CGFloat) -> TabIndicatorMetrics {
        let tabWidth = widthPerTab(totalWidth: totalWidth)
        let minX: CGFloat = 4
        let maxX = CGFloat(tabs.count - 1) * tabWidth + 4
        let x = clamp(baseX(tabWidth: tabWidth) + dragTranslation, min: minX, max: maxX)

        let stretch = min(abs(dragTranslation) * 0.08, 12)
        return TabIndicatorMetrics(x: x - (stretch / 2), width: tabWidth - 8 + stretch)
    }

    func isSelected(_ tab: AppTab) -> Bool {
        selectedTab == tab
    }

    func layerOpacity(for tab: AppTab) -> Double {
        isSelected(tab) ? 1 : 0
    }

    private func widthPerTab(totalWidth: CGFloat) -> CGFloat {
        totalWidth / CGFloat(tabs.count)
    }

    private func baseX(tabWidth: CGFloat) -> CGFloat {
        CGFloat(selectedTab.rawValue) * tabWidth + 4
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(value, maxValue))
    }
}
