import SwiftUI
import SwiftData
import MessageUI

struct TodoDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStateManager.self) private var appState

    let todo: TodoItem

    @State private var isEditing: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showMailComposer: Bool = false
    @State private var mailBody: String = ""
    @State private var mailSubject: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
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
                        HStack(spacing: 10) {
                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title)
                                .foregroundColor(todo.isCompleted ? .green : .gray)
                            Text(todo.isCompleted ? "已完成" : "标记完成")
                                .font(.headline)
                                .foregroundColor(todo.isCompleted ? .green : .primary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(todo.isCompleted ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top)

                VStack(alignment: .leading, spacing: 16) {
                    detailRow(title: "名称", value: todo.title)
                    detailRow(title: "优先级", value: todo.priority.rawValue)

                    if let dueDate = todo.dueDate {
                        detailRow(title: "截止日期", value: DateHelper.formattedDueDate(dueDate))
                    }

                    if todo.isRecurringDaily {
                        HStack {
                            Image(systemName: "repeat")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("每日重复")
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }

                    if let note = todo.note, !note.isEmpty {
                        detailRow(title: "备注", value: note)
                    }

                    let reminders = todo.reminders ?? []
                    if !reminders.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("提醒设置")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            ForEach(reminders) { reminder in
                                HStack {
                                    Image(systemName: reminder.type == .push ? "bell.fill" : "envelope.fill")
                                        .foregroundColor(.orange)
                                        .font(.subheadline)
                                    Text(reminder.type.displayName)
                                        .font(.subheadline)
                                    if let time = reminder.remindAtTime {
                                        Text("· \(DateHelper.formattedTime(time))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    if todo.isCompleted, let completedDate = todo.lastCompletedDate {
                        detailRow(title: "完成时间", value: completedDate.formatted(date: .abbreviated, time: .shortened))
                    }
                }
                .padding(.horizontal)

                VStack(spacing: 12) {
                    if EmailService.canSendMail {
                        Button {
                            mailSubject = "待办提醒: \(todo.title)"
                            mailBody = createMailBody()
                            showMailComposer = true
                        } label: {
                            Label("发送邮件", systemImage: "envelope")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    Button {
                        isEditing = true
                    } label: {
                        Label("编辑", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("删除", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .navigationTitle("待办详情")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditing) {
            TodoFormView(todo: todo)
        }
        .sheet(isPresented: $showMailComposer) {
            if let controller = EmailService.shared.composeController(
                subject: mailSubject,
                body: mailBody,
                completion: { _ in
                    showMailComposer = false
                }
            ) {
                MailComposeView(controller: controller)
            }
        }
        .confirmationDialog("确定删除此待办吗？", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                NotificationService.shared.cancelAllReminders(for: todo.id)
                modelContext.delete(todo)
                try? modelContext.save()
                dismiss()
            }
            Button("取消", role: .cancel) {}
        }
        .onAppear {
            if let pendingId = appState.pendingEmailTodoId, pendingId == todo.id {
                mailSubject = "待办提醒: \(todo.title)"
                mailBody = createMailBody()
                showMailComposer = true
                appState.pendingEmailTodoId = nil
            }
        }
    }

    private func createMailBody() -> String {
        var body = "待办: \(todo.title)\n"
        if let note = todo.note, !note.isEmpty {
            body += "备注: \(note)\n"
        }
        if let dueDate = todo.dueDate {
            body += "截止日期: \(DateHelper.formattedDueDate(dueDate))\n"
        }
        body += "优先级: \(todo.priority.rawValue)\n"
        return body
    }

    @ViewBuilder
    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    let controller: MFMailComposeViewController

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
