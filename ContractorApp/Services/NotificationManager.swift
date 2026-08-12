import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    @Published var permissionGranted = false

    override init() { super.init(); UNUserNotificationCenter.current().delegate = self }

    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run { permissionGranted = granted }
            if granted { await MainActor.run { UIApplication.shared.registerForRemoteNotifications() } }
        } catch { print("Notification error: \(error)") }
    }

    func scheduleLocal(id: String, title: String, body: String, in seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title; content.body = body; content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(seconds, 1), repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    func scheduleDailyReminder(id: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title; content.body = body; content.sound = .default
        var c = DateComponents(); c.hour = hour; c.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: c, repeats: true)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    func cancel(id: String) { UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id]) }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler handler: @escaping (UNNotificationPresentationOptions) -> Void) {
        handler([.banner, .sound, .badge])
    }
}
