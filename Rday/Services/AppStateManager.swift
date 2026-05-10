import SwiftUI
import SwiftData

@Observable
final class AppStateManager {
    var pendingEmailTodoId: UUID?

    func handleDidBecomeActive(modelContext: ModelContext) {
        resetDailyRecurringTodos(modelContext: modelContext)
    }

    private func resetDailyRecurringTodos(modelContext: ModelContext) {
        let todayStart = Calendar.current.startOfDay(for: Date())

        let fetchDescriptor = FetchDescriptor<TodoItem>(
            predicate: #Predicate { todo in
                todo.isRecurringDaily && todo.isCompleted
            }
        )

        guard let todos = try? modelContext.fetch(fetchDescriptor) else { return }

        var didChange = false
        for todo in todos {
            guard let lastCompleted = todo.lastCompletedDate else { continue }
            if Calendar.current.startOfDay(for: lastCompleted) < todayStart {
                todo.isCompleted = false
                todo.lastCompletedDate = nil
                didChange = true
            }
        }

        if didChange {
            try? modelContext.save()
        }
    }
}
