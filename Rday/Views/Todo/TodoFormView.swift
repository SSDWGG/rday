import SwiftUI
import SwiftData

struct TodoFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let editingTodo: TodoItem?

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var priority: TodoPriority = .none
    @State private var isRecurringDaily: Bool = false
    @State private var isPushEnabled: Bool = false
    @State private var pushTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var isEmailEnabled: Bool = false
    @State private var emailTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showDeleteConfirmation: Bool = false
    @State private var showPastTimeAlert: Bool = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    private var isEditing: Bool { editingTodo != nil }
    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    init(todo: TodoItem? = nil) {
        self.editingTodo = todo
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("待办事项") {
                    TextField("标题", text: $title)

                    ZStack(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("添加备注...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $note)
                            .frame(minHeight: 60)
                    }

                    Toggle("设置截止日期", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker("截止日期", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }

                    Picker("优先级", selection: $priority) {
                        ForEach(TodoPriority.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                }

                Section {
                    Toggle("每日重复", isOn: $isRecurringDaily)
                        .disabled(editingTodo != nil)
                } header: {
                    Text("重复")
                } footer: {
                    if isRecurringDaily {
                        Text("此待办每天都会重新显示为未完成状态")
                    }
                }

                Section {
                    Toggle("推送通知", isOn: $isPushEnabled.animation())
                        .disabled(notificationStatus == .denied)

                    if isPushEnabled {
                        DatePicker("提醒时间", selection: $pushTime, displayedComponents: .hourAndMinute)
                    }

                    if notificationStatus == .denied {
                        HStack {
                            Text("通知已禁用")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("打开设置") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.caption)
                        }
                    }

                    Toggle("邮件提醒", isOn: $isEmailEnabled.animation())

                    if isEmailEnabled {
                        if EmailService.canSendMail {
                            DatePicker("提醒时间", selection: $emailTime, displayedComponents: .hourAndMinute)
                            Text("到时间后会收到推送通知，点击即可打开邮件")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("未配置邮件账户，请在「邮件」App 中设置")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("提醒")
                }

                if isEditing {
                    Section {
                        Button("删除待办", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑待办" : "新建待办")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if validateAndSave() {
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                Task {
                    notificationStatus = await NotificationService.shared.authorizationStatus()
                }
                loadEditingTodo()
            }
            .confirmationDialog("确定删除此待办吗？", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("删除", role: .destructive) {
                    deleteTodo()
                    dismiss()
                }
                Button("取消", role: .cancel) {}
            }
            .alert("提醒时间已过", isPresented: $showPastTimeAlert) {
                Button("好的", role: .cancel) {}
            } message: {
                Text("推送提醒时间不能是过去的时间")
            }
        }
    }

    private func loadEditingTodo() {
        guard let todo = editingTodo else { return }
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

    private func validateAndSave() -> Bool {
        guard canSave else { return false }

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
                showPastTimeAlert = true
                return false
            }
        }

        save()
        return true
    }

    private func save() {
        let todo: TodoItem

        if let existing = editingTodo {
            todo = existing
            NotificationService.shared.cancelAllReminders(for: todo.id)
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
    }

    private func scheduleReminders(for todo: TodoItem) {
        let calendar = Calendar.current

        if isPushEnabled {
            let reminder = TodoReminder(type: .push, remindAtTime: pushTime)
            if todo.reminders == nil { todo.reminders = [] }
            todo.reminders?.append(reminder)

            if isRecurringDaily {
                NotificationService.shared.scheduleDailyPushReminder(
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
                NotificationService.shared.schedulePushReminder(
                    for: todo.id,
                    title: todo.title,
                    body: todo.note,
                    at: triggerDate
                )
            }
        }

        if isEmailEnabled && EmailService.canSendMail {
            let reminder = TodoReminder(type: .email, remindAtTime: emailTime)
            if todo.reminders == nil { todo.reminders = [] }
            todo.reminders?.append(reminder)

            if isRecurringDaily {
                NotificationService.shared.scheduleDailyPushReminder(
                    for: todo.id,
                    title: "[邮件] " + todo.title,
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
                NotificationService.shared.scheduleEmailReminder(
                    for: todo.id,
                    title: todo.title,
                    body: todo.note,
                    at: triggerDate
                )
            }
        }
    }

    private func deleteTodo() {
        guard let todo = editingTodo else { return }
        NotificationService.shared.cancelAllReminders(for: todo.id)
        modelContext.delete(todo)
        try? modelContext.save()
    }
}
