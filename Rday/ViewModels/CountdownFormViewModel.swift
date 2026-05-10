import SwiftUI
import SwiftData

@Observable
final class CountdownFormViewModel {
    var title: String = ""
    var targetDate: Date = Date()
    var isCountdown: Bool = true
    var note: String = ""
    var category: EventCategory = .none
    var isPinned: Bool = false
    var cardPresetIndex: Int? = nil

    private var editingEvent: CountdownEvent?
    private let modelContext: ModelContext

    var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canSave: Bool { isTitleValid }
    var isEditing: Bool { editingEvent != nil }
    var navigationTitle: String { isEditing ? "编辑倒数日" : "新建倒数日" }

    init(modelContext: ModelContext, event: CountdownEvent? = nil) {
        self.modelContext = modelContext
        self.editingEvent = event

        if let event {
            title = event.title
            targetDate = event.targetDate
            isCountdown = event.isCountdown
            note = event.note ?? ""
            category = event.category
            isPinned = event.isPinned
            cardPresetIndex = event.cardPresetIndex
        }
    }

    func save() {
        guard canSave else { return }

        if let existing = editingEvent {
            existing.title = title.trimmingCharacters(in: .whitespaces)
            existing.targetDate = targetDate
            existing.isCountdown = isCountdown
            existing.note = note.isEmpty ? nil : note
            existing.category = category
            existing.isPinned = isPinned
            existing.cardPresetIndex = cardPresetIndex
        } else {
            let event = CountdownEvent(
                title: title.trimmingCharacters(in: .whitespaces),
                targetDate: targetDate,
                isCountdown: isCountdown,
                note: note.isEmpty ? nil : note,
                categoryRaw: category.rawValue,
                isPinned: isPinned,
                cardPresetIndex: cardPresetIndex
            )
            modelContext.insert(event)
        }

        try? modelContext.save()
    }

    func delete() {
        guard let event = editingEvent else { return }
        modelContext.delete(event)
        try? modelContext.save()
    }
}
