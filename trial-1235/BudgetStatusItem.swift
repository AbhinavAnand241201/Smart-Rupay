import SwiftUI

struct BudgetStatusItem: Identifiable {
    let id = UUID()
    let categoryName: String
    let budgetedAmount: Double
    var spentAmount: Double
    var accentColor: Color

    var isOverBudget: Bool { spentAmount > budgetedAmount && budgetedAmount > 0 }
    var isWithinBudget: Bool { spentAmount <= budgetedAmount && budgetedAmount > 0}
    var progress: Double {
        guard budgetedAmount > 0 else { return 0 }
        return min(spentAmount / budgetedAmount, 1.5)
    }
}
