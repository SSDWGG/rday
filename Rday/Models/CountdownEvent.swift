import Foundation
import SwiftData

@Model
final class CountdownEvent {
    @Attribute(.unique) var id: UUID
    var title: String
    var targetDate: Date
    var isCountdown: Bool
    var note: String?
    var createdAt: Date
    var displayOrder: Int
    var categoryRaw: String = ""
    var isPinned: Bool = false
    var cardPresetIndex: Int? = nil
    var backgroundImageData: Data? = nil
    var blurRadius: Double = 0

    init(
        title: String,
        targetDate: Date,
        isCountdown: Bool = true,
        note: String? = nil,
        displayOrder: Int = 0,
        categoryRaw: String = "",
        isPinned: Bool = false,
        cardPresetIndex: Int? = nil,
        backgroundImageData: Data? = nil,
        blurRadius: Double = 0
    ) {
        self.id = UUID()
        self.title = title
        self.targetDate = targetDate
        self.isCountdown = isCountdown
        self.note = note
        self.createdAt = Date()
        self.displayOrder = displayOrder
        self.categoryRaw = categoryRaw
        self.isPinned = isPinned
        self.cardPresetIndex = cardPresetIndex
        self.backgroundImageData = backgroundImageData
        self.blurRadius = blurRadius
    }

    var category: EventCategory {
        get { EventCategory(rawValue: categoryRaw) ?? .none }
        set { categoryRaw = newValue.rawValue }
    }
}

extension CountdownEvent {
    var daysFromToday: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: startOfToday, to: startOfTarget).day ?? 0
    }

    var displayText: String {
        let days = daysFromToday
        if isCountdown {
            if days > 0 { return "\(days) 天后" }
            if days == 0 { return "就是今天!" }
            return "已过去 \(abs(days)) 天"
        } else {
            return "已 \(abs(days)) 天"
        }
    }

    var isPast: Bool {
        Calendar.current.startOfDay(for: targetDate) < Calendar.current.startOfDay(for: Date())
    }
}
