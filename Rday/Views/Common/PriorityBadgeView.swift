import SwiftUI

struct PriorityBadgeView: View {
    let priority: TodoPriority

    var body: some View {
        if priority != .none {
            Text(priority.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(backgroundColor.opacity(0.15))
                .foregroundColor(backgroundColor)
                .clipShape(Capsule())
        }
    }

    private var backgroundColor: Color {
        switch priority {
        case .none: return .gray
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}
