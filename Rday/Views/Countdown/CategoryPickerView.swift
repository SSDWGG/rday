import SwiftUI

struct CategoryPickerView: View {
    @Binding var selection: EventCategory

    var body: some View {
        HStack(spacing: 10) {
            ForEach(EventCategory.allCases) { category in
                Button {
                    selection = category
                } label: {
                    Text(category.displayName)
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            selection == category
                                ? categoryColor(category)
                                : Color(.systemGray5)
                        )
                        .foregroundColor(
                            selection == category ? .white : .primary
                        )
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func categoryColor(_ category: EventCategory) -> Color {
        switch category {
        case .none: return Color(hex: "6C63FF")
        case .anniversary: return DesignSystem.Color.categoryAnniversary
        case .work: return DesignSystem.Color.categoryWork
        case .life: return DesignSystem.Color.categoryLife
        case .custom: return DesignSystem.Color.categoryCustom
        }
    }
}
