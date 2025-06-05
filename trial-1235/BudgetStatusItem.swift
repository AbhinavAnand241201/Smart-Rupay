//
//  BudgetStatusItem.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 05/06/25.
//

import SwiftUI
// Add this to a Models file or at the top of RupayOracleViewModel.swift

struct BudgetStatusItem: Identifiable {
    let id = UUID()
    let categoryName: String
    let budgetedAmount: Double
    var spentAmount: Double
    var accentColor: Color // For potential display

    var isOverBudget: Bool { spentAmount > budgetedAmount && budgetedAmount > 0 }
    var isWithinBudget: Bool { spentAmount <= budgetedAmount && budgetedAmount > 0}
    var progress: Double {
        guard budgetedAmount > 0 else { return 0 }
        return min(spentAmount / budgetedAmount, 1.5) // Allow showing over-budget progress up to 150%
    }
}
