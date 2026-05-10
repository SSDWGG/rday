import SwiftUI
import SwiftData

@MainActor
@Observable
final class TodoFormViewModel {
    var title: String = ""
    var note: String = ""
    var hasDueDate: Bool = false
    var dueDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var priority: TodoPriority = .none
    var isRecurringDaily: Bool = false

    var isPushEnabled: Bool = false
    var pushTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

    var isEmailEnabled: Bool = false
    var emailTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

    var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canSave: Bool { isTitleValid }
    var isEditing: Bool { editingTodo != nil }
    var navigationTitle: String { isEditing ? "编辑待办" : "新建待办" }

    private var editingTodo: TodoItem?
    private let modelContext: ModelContext
    private let notificationService = NotificationService.shared

    init(modelContext: ModelContext, todo: TodoItem? = nil) {
        self.modelContext = modelContext
        self.editingTodo = todo

        if let todo {
            title = todo.title
            note = todo.note ?? ""
            if let due = todo.dueDate {
                hasDueDate = true
                dueDate = due
            }
            priority = todo.priority
            isRecurringDaily = todo.isRecurringDaily

            for reminder in todo.reminders ?? [] {
                switch reminder.type {
                case .push:
                    isPushEnabled = true
                    if let time = reminder.remindAtTime { pushTime = time }
                case .email:
                    isEmailEnabled = true
                    if let time = reminder.remindAtTime { emailTime = time }
                }
            }
        }
    }

    func save() -> Bool {
        guard canSave else { return false }

        // Check if push time is in the past for non-recurring todos
        if isPushEnabled && !isRecurringDaily && hasDueDate {
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: pushTime)
            let triggerDate = calendar.date(
                bySettingHour: timeComponents.hour ?? 9,
                minute: timeComponents.minute ?? 0,
                second: 0,
                of: dueDate
            ) ?? dueDate
            if triggerDate < Date() {
                return false
            }
        }

        let todo: TodoItem

        if let existing = editingTodo {
            todo = existing
            notificationService.cancelAllReminders(for: todo.id)
            if let existingReminders = todo.reminders {
                for reminder in existingReminders {
                    modelContext.delete(reminder)
                }
            }
            todo.reminders = []
        } else {
            todo = TodoItem(title: title.trimmingCharacters(in: .whitespaces))
            modelContext.insert(todo)
        }

        todo.title = title.trimmingCharacters(in: .whitespaces)
        todo.note = note.isEmpty ? nil : note
        todo.dueDate = hasDueDate ? dueDate : nil
        todo.priority = priority
        todo.isRecurringDaily = isRecurringDaily

        scheduleReminders(for: todo)
        try? modelContext.save()
        return true
    }

    private func scheduleReminders(for todo: TodoItem) {
        let calendar = Calendar.current

        if isPushEnabled {
            let reminder = TodoReminder(type: .push, remindAtTime: pushTime)
            if todo.reminders == nil { todo.reminders = [] }
            todo.reminders?.append(reminder)

            if isRecurringDaily {
                notificationService.scheduleDailyPushReminder(
                    for: todo.id,
                    title: todo.title,
                    body: todo.note,
                    atTime: pushTime
                )
            } else if hasDueDate {
                let timeComponents = calendar.dateComponents([.hour, .minute], from: pushTime)
                let triggerDate = calendar.date(
                    bySettingHour: timeComponents.hour ?? 9,
                    minute: timeComponents.minute ?? 0,
                    second: 0,
                    of: dueDate
                ) ?? dueDate
                notificationService.schedulePushReminder(
                    for: todo.id,
                    title: todo.title,
                    body: todo.note,
                    at: triggerDate
                )
            }
        }

        if isEmailEnabled {
            let reminder = TodoReminder(type: .email, remindAtTime: emailTime)
            if todo.reminders == nil { todo.reminders = [] }
            todo.reminders?.append(reminder)

            if isRecurringDaily {
                // For daily recurring, schedule a daily notification that opens mail compose
                notificationService.scheduleDailyPushReminder(
                    for: todo.id,
                    title: todo.title,
                    body: todo.note,
                    atTime: emailTime
                )
            } else if hasDueDate {
                let timeComponents = calendar.dateComponents([.hour, .minute], from: emailTime)
                let triggerDate = calendar.date(
                    bySettingHour: timeComponents.hour ?? 9,
                    minute: timeComponents.minute ?? 0,
                    second: 0,
                    of: dueDate
                ) ?? dueDate
                notificationService.scheduleEmailReminder(
                    for: todo.id,
                    title: todo.title,
                    body: todo.note,
                    at: triggerDate
                )
            }
        }
    }

    func delete() {
        guard let todo = editingTodo else { return }
        notificationService.cancelAllReminders(for: todo.id)
        modelContext.delete(todo)
        try? modelContext.save()
    }
}
