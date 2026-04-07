import SwiftUI

enum LayoutMetrics {
    static var isSmallDevice: Bool {
        UIScreen.main.bounds.height <= 667
    }

    static var contentHorizontalPadding: CGFloat {
        isSmallDevice ? 12 : 16
    }

    static var cardCornerRadius: CGFloat {
        isSmallDevice ? 12 : 16
    }
}
