//
//  TransactionStore.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 07/06/25.
//


//
//  TransactionStore.swift
//  trial-1235
//
//  Created by Gemini AI on 07/06/25.
//

import SwiftUI

@MainActor
class TransactionStore: ObservableObject {
    @Published var transactions: [TransactionDetail] = []
    
    private let transactionsSaveKey = "UserTransactions"
    
    init() {
        loadTransactions()
    }
    
    func addTransaction(date: Date, name: String, category: String, amount: Double, iconName: String, iconColor: Color) {
        let newTransaction = TransactionDetail(
            date: date,
            iconName: iconName,
            iconBackgroundColor: iconColor,
            name: name,
            category: category,
            amount: amount
        )
        transactions.insert(newTransaction, at: 0) // Add to the top of the list
        saveTransactions()
    }
    
    private func saveTransactions() {
        // This persistence will require TransactionDetail to be Codable.
        // We will address this in a later step.
        print("TODO: Implement saving transactions here.")
    }
    
    private func loadTransactions() {
        // This persistence will require TransactionDetail to be Codable.
        // For now, we load the same sample data your app was using.
        self.transactions = Self.generateSampleTransactions()
    }
    
    // We can move the sample data generator here to keep things clean.
    static func generateSampleTransactions() -> [TransactionDetail] {
        // ... (The same sample transaction data from your MainAppView)
        // For brevity, I am omitting the large block of sample data.
        // You should copy the generator from `MainAppView.swift` and paste it here.
        // For example:
        let today = Date()
        let calendar = Calendar.current
        return [
            TransactionDetail(date: calendar.date(byAdding: .hour, value: -1, to: today)!, iconName: "cart.fill", iconBackgroundColor: Color(hex: "#2c2c2e"), name: "Groceries", category: "Groceries", amount: -120.00)
            // ... add all other sample transactions
        ]
    }
}