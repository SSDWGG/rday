import UIKit
import UserNotifications

@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    var onNavigateToTodo: ((UUID) -> Void)?

    private let center = UNUserNotificationCenter.current()

    override private init() {
        super.init()
        center.delegate = self
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func schedulePushReminder(for todoId: UUID, title: String, body: String?, at date: Date) {
        let identifier = "todo-\(todoId.uuidString)-push-\(UUID().uuidString.prefix(8))"
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body ?? "你的待办事项需要处理"
        content.sound = .default
        content.userInfo = ["todoId": todoId.uuidString, "type": "push"]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    func scheduleDailyPushReminder(for todoId: UUID, title: String, body: String?, atTime time: Date) {
        let identifier = "todo-\(todoId.uuidString)-daily"
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body ?? "每日待办提醒"
        content.sound = .default
        content.userInfo = ["todoId": todoId.uuidString, "type": "push"]

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    func scheduleEmailReminder(for todoId: UUID, title: String, body: String?, at date: Date) {
        let identifier = "todo-\(todoId.uuidString)-email-\(UUID().uuidString.prefix(8))"
        let content = UNMutableNotificationContent()
        content.title = "[邮件] " + title
        content.body = "点击以发送邮件提醒 — " + (body ?? title)
        content.sound = .default
        content.userInfo = ["todoId": todoId.uuidString, "type": "email"]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelAllReminders(for todoId: UUID) {
        let prefix = "todo-\(todoId.uuidString)"
        center.getPendingNotificationRequests { requests in
            let toRemove = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(prefix) }
            self.center.removePendingNotificationRequests(withIdentifiers: toRemove)
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        guard let todoIdString = userInfo["todoId"] as? String,
              let todoId = UUID(uuidString: todoIdString) else { return }
        await MainActor.run {
            NotificationService.shared.onNavigateToTodo?(todoId)
        }
    }
}
