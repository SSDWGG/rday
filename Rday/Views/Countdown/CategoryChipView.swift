import SwiftUI

struct CategoryChipView: View {
    let category: EventCategory

    var body: some View {
        if category != .none {
            Text(category.displayName)
                .font(DesignSystem.Typography.categoryLabel)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(0.25))
                .clipShape(Capsule())
        }
    }
}
