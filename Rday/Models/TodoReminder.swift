import Foundation
import SwiftData

enum ReminderType: String, Codable, CaseIterable, Identifiable {
    case push
    case email

    var id: Self { self }

    var displayName: String {
        switch self {
        case .push: return "推送通知"
        case .email: return "邮件提醒"
        }
    }
}

@Model
final class TodoReminder {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var remindAtDate: Date?
    var remindAtTime: Date?
    var isSent: Bool

    var type: ReminderType {
        get { ReminderType(rawValue: typeRaw) ?? .push }
        set { typeRaw = newValue.rawValue }
    }

    init(type: ReminderType, remindAtDate: Date? = nil, remindAtTime: Date? = nil) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.remindAtDate = remindAtDate
        self.remindAtTime = remindAtTime
        self.isSent = false
    }
}
