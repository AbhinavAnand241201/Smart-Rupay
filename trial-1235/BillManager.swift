// File: ViewModels/BillManager.swift

import Foundation
import UserNotifications

@MainActor
class BillManager: ObservableObject {
    
    @Published var bills: [BillItem] = []
    @Published var urgentBill: BillItem? = nil

    init() {
        // Load saved bills and check for urgent ones on startup
        loadBills()
        checkForUrgentBills()
    }

    func checkForUrgentBills() {
        // Find the first bill that is urgent
        self.urgentBill = bills.first(where: { $0.isUrgent })
    }
    
    func addBill(_ bill: BillItem) {
        bills.append(bill)
        scheduleNotifications(for: bill)
        saveBills()
    }
    
    func markBillAsPaid(id: UUID) {
        if let index = bills.firstIndex(where: { $0.id == id }) {
            bills[index].isPaid = true
            // Remove any pending notifications for this bill
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(id)-24h", "\(id)-12h", "\(id)-6h", "\(id)-1h"])
        }
        saveBills()
        checkForUrgentBills() // Re-check so the alarm disappears
    }

    // --- NOTIFICATION LOGIC ---
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func scheduleNotifications(for bill: BillItem) {
        let content = UNMutableNotificationContent()
        content.title = "Payment Due Soon!"
        content.subtitle = "\(bill.name) - ₹\(bill.amount) is due."
        content.sound = UNNotificationSound.defaultCritical // For high-priority sound

        // Schedule for 24 hours before
        let t24 = bill.dueDate.addingTimeInterval(-24 * 60 * 60)
        schedule(content: content, date: t24, identifier: "\(bill.id)-24h")
        
        // Schedule for 1 hour before
        let t1 = bill.dueDate.addingTimeInterval(-1 * 60 * 60)
        schedule(content: content, date: t1, identifier: "\(bill.id)-1h")
    }
    
    private func schedule(content: UNNotificationContent, date: Date, identifier: String) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // --- DATA PERSISTENCE (Example using UserDefaults) ---
    func saveBills() {
        if let encodedData = try? JSONEncoder().encode(bills) {
            UserDefaults.standard.set(encodedData, forKey: "userBills")
        }
    }
    
    func loadBills() {
        if let savedData = UserDefaults.standard.data(forKey: "userBills"),
           let decodedBills = try? JSONDecoder().decode([BillItem].self, from: savedData) {
            self.bills = decodedBills
        }
    }
}