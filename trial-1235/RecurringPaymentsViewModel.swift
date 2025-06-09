import SwiftUI
import Combine
import UserNotifications

class RecurringPaymentsViewModel: ObservableObject {
    @Published var recurringPayments: [RecurringPayment] = []
    @Published var notificationAuthStatus: UNAuthorizationStatus = .notDetermined

    let itemVisuals: [(icon: String, colorHex: String)] = [
        ("creditcard.fill", "007BFF"), ("house.fill", "39FF14"), ("phone.fill", "BF00FF"),
        ("bolt.car.fill", "FFD700"), ("figure.walk", "FF3399"), ("newspaper.fill", "FF4500"),
        ("lightbulb.fill", "3AD7D5"), ("wifi", "5E5CE6"), ("tv.fill", "AF52DE")
    ].shuffled()
    private var nextVisualIndex = 0
    
    let sampleCategories = ["Subscription", "Housing", "Utilities", "Loan", "Membership", "Bills", "Insurance", "Internet", "Entertainment"].sorted()
    
    private let paymentsSaveKey = "UserRecurringPayments"

    private func savePayments() {
        do {
            let data = try JSONEncoder().encode(recurringPayments)
            UserDefaults.standard.set(data, forKey: paymentsSaveKey)
        } catch {
            print("Failed to save payments: \(error.localizedDescription)")
        }
    }

    private func loadPayments() {
        guard let data = UserDefaults.standard.data(forKey: paymentsSaveKey) else {
            self.recurringPayments = []
            return
        }
        
        do {
            self.recurringPayments = try JSONDecoder().decode([RecurringPayment].self, from: data)
        } catch {
            print("Failed to load payments: \(error.localizedDescription)")
            self.recurringPayments = []
        }
    }

    init() {
        loadPayments()
        checkNotificationPermission()
        if notificationAuthStatus == .authorized {
            scheduleInitialRemindersForAllActivePayments()
        }
    }

    func checkNotificationPermission() {
        NotificationManager.shared.getNotificationAuthorizationStatus { status in
            self.notificationAuthStatus = status
        }
    }

    func requestNotificationPermission() {
        NotificationManager.shared.requestAuthorization { granted, error in
            self.notificationAuthStatus = granted ? .authorized : .denied
            if granted {
                self.scheduleInitialRemindersForAllActivePayments()
            }
        }
    }

    func scheduleInitialRemindersForAllActivePayments(daysBefore: Int = 3, dueTodayHour: Int = 9) {
        guard notificationAuthStatus == .authorized else { return }
        print("Scheduling initial reminders for all active payments...")
        recurringPayments.forEach { payment in
            if !payment.isEnded && payment.nextDueDate >= Calendar.current.startOfDay(for: Date()) {
                NotificationManager.shared.scheduleNotification(for: payment, reminderDaysBefore: daysBefore, atHour: dueTodayHour)
            } else {
                NotificationManager.shared.cancelNotification(for: payment)
            }
        }
    }
    
    func openAppSettings() {
        NotificationManager.shared.openAppSettings()
    }

    func addPayment(name: String, amount: Double, category: String, interval: RecurrenceInterval, startDate: Date, endDate: Date?, notes: String?) {
        let visual = itemVisuals[nextVisualIndex % itemVisuals.count]
        nextVisualIndex = (nextVisualIndex + 1) % itemVisuals.count

        let newPayment = RecurringPayment(
            name: name, amount: amount, category: category,
            recurrenceInterval: interval, startDate: startDate, endDate: endDate,
            notes: notes, iconName: visual.icon, colorHex: visual.colorHex
        )
        
        recurringPayments.append(newPayment)
        sortPayments()
        
        if notificationAuthStatus == .authorized && !newPayment.isEnded && newPayment.nextDueDate >= Calendar.current.startOfDay(for: Date()){
            NotificationManager.shared.scheduleNotification(for: newPayment)
        }
        savePayments()
    }

    func updatePayment(_ paymentToUpdate: RecurringPayment) {
        if let index = recurringPayments.firstIndex(where: { $0.id == paymentToUpdate.id }) {
            var updatedPayment = paymentToUpdate
            
            if recurringPayments[index].startDate != updatedPayment.startDate || recurringPayments[index].recurrenceInterval != updatedPayment.recurrenceInterval {
                 updatedPayment.nextDueDate = RecurringPayment.calculateCorrectNextDueDate(
                    from: updatedPayment.startDate,
                    interval: updatedPayment.recurrenceInterval,
                    after: Date()
                )
            }

            recurringPayments[index] = updatedPayment
            sortPayments()

            NotificationManager.shared.cancelNotification(for: updatedPayment)
            if notificationAuthStatus == .authorized && !updatedPayment.isEnded && updatedPayment.nextDueDate >= Calendar.current.startOfDay(for: Date()) {
                NotificationManager.shared.scheduleNotification(for: updatedPayment)
            }
            savePayments()
        }
    }
    
    func markAsPaidAndAdvanceDueDate(paymentId: UUID) {
        guard let index = recurringPayments.firstIndex(where: { $0.id == paymentId }) else { return }
        
        var payment = recurringPayments[index]
        let paidOnDate = payment.nextDueDate

        print("--- PAYMENT TRACKED ---")
        print("Recurring payment '\(payment.name)' for $ \(String(format: "%.2f", payment.amount)) due on \(paidOnDate.formatted(date: .long, time: .omitted)) marked as PAID.")
        print("TODO: Create a TransactionDetail record: category='\(payment.category)', amount='-\(payment.amount)', date='\(paidOnDate)'.")
        print("------------------------")

        NotificationManager.shared.cancelNotification(for: payment)

        let newAdvancedDueDate = payment.getNextSequentialDueDate()
        
        if let endDate = payment.endDate, newAdvancedDueDate > endDate {
            payment.nextDueDate = newAdvancedDueDate
            print("\(payment.name) has concluded its recurrence period.")
        } else {
            payment.nextDueDate = newAdvancedDueDate
        }
        
        recurringPayments[index] = payment
        sortPayments()

        if notificationAuthStatus == .authorized && !payment.isEnded && payment.nextDueDate >= Calendar.current.startOfDay(for: Date()) {
            NotificationManager.shared.scheduleNotification(for: payment)
        }
        savePayments()
    }

    func deletePayment(at offsets: IndexSet) {
        let paymentsToDelete = offsets.map { recurringPayments[$0] }
        paymentsToDelete.forEach { NotificationManager.shared.cancelNotification(for: $0) }
        recurringPayments.remove(atOffsets: offsets)
        savePayments()
    }

    private func sortPayments() {
        recurringPayments.sort {
            // Primary sort: Not ended vs Ended
            if !$0.isEnded && $1.isEnded { return true }
            if $0.isEnded && !$1.isEnded { return false }
            // Secondary sort: Next due date
            return $0.nextDueDate < $1.nextDueDate
        }
    }

    private func loadSamplePayments() {
        let calendar = Calendar.current
        let today = Date()
        
        let sampleData = [
            RecurringPayment(name: "Netflix Premium", amount: 19.99, category: "Subscription", recurrenceInterval: .monthly, startDate: calendar.date(byAdding: .month, value: -2, to: today)!, iconName: itemVisuals[0].icon, colorHex: itemVisuals[0].colorHex),
            RecurringPayment(name: "Apartment Rent", amount: 1250.00, category: "Housing", recurrenceInterval: .monthly, startDate: calendar.date(byAdding: .day, value: -60, to: today)!, iconName: itemVisuals[1].icon, colorHex: itemVisuals[1].colorHex),
            RecurringPayment(name: "Gym Active", amount: 39.99, category: "Membership", recurrenceInterval: .monthly, startDate: calendar.date(byAdding: .day, value: -45, to: today)!, nextDueDate: calendar.date(byAdding: .day, value: 5, to: today), iconName: itemVisuals[4].icon, colorHex: itemVisuals[4].colorHex), // Due in 5 days
            RecurringPayment(name: "Phone Bill (Past End)", amount: 50.00, category: "Utilities", recurrenceInterval: .monthly, startDate: calendar.date(byAdding: .month, value: -8, to: today)!, endDate: calendar.date(byAdding: .month, value: -2, to: today)!, iconName: itemVisuals[2].icon, colorHex: itemVisuals[2].colorHex), // Already ended
            RecurringPayment(name: "Upcoming Weekly", amount: 10.00, category: "Subscription", recurrenceInterval: .weekly, startDate: calendar.date(byAdding: .day, value: 1, to: today)!, iconName: itemVisuals[3].icon, colorHex: itemVisuals[3].colorHex) // Starts tomorrow
        ]
        self.recurringPayments = sampleData
        self.nextVisualIndex = sampleData.count % itemVisuals.count
        
        // Ensure all nextDueDates are correctly calculated after loading samples
        for i in recurringPayments.indices {
            recurringPayments[i].nextDueDate = RecurringPayment.calculateCorrectNextDueDate(
                from: recurringPayments[i].startDate,
                interval: recurringPayments[i].recurrenceInterval,
                after: Date() // Reference from today
            )
        }
        sortPayments()
    }
}
