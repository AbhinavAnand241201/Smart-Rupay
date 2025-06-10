

import SwiftUI
import Combine

struct BudgetItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var amount: Double // The total budgeted amount
    var iconName: String
    var colorHex: String
    
    var spentAmount: Double = 0.0
    
    var progress: Double {
        guard amount > 0 else { return 0 }
        return min(spentAmount / amount, 1.0)
    }
    
    var remainingAmount: Double {
        amount - spentAmount
    }
    
    var accentColor: Color {
        Color(hex: colorHex)
    }
}

@MainActor
class BudgetViewModel: ObservableObject {
    @Published var budgets: [BudgetItem] = []
    private let budgetsSaveKey = "UserBudgets"
    
    // A predefined set of visuals for new budgets
    private let budgetVisuals: [(icon: String, colorHex: String)] = [
        ("cart.fill", "007BFF"), ("fork.knife", "FF9500"), ("car.fill", "34C759"),
        ("movieclapper.fill", "AF52DE"), ("creditcard.fill", "FF3B30"),
        ("message.fill", "5E5CE6"), ("house.fill", "FFD700")
    ].shuffled()
    private var nextVisualIndex = 0

    init() {
        loadBudgets()
    }
    
    func addBudget(name: String, amount: Double) {
        let visual = budgetVisuals[nextVisualIndex % budgetVisuals.count]
        nextVisualIndex += 1
        
        let newBudget = BudgetItem(
            id: UUID(),
            name: name,
            amount: amount,
            iconName: visual.icon,
            colorHex: visual.colorHex
        )
        budgets.append(newBudget)
        saveBudgets()
    }
    
    private func saveBudgets() {
        do {
            let data = try JSONEncoder().encode(budgets)
            UserDefaults.standard.set(data, forKey: budgetsSaveKey)
        } catch {
            print("Failed to save budgets: \(error)")
        }
    }
    
    private func loadBudgets() {
        guard let data = UserDefaults.standard.data(forKey: budgetsSaveKey) else {
            // Load sample data if nothing is saved
            self.budgets = [
                BudgetItem(id: UUID(), name: "Groceries", amount: 15000, iconName: "cart.fill", colorHex: "34C759", spentAmount: 8500),
                BudgetItem(id: UUID(), name: "Dining Out", amount: 8000, iconName: "fork.knife", colorHex: "FF9500", spentAmount: 6000)
            ]
            return
        }
        
        do {
            self.budgets = try JSONDecoder().decode([BudgetItem].self, from: data)
        } catch {
            print("Failed to load budgets: \(error)")
        }
    }
}