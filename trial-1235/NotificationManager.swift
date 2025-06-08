// NotificationManager.swift
// Smart-Rupay App - Corrected
//trying to resolve some issues here , will do it tmr.

import UserNotifications
import UIKit // For UIApplication settings URL

class NotificationManager {
    static let shared = NotificationManager()
    private init() {} // Singleton

    // Request user permission for notifications
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting notification authorization: \(error.localizedDescription)")
                }
                completion(granted, error)
            }
        }
    }

    // Check current notification authorization status
    func getNotificationAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // Schedule a local notification for a recurring payment
    func scheduleNotification(for payment: RecurringPayment, reminderDaysBefore: Int = 3, atHour: Int = 9, atMinute: Int = 0) {
        // Ensure the payment isn't already ended
        if payment.isEnded {
            print("Payment '\(payment.name)' has already ended. No notification scheduled.")
            cancelNotification(for: payment) // Cancel any lingering notifications
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming: \(payment.name)"
        // **CORRECTED LINE BELOW**
        content.body = String(format: "$%.2f due on %@", payment.amount, payment.nextDueDate.formatted(date: .long, time: .omitted))
        content.sound = .default
        content.userInfo = ["paymentID": payment.id.uuidString]
        // content.badge = 1 // Manage badge count carefully

        guard var reminderTriggerDate = Calendar.current.date(byAdding: .day, value: -reminderDaysBefore, to: payment.nextDueDate) else {
            print("Could not calculate reminder trigger date for \(payment.name).")
            return
        }

        if reminderTriggerDate <= Date() {
            if payment.nextDueDate >= Calendar.current.startOfDay(for: Date()) {
                if Calendar.current.isDateInToday(payment.nextDueDate) {
                    let nowComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
                    var dueTodayComponents = Calendar.current.dateComponents([.year, .month, .day], from: payment.nextDueDate)
                    dueTodayComponents.hour = nowComponents.hour ?? atHour
                    dueTodayComponents.minute = (nowComponents.minute ?? atMinute) + 1
                    
                    if let specificTodayReminder = Calendar.current.date(from: dueTodayComponents), specificTodayReminder > Date() {
                        reminderTriggerDate = specificTodayReminder
                    } else {
                         print("Reminder time for '\(payment.name)' (due today) is already past. No notification scheduled.")
                         return
                    }
                } else {
                    print("Calculated reminder date for '\(payment.name)' is in the past. No notification scheduled.")
                    return
                }
            } else {
                print("Due date for '\(payment.name)' is in the past. No notification scheduled.")
                return
            }
        }
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: reminderTriggerDate)
        dateComponents.hour = atHour
        dateComponents.minute = atMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = payment.id.uuidString + "_reminder_\(reminderDaysBefore)days"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(payment.name) (ID: \(identifier)): \(error.localizedDescription)")
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, h:mm a"
                print("Notification scheduled for \(payment.name) (ID: \(identifier)) to trigger around \(formatter.string(from: Calendar.current.date(from:dateComponents)!))")
            }
        }
    }

    func cancelNotification(for payment: RecurringPayment) {
        let baseID = payment.id.uuidString
        // More robustly cancel all potential identifiers associated with this payment ID prefix
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToCancel = requests.filter { $0.identifier.hasPrefix(baseID) }.map { $0.identifier }
            if !identifiersToCancel.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
                print("Cancelled pending notifications for payment: \(payment.name) (IDs: \(identifiersToCancel.joined(separator: ", ")))")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All pending notifications cancelled.")
    }

    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            DispatchQueue.main.async {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
}
