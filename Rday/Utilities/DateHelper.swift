import Foundation

enum DateHelper {
    static func daysBetween(_ from: Date, _ to: Date) -> Int {
        let calendar = Calendar.current
        let startOfFrom = calendar.startOfDay(for: from)
        let startOfTo = calendar.startOfDay(for: to)
        return calendar.dateComponents([.day], from: startOfFrom, to: startOfTo).day ?? 0
    }

    static func formattedDueDate(_ date: Date) -> String {
        let days = daysBetween(Date(), date)
        if days == 0 { return "今天截止" }
        if days == 1 { return "明天截止" }
        if days == -1 { return "昨天截止" }
        if days < 0 { return "已逾期 \(abs(days)) 天" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    static func formattedDate(_ date: Date) -> String {
        date.formatted(date: .long, time: .omitted)
    }

    static func formattedTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func startOfToday() -> Date {
        Calendar.current.startOfDay(for: Date())
    }

    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}
