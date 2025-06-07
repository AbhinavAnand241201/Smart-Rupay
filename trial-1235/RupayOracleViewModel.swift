// RupayOracleViewModel.swift
// Smart-Rupay App - Full Corrected Version
// RupayOracleViewModel.swift
// Smart-Rupay App - Phase 2 Enhancements

import SwiftUI
import Combine

// Make sure your TransactionDetail, BudgetStatusItem, and FinancialGoal structs are defined
// and accessible. Color(hex:) extension must also be globally available.

class RupayOracleViewModel: ObservableObject {
    // --- Inputs (These would ideally come from other services/data stores) ---
    @Published var averageMonthlyIncomeString: String = "5000"
    @Published var allTransactions: [TransactionDetail] = []
    @Published var budgetItems: [BudgetStatusItem] = []
    @Published var financialGoals: [FinancialGoal] = []

    // --- Outputs for the UI ---
    @Published var overallWellnessScore: Double = 0.0
    @Published var budgetAdherenceScore: Double = 0.0
    @Published var emergencyFundProgressScore: Double = 0.0
    @Published var savingsRate: Double = 0.0 // Percentage
    @Published var savingsRateScore: Double = 0.0 // Scored version of savings rate (0-100)
    @Published var averageMonthlyExpenses: Double = 0.0
    @Published var oracleTip: String = "Let's analyze your finances to get your first tip!"
    @Published var badges: [Badge] = []

    // --- Simulated Historical Data for Phase 2 Trend Nudges ---
    private var lastMonthBudgetAdherence: Double = 65.0
    private var lastMonthSavingsRate: Double = 8.0

    let accentColorTeal = Color(hex: "3AD7D5") // Assumes Color(hex:) is available
    let categoryColors = [
        Color(hex: "FF3399"), Color.orange, Color(hex: "39FF14"),
        Color(hex: "007BFF"), Color(hex: "FFD700"), Color(hex: "BF00FF"), Color(hex: "FF4500")
    ]

    init(sampleTransactions: [TransactionDetail]? = nil,
         sampleBudgets: [BudgetStatusItem]? = nil,
         sampleGoals: [FinancialGoal]? = nil) {
        self.allTransactions = sampleTransactions ?? Self.generateSampleTransactions()
        self.budgetItems = sampleBudgets ?? Self.generateSampleBudgets(colors: categoryColors)
        self.financialGoals = sampleGoals ?? Self.generateSampleGoals(colors: categoryColors)
        self.initializeBadges()
        recalculateWellnessMetrics()
    }

    func getAverageMonthlyIncome() -> Double {
        Double(averageMonthlyIncomeString) ?? 0.0
    }

    func recalculateWellnessMetrics() {
        let income = getAverageMonthlyIncome()

        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let recentExpenses = allTransactions.filter { !$0.isCredit && $0.date >= thirtyDaysAgo }
        let totalRecentExpenses = recentExpenses.reduce(0) { $0 + abs($1.amount) }
        self.averageMonthlyExpenses = totalRecentExpenses

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
            Badge(id: "budgetPro", name: "Budget Pro", description: "Kept all budgets in check for a month!", iconName: "chart.bar.doc.horizontal", achievedIconName: "chart.bar.doc.horizontal.fill", accentColor: categoryColors[2]),
            Badge(id: "emergencyReady50", name: "Emergency Ready Lvl 1", description: "Reached 50% of your Emergency Fund goal!", iconName: "shield.lefthalf.filled", achievedIconName: "shield.fill", accentColor: categoryColors[4]),
            Badge(id: "emergencyReady100", name: "Fort Knox", description: "Fully funded your Emergency Fund!", iconName: "shield.lefthalf.filled", achievedIconName: "shield.checkerboard", accentColor: accentColorTeal),
            Badge(id: "goalGetter", name: "Goal Getter", description: "Achieved a financial goal!", iconName: "target", achievedIconName: "flag.fill", accentColor: categoryColors[0]),
            Badge(id: "savingsSavvy10", name: "Savings Savvy", description: "Achieved a 10%+ savings rate!", iconName: "banknote", achievedIconName: "banknote.fill", accentColor: categoryColors[1])
        ]
    }

    private func checkAndAwardBadges() {
        for i in badges.indices {
            if badges[i].isAchieved { continue }
            switch badges[i].id {
            case "budgetPro":
                if budgetAdherenceScore >= 99.0 { badges[i].isAchieved = true; badges[i].achievedDate = Date() }
            case "emergencyReady50":
                if emergencyFundProgressScore >= 50.0 { badges[i].isAchieved = true; badges[i].achievedDate = Date() }
            case "emergencyReady100":
                if emergencyFundProgressScore >= 99.9 { badges[i].isAchieved = true; badges[i].achievedDate = Date() }
            case "goalGetter":
                if financialGoals.contains(where: { $0.isCompleted }) { badges[i].isAchieved = true; badges[i].achievedDate = Date() }
            case "savingsSavvy10":
                if savingsRate >= 10.0 { badges[i].isAchieved = true; badges[i].achievedDate = Date() }
            default: break
            }
        }
    }

    private func selectOracleTip() {
        var potentialTips: [String] = []
        if getAverageMonthlyIncome() <= 0 {
            oracleTip = "Rupay Oracle says: Knowing your income is the first step to smart finance. Please update your average monthly income!"
            return
        }
        if budgetAdherenceScore < lastMonthBudgetAdherence - 10 { potentialTips.append("Rupay Oracle noticed: Your budget adherence slipped a bit this month. A quick review might help get back on track!")
        } else if budgetAdherenceScore > lastMonthBudgetAdherence + 10 && budgetAdherenceScore > 80 { potentialTips.append("Fantastic improvement on sticking to your budget this month! Rupay Oracle is impressed!") }
        if savingsRate < lastMonthSavingsRate - 2 && savingsRate < 10 { potentialTips.append("Rupay Oracle sees: Your savings rate dipped. Small, consistent savings are powerful. Let's see if we can find an area to redirect funds from.") }
        if emergencyFundProgressScore < 30 { potentialTips.append("Rupay Oracle suggests: Your emergency fund is a key safety net. Even small, regular contributions make a big difference!")
        } else if emergencyFundProgressScore < 75 && emergencyFundProgressScore >= 30 && !financialGoals.contains(where: {$0.name.lowercased().contains("emergency fund") && $0.isCompleted}) { potentialTips.append("You're making good progress on your emergency fund! Keep it up to build that financial cushion.") }
        if budgetAdherenceScore < 60 {
            let overspentCategories = budgetItems.filter { $0.isOverBudget }.map { $0.categoryName }
            if let firstOverspent = overspentCategories.first { potentialTips.append("Rupay Oracle notes: It can be tricky with budgets. Spending in '\(firstOverspent)' was higher than planned. Maybe review that category for next month?")
            }
        } else if budgetAdherenceScore >= 90 { potentialTips.append("Excellent work on your budget this month! Rupay Oracle commends your discipline.") }
        if savingsRate < 5 && getAverageMonthlyIncome() > 0 { potentialTips.append("Rupay Oracle advises: Aiming for a higher savings rate can help you reach goals faster. Let's look for ways to save a bit more!")
        } else if savingsRate >= 15 { potentialTips.append("A savings rate of \(String(format: "%.0f%%", savingsRate)) is fantastic! You're building a strong financial future.") }
        if overallWellnessScore > 85 { potentialTips.append("Rupay Oracle is impressed! You're managing your finances like a pro. Keep up the great work!")
        } else if overallWellnessScore < 50 { potentialTips.append("Rupay Oracle says: Let's work together to boost your financial wellness. Small steps can lead to big improvements!")
        } else { potentialTips.append("Rupay Oracle here to help! Regularly reviewing your finances empowers you to make smarter decisions.") }
        oracleTip = potentialTips.randomElement() ?? "Rupay Oracle is analyzing your data. Check back soon for fresh insights!"
    }
    
    // In RupayOracleViewModel.swift

    static func generateSampleTransactions() -> [TransactionDetail] {
        let calendar = Calendar.current
        let today = Date()
        
        // FIXED: All initializers now correctly use `id: UUID()`, `iconBackgroundColorHex`, and pass a String hex value.
        return [
            TransactionDetail(id: UUID(), date: calendar.date(byAdding: .day, value: -2, to: today)!, iconName: "cart.fill", iconBackgroundColorHex: "#8E8E93", name: "Groceries A", category: "Groceries", amount: -70.0),
            TransactionDetail(id: UUID(), date: calendar.date(byAdding: .day, value: -5, to: today)!, iconName: "fork.knife", iconBackgroundColorHex: "#FF9500", name: "Restaurant B", category: "Dining Out", amount: -45.0),
            TransactionDetail(id: UUID(), date: calendar.date(byAdding: .day, value: -10, to: today)!, iconName: "bolt.fill", iconBackgroundColorHex: "#FFCC00", name: "Electricity Bill", category: "Utilities", amount: -80.0),
            TransactionDetail(id: UUID(), date: calendar.date(byAdding: .day, value: -25, to: today)!, iconName: "dollarsign.circle.fill", iconBackgroundColorHex: "#34C759", name: "Salary", category: "Income", amount: 2500.0)
        ]
    }
    static func generateSampleBudgets(colors: [Color]) -> [BudgetStatusItem] {
        return [
            BudgetStatusItem(categoryName: "Groceries", budgetedAmount: 300, spentAmount: 130, accentColor: colors[0 % colors.count]),
            BudgetStatusItem(categoryName: "Dining Out", budgetedAmount: 200, spentAmount: 250, accentColor: colors[1 % colors.count]),
            BudgetStatusItem(categoryName: "Utilities", budgetedAmount: 150, spentAmount: 80, accentColor: colors[2 % colors.count]),
        ]
    }
    static func generateSampleGoals(colors: [Color]) -> [FinancialGoal] {
         let calendar = Calendar.current
        return [
            FinancialGoal(name: "Emergency Fund", targetAmount: 5000, currentAmount: 2500, deadline: calendar.date(byAdding: .year, value: 1, to: Date()), iconName: "shield.lefthalf.filled", colorHex: colors[4 % colors.count].toHex() ?? "FFD700"), // Error was here
            FinancialGoal(name: "Dream Vacation", targetAmount: 3000, currentAmount: 2950, deadline: calendar.date(byAdding: .month, value: 2, to: Date()), iconName: "airplane", colorHex: colors[5 % colors.count].toHex() ?? "007BFF"), // And here
            FinancialGoal(name: "Completed Goal Example", targetAmount: 500, currentAmount: 500, deadline: calendar.date(byAdding: .month, value: -1, to: Date()), iconName: "star.fill", colorHex: Color.green.toHex() ?? "34C759") // And here
        ]
    }
}

// MARK: - Color toHex Extension
// Place this extension in a global Extensions.swift file or ensure it's accessible.
// If you already have this from previous steps, you don't need to redefine it.
// This is a simplified version. For production, a more robust solution might be needed.
extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            // Attempt to handle system colors like .blue, .green which might not have direct RGB components this way
            // This is a very basic fallback and might not work for all system colors or dynamic colors.
            // For a more robust solution, you might need to draw the color into a context to get its RGB.
            // For now, returning nil or a placeholder if direct components aren't available.
            // Or, ensure your 'categoryColors' and 'badge accentColors' are defined with Color(hex:) or Color(red:green:blue:)
            // print("Warning: Could not get RGB components for color \(self). This might be a system color.")
            // Fallback for some common system colors if needed for sample data only:
            if uic == UIColor.blue { return "007AFF" }
            if uic == UIColor.green { return "34C759" }
            if uic == UIColor.orange { return "FF9500" }
            // ... add more if necessary for sample data, but ideally define colors with RGB/Hex initially.
            return nil // Or a default hex like "000000"
        }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        // let a = components.count >= 4 ? Int(components[3] * 255.0) : 255 // Alpha
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
