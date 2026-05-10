import SwiftUI

struct DateCalculatorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()

    private var daysDiff: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    private var weeksAndDays: (weeks: Int, days: Int) {
        let absDays = abs(daysDiff)
        return (absDays / 7, absDays % 7)
    }

    private var monthsAndDays: (months: Int, days: Int) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let earlier = min(start, end)
        let later = max(start, end)
        let months = calendar.dateComponents([.month], from: earlier, to: later).month ?? 0
        let monthDate = calendar.date(byAdding: .month, value: months, to: earlier) ?? later
        let remainingDays = calendar.dateComponents([.day], from: monthDate, to: later).day ?? 0
        return (months, max(0, remainingDays))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("选择日期") {
                    DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                    DatePicker("结束日期", selection: $endDate, displayedComponents: .date)
                }

                Section("计算结果") {
                    VStack(spacing: 16) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(abs(daysDiff))")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                            Text("天")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: 6) {
                            Text("相差 \(monthsAndDays.months) 个月 \(monthsAndDays.days) 天")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("\(weeksAndDays.weeks) 周 \(weeksAndDays.days) 天")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("日期计算器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
