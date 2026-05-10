import SwiftUI

enum DesignSystem {
    enum Color {
        static let futureCountdown = SwiftUI.Color(hex: "007AFF")
        static let today = SwiftUI.Color(hex: "FF9500")
        static let past = SwiftUI.Color(hex: "8E8E93")
        static let memorial = SwiftUI.Color(hex: "34C759")

        static let categoryAnniversary = SwiftUI.Color(hex: "FF6B6B")
        static let categoryWork = SwiftUI.Color(hex: "4A90D9")
        static let categoryLife = SwiftUI.Color(hex: "50C878")
        static let categoryCustom = SwiftUI.Color(hex: "9B59B6")

        struct GradientPreset {
            let name: String
            let start: String
            let end: String

            var gradient: LinearGradient {
                LinearGradient(
                    colors: [SwiftUI.Color(hex: start), SwiftUI.Color(hex: end)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }

        static let gradientPresets: [GradientPreset] = [
            GradientPreset(name: "海洋蓝", start: "4A90D9", end: "357ABD"),
            GradientPreset(name: "日落橙", start: "FF6B35", end: "F7931E"),
            GradientPreset(name: "翡翠绿", start: "2ECC71", end: "27AE60"),
            GradientPreset(name: "皇家紫", start: "9B59B6", end: "8E44AD"),
            GradientPreset(name: "玫瑰红", start: "E74C3C", end: "C0392B"),
            GradientPreset(name: "海洋青", start: "1ABC9C", end: "16A085"),
            GradientPreset(name: "暗夜", start: "2C3E50", end: "34495E"),
            GradientPreset(name: "金色", start: "F39C12", end: "E67E22"),
        ]
    }

    enum Typography {
        static let cardLargeNumber: Font = .system(size: 56, weight: .bold, design: .rounded)
        static let cardLargeSuffix: Font = .system(size: 18, weight: .semibold, design: .rounded)
        static let cardTitle: Font = .system(size: 20, weight: .semibold)
        static let cardDate: Font = .system(size: 13, weight: .regular)
        static let categoryLabel: Font = .system(size: 11, weight: .medium)
    }

    enum Layout {
        static let cardCornerRadius: CGFloat = 16
        static let cardHeight: CGFloat = 200
        static let cardPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 12
        static let cardHorizontalPadding: CGFloat = 16
    }
}
