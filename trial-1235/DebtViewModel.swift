// MARK: - ViewModel for Debt Management
// File: ViewModels/DebtViewModel.swift

import Foundation
import SwiftUI

@MainActor
class DebtViewModel: ObservableObject {

    @Published var debtItems: [DebtItem] = [] // The master list of all debts
    @Published var strategy: PayoffStrategy = .snowball // Default strategy
    @Published var monthlyExtraPayment: Double = 0.0 // Extra amount user can pay

    enum PayoffStrategy: String, CaseIterable {
        case snowball = "Snowball" // Pay lowest balance first
        case avalanche = "Avalanche" // Pay highest interest first
    }

    // This is the core logic: a computed property that returns the debts
    // sorted according to the selected strategy.
    var sortedDebts: [DebtItem] {
        switch strategy {
        case .snowball:
            // Sort by the lowest remaining balance first
            return debtItems.sorted { $0.remainingBalance < $1.remainingBalance }
        case .avalanche:
            // Sort by the highest interest rate first
            return debtItems.sorted { $0.interestRate > $1.interestRate }
        }
    }

    // Summary Properties
    var totalOutstandingDebt: Double {
        debtItems.reduce(0) { $0 + $1.remainingBalance }
    }

    // TODO: Add functions to add, edit, and delete debts
    func addDebt(item: DebtItem) {
        debtItems.append(item)
    }
    
    // TODO: Add function to apply payments to debts
}