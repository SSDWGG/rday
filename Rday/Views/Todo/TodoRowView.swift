import SwiftUI

struct TodoRowView: View {
    @Environment(\.modelContext) private var modelContext
    let todo: TodoItem

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    todo.isCompleted.toggle()
                    if todo.isCompleted {
                        todo.lastCompletedDate = Date()
                    } else {
                        todo.lastCompletedDate = nil
                    }
                    try? modelContext.save()
                }
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(todo.isCompleted ? .green : .gray.opacity(0.5))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(todo.title)
                        .font(.body)
                        .strikethrough(todo.isCompleted, color: .secondary)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)

                    PriorityBadgeView(priority: todo.priority)
                }

                if let dueDate = todo.dueDate {
                    Text(DateHelper.formattedDueDate(dueDate))
                        .font(.caption)
                        .foregroundColor(dueDateColor(dueDate))
                }

                if todo.isRecurringDaily {
                    Text("每日重复")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            if !(todo.reminders ?? []).isEmpty {
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }

    private func dueDateColor(_ date: Date) -> Color {
        let days = DateHelper.daysBetween(Date(), date)
        if todo.isCompleted { return .secondary }
        if days < 0 { return .red }
        if days == 0 { return .orange }
        return .secondary
    }
}
