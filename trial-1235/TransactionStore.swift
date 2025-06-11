import SwiftUI
import Combine

@MainActor
class TransactionStore: ObservableObject {
    
    @Published var transactions: [TransactionDetail] = []
    
    
    @Published var groupedTransactions: [TransactionSection] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let transactionsSaveKey = "UserTransactions"
    
    init() {
        loadTransactions()
        
        
        $transactions
            .sink { [weak self] _ in
                self?.groupTransactions()
            }
            .store(in: &cancellables)
    }
    
    
    func groupTransactions(criteria: TransactionFilterCriteria? = nil) {
        
        var filteredTransactions = transactions
        
        if let criteria = criteria, criteria.isActive {
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
    
    
    
    func updateTransaction(_ transaction: TransactionDetail) async {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            print("Error: Transaction to update not found in local store.")
            return
        }
        
        // Create the request body
        let updateRequest = TransactionUpdateRequest(
            name: transaction.name,
            category: transaction.category,
            amount: transaction.amount,
            date: transaction.date
        )
        
        do {
            // Call the network service and get the updated transaction back from the server
            let updatedFromServer = try await NetworkService.shared.updateTransaction(
                id: transaction.id.uuidString, // Assuming IDs are UUIDs, convert to string
                with: updateRequest
            )
            
            // Update the local array on the main thread
            await MainActor.run {
                self.transactions[index] = updatedFromServer
            }
        } catch {
            print("Failed to update transaction: \(error.localizedDescription)")
        }
    }
    
    static func generateSampleTransactions() -> [TransactionDetail] {
        var transactions: [TransactionDetail] = []
        let today = Date()
        let calendar = Calendar.current
        
        // Today's Transactions
        transactions.append(.init(id: UUID(), date: today, iconName: "cart.fill", iconBackgroundColorHex: "#30D158", name: "BigBasket Groceries", category: "Groceries", amount: -2850.50))
        transactions.append(.init(id: UUID(), date: calendar.date(byAdding: .hour, value: -2, to: today)!, iconName: "fork.knife", iconBackgroundColorHex: "#FF9F0A", name: "Lunch at Social", category: "Dining Out", amount: -1200.00))
        
        // Yesterday's Transactions
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        transactions.append(.init(id: UUID(), date: yesterday, iconName: "fuelpump.fill", iconBackgroundColorHex: "#AF52DE", name: "Petrol", category: "Transport", amount: -2000.00))
        transactions.append(.init(id: UUID(), date: calendar.date(byAdding: .hour, value: -5, to: yesterday)!, iconName: "ticket.fill", iconBackgroundColorHex: "#FF2D55", name: "Movie Tickets", category: "Entertainment", amount: -750.00))
        
        // Two Days Ago
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        transactions.append(.init(id: UUID(), date: twoDaysAgo, iconName: "dollarsign.circle.fill", iconBackgroundColorHex: "#34C759", name: "Freelance Project Payment", category: "Salary", amount: 45000.00))
        transactions.append(.init(id: UUID(), date: calendar.date(byAdding: .hour, value: -1, to: twoDaysAgo)!, iconName: "bag.fill", iconBackgroundColorHex: "#FF2D55", name: "H&M Shopping", category: "Shopping", amount: -4999.00))
        
        return transactions.sorted(by: { $0.date > $1.date })
    }
}
