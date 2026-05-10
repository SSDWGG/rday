import Foundation
import SwiftData

enum TodoPriority: String, Codable, CaseIterable, Identifiable {
    case none = "无"
    case low = "低"
    case medium = "中"
    case high = "高"

    var id: Self { self }

    var sortOrder: Int {
        switch self {
        case .none: return 0
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        }
    }
}

@Model
final class TodoItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var note: String?
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var priorityRaw: String
    var isRecurringDaily: Bool
    var lastCompletedDate: Date?
    var displayOrder: Int

    @Relationship(deleteRule: .cascade) var reminders: [TodoReminder]?

    var priority: TodoPriority {
        get { TodoPriority(rawValue: priorityRaw) ?? .none }
        set { priorityRaw = newValue.rawValue }
    }

    init(
        title: String,
        note: String? = nil,
        dueDate: Date? = nil,
        priority: TodoPriority = .none,
        isRecurringDaily: Bool = false,
        displayOrder: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.note = note
        self.isCompleted = false
        self.createdAt = Date()
        self.dueDate = dueDate
        self.priorityRaw = priority.rawValue
        self.isRecurringDaily = isRecurringDaily
        self.lastCompletedDate = nil
        self.displayOrder = displayOrder
        self.reminders = []
    }
}
