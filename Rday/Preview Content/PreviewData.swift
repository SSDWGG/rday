import Foundation
import SwiftData

@MainActor
enum PreviewData {
    static var container: ModelContainer = {
        let schema = Schema([
            CountdownEvent.self,
            TodoItem.self,
            TodoReminder.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        guard let container = try? ModelContainer(for: schema, configurations: [configuration]) else {
            fatalError("Could not create preview container")
        }

        let calendar = Calendar.current

        container.mainContext.insert(CountdownEvent(
            title: "春节",
            targetDate: calendar.date(from: DateComponents(year: 2027, month: 2, day: 6))!,
            isCountdown: true,
            note: "中国农历新年"
        ))

        container.mainContext.insert(CountdownEvent(
            title: "恋爱纪念日",
            targetDate: calendar.date(from: DateComponents(year: 2024, month: 6, day: 15))!,
            isCountdown: false,
            note: "在一起的每一天都值得纪念"
        ))

        container.mainContext.insert(CountdownEvent(
            title: "项目交付",
            targetDate: calendar.date(byAdding: .day, value: 30, to: Date())!,
            isCountdown: true
        ))

        let todo1 = TodoItem(
            title: "完成季度报告",
            note: "需要包含Q4数据分析和明年规划",
            dueDate: calendar.date(byAdding: .day, value: 3, to: Date()),
            priority: .high,
            isRecurringDaily: false
        )
        container.mainContext.insert(todo1)

        let todo2 = TodoItem(
            title: "每日阅读",
            note: "至少阅读30分钟",
            priority: .medium,
            isRecurringDaily: true
        )
        let pushReminder = TodoReminder(type: .push, remindAtTime: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!)
        todo2.reminders = [pushReminder]
        container.mainContext.insert(todo2)

        let todo3 = TodoItem(
            title: "买生日礼物",
            dueDate: calendar.date(byAdding: .day, value: 7, to: Date()),
            priority: .low
        )
        container.mainContext.insert(todo3)

        return container
    }()
}

extension CountdownEvent {
    static var preview: CountdownEvent {
        CountdownEvent(
            title: "新年",
            targetDate: Calendar.current.date(from: DateComponents(year: 2027, month: 1, day: 1))!,
            isCountdown: true,
            note: "元旦快乐"
        )
    }
}

extension TodoItem {
    static var preview: TodoItem {
        let todo = TodoItem(
            title: "完成项目",
            note: "提交最终版本",
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            priority: .high,
            isRecurringDaily: false
        )
        todo.reminders = [
            TodoReminder(type: .push, remindAtTime: Date()),
        ]
        return todo
    }
}
