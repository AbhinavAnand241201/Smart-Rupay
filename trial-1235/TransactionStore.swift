import SwiftUI
import Combine

@MainActor
class TransactionStore: ObservableObject {
    // The raw list of all transactions, loaded from memory.
    @Published var transactions: [TransactionDetail] = []
    
    // FIXED: A stable, published property that holds the grouped sections for the UI.
    // The view will listen to this property for updates.
    @Published var groupedTransactions: [TransactionSection] = []

    private var cancellables = Set<AnyCancellable>()
    private let transactionsSaveKey = "UserTransactions"

    init() {
        loadTransactions()

        // This powerful pipeline automatically calls `groupTransactions()` whenever
        // the main `transactions` array is modified.
        $transactions
            .sink { [weak self] _ in
                self?.groupTransactions()
            }
            .store(in: &cancellables)
    }

    /// This is the new central function for grouping and filtering.
    /// It updates the `groupedTransactions` property, which causes the UI to refresh.
    func groupTransactions(criteria: TransactionFilterCriteria? = nil) {
        
        var filteredTransactions = transactions

        // In the future, you can add your filter logic here based on the criteria
        if let criteria = criteria, criteria.isActive {
            // Example: filteredTransactions = transactions.filter { ... }
        }

        let groupedDictionary = Dictionary(grouping: filteredTransactions) { transaction in
            return Calendar.current.startOfDay(for: transaction.date)
        }

        let sortedKeys = groupedDictionary.keys.sorted(by: >)

        self.groupedTransactions = sortedKeys.map { dateKey -> TransactionSection in
            let title: String
            if Calendar.current.isDateInToday(dateKey) {
                title = "Today"
            } else if Calendar.current.isDateInYesterday(dateKey) {
                title = "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM d, yyyy"
                title = formatter.string(from: dateKey)
            }
            return TransactionSection(id: title, title: title, transactions: groupedDictionary[dateKey] ?? [])
        }
    }

    // --- Data Persistence ---
    func addTransaction(detail: TransactionDetail) {
        transactions.insert(detail, at: 0)
        saveTransactions()
    }
    
    private func saveTransactions() {
        do {
            let data = try JSONEncoder().encode(transactions)
            UserDefaults.standard.set(data, forKey: transactionsSaveKey)
        } catch {
            print("Failed to save transactions: \(error.localizedDescription)")
        }
    }

    private func loadTransactions() {
        guard let data = UserDefaults.standard.data(forKey: transactionsSaveKey) else {
            self.transactions = Self.generateSampleTransactions()
            return
        }
        
        do {
            self.transactions = try JSONDecoder().decode([TransactionDetail].self, from: data)
        } catch {
            print("Failed to load transactions, using sample data. Error: \(error)")
            self.transactions = Self.generateSampleTransactions()
        }
    }
    
    static func generateSampleTransactions() -> [TransactionDetail] {
        var transactions: [TransactionDetail] = []
        let today = Date()
        let calendar = Calendar.current

        transactions.append(TransactionDetail(id: UUID(), date: calendar.date(byAdding: .hour, value: -1, to: today)!, iconName: "cart.fill", iconBackgroundColorHex: "#2c2c2e", name: "Grocery Market", category: "Groceries", amount: -120.00))
        transactions.append(TransactionDetail(id: UUID(), date: calendar.date(byAdding: .hour, value: -3, to: today)!, iconName: "film.fill", iconBackgroundColorHex: "#2c2c2e", name: "Cinema", category: "Entertainment", amount: -30.00))
        
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        transactions.append(TransactionDetail(id: UUID(), date: yesterday, iconName: "fork.knife", iconBackgroundColorHex: "#2c2c2e", name: "Italian Restaurant", category: "Dining Out", amount: -75.00))
        transactions.append(TransactionDetail(id: UUID(), date: calendar.date(byAdding: .hour, value: -9, to: yesterday)!, iconName: "dollarsign.circle.fill", iconBackgroundColorHex: "#34C759", name: "Salary Deposit", category: "Salary", amount: 2500.00))

        return transactions.sorted(by: { $0.date > $1.date })
    }
}
