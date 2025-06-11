
// In file: RupayOracleViewModel.swift

import SwiftUI
import Combine

class RupayOracleViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var averageMonthlyIncomeString: String = "95000" // More realistic sample income
    @Published var allTransactions: [TransactionDetail] = []
    @Published var budgetItems: [BudgetStatusItem] = []
    @Published var financialGoals: [FinancialGoal] = []
    @Published var badges: [Badge] = []

    @Published var overallWellnessScore: Double = 0.0
    @Published var budgetAdherenceScore: Double = 0.0
    @Published var emergencyFundProgressScore: Double = 0.0
    @Published var savingsRate: Double = 0.0
    @Published var savingsRateScore: Double = 0.0
    @Published var averageMonthlyExpenses: Double = 0.0
    @Published var oracleTip: String = "Let's analyze your finances to get your first tip!"
    
    // MARK: - Private Properties
    private var lastMonthBudgetAdherence: Double = 65.0
    private var lastMonthSavingsRate: Double = 8.0

    // MARK: - Initialization
    init() {
        // We now call our updated mock data generators
        self.allTransactions = Self.generateSampleTransactions()
        self.budgetItems = Self.generateSampleBudgets()
        self.financialGoals = Self.generateSampleGoals()
        self.initializeBadges()
        recalculateWellnessMetrics()
    }

    // MARK: - Core Logic (Preserved)
    // All of your complex calculation logic remains exactly the same.
    
    func getAverageMonthlyIncome() -> Double {
        Double(averageMonthlyIncomeString) ?? 0.0
    }

    func recalculateWellnessMetrics() {
        let income = getAverageMonthlyIncome()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let recentExpenses = allTransactions.filter { !$0.isCredit && $0.date >= thirtyDaysAgo }
        self.averageMonthlyExpenses = recentExpenses.reduce(0) { $0 + abs($1.amount) }

        if income > 0 {
            let netSavings = income - self.averageMonthlyExpenses
            self.savingsRate = (netSavings / income) * 100.0
            if self.savingsRate >= 20 { self.savingsRateScore = 100 }
            else if self.savingsRate >= 10 { self.savingsRateScore = 75 }
            else if self.savingsRate >= 5 { self.savingsRateScore = 50 }
            else if self.savingsRate > 0 { self.savingsRateScore = 25 }
            else { self.savingsRateScore = 0 }
        } else {
            self.savingsRate = 0.0
            self.savingsRateScore = 0.0
        }

        let relevantBudgets = budgetItems.filter { $0.budgetedAmount > 0 }
        if !relevantBudgets.isEmpty {
            let metOrUnderBudgets = relevantBudgets.filter { $0.spentAmount <= $0.budgetedAmount }.count
            self.budgetAdherenceScore = (Double(metOrUnderBudgets) / Double(relevantBudgets.count)) * 100.0
        } else {
            self.budgetAdherenceScore = 50.0
        }

        if let emergencyGoal = financialGoals.first(where: { $0.name.lowercased().contains("emergency fund") }) {
            self.emergencyFundProgressScore = emergencyGoal.progress * 100.0
        } else {
            self.emergencyFundProgressScore = 0.0
        }

        let weightedBudgetScore = self.budgetAdherenceScore * 0.35
        let weightedEmergencyFundScore = self.emergencyFundProgressScore * 0.35
        let weightedSavingsScore = self.savingsRateScore * 0.30
        self.overallWellnessScore = min(max(weightedBudgetScore + weightedEmergencyFundScore + weightedSavingsScore, 0), 100)

        checkAndAwardBadges()
        selectOracleTip()
    }

    private func initializeBadges() {
        badges = [
            Badge(id: "budgetPro", name: "Budget Pro", description: "Kept all budgets in check!", iconName: "chart.bar.doc.horizontal", achievedIconName: "chart.bar.doc.horizontal.fill", accentColor: .App.accentGreen),
            Badge(id: "emergencyReady50", name: "Emergency Ready Lvl 1", description: "Reached 50% of your Emergency Fund goal!", iconName: "shield.lefthalf.filled", achievedIconName: "shield.fill", accentColor: .App.accentOrange),
            Badge(id: "emergencyReady100", name: "Fort Knox", description: "Fully funded your Emergency Fund!", iconName: "shield.lefthalf.filled", achievedIconName: "shield.checkerboard", accentColor: .App.accent),
            Badge(id: "goalGetter", name: "Goal Getter", description: "Achieved a financial goal!", iconName: "target", achievedIconName: "flag.fill", accentColor: .App.accentPink),
            Badge(id: "savingsSavvy10", name: "Savings Savvy", description: "Achieved a 10%+ savings rate!", iconName: "banknote", achievedIconName: "banknote.fill", accentColor: .App.accentBlue)
        ]
    }
    
    private func checkAndAwardBadges() { /* ... Your existing logic ... */ }
    private func selectOracleTip() { /* ... Your existing logic ... */ }
    
    // MARK: - Static Mock Data Generators (Enhanced)
    
    static func generateSampleTransactions() -> [TransactionDetail] {
        // This can be expanded to provide transactions for the last 30 days
        return [] // Returning empty for now as it's not directly displayed
    }
    
    static func generateSampleBudgets() -> [BudgetStatusItem] {
        return [
            .init(categoryName: "Groceries", budgetedAmount: 20000, spentAmount: 18500, accentColor: .App.accentGreen),
            .init(categoryName: "Dining Out", budgetedAmount: 15000, spentAmount: 16000, accentColor: .App.accentOrange),
            .init(categoryName: "Shopping", budgetedAmount: 25000, spentAmount: 12000, accentColor: .App.accentPink),
        ]
    }
    
    static func generateSampleGoals() -> [FinancialGoal] {
        return [
            .init(name: "Emergency Fund", targetAmount: 200000, currentAmount: 150000, iconName: "shield.lefthalf.filled", colorHex: Color.App.accentGreen.toHex() ?? ""),
            .init(name: "MacBook Pro", targetAmount: 250000, currentAmount: 195000, iconName: "laptopcomputer", colorHex: Color.App.accentBlue.toHex() ?? ""),
            .init(name: "Completed Goal!", targetAmount: 50000, currentAmount: 50000, iconName: "star.fill", colorHex: Color.App.accentOrange.toHex() ?? "")
        ]
    }
}


// MARK: - Color Extension (Bug Fixed)
// This more robust version handles all our app's accent colors
extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            // Add cases for all colors in our app palette
            if self == .App.accentBlue { return "0A84FF" }
            if self == .App.accentGreen { return "30D158" }
            if self == .App.accentOrange { return "FF9F0A" }
            if self == .App.accentPink { return "FF2D55" }
            if self == .App.accentPurple { return "AF52DE" }
            return nil
        }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
