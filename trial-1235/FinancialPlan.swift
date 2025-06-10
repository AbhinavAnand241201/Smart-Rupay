
import SwiftUI

struct FinancialPlan: Identifiable, Decodable {
    let id = UUID()
    let emergencyFundPlan: PlanSection
    let budgetAllocationPlan: BudgetPlanSection
    let longTermGoalSuggestion: PlanSection
    
    private enum CodingKeys: String, CodingKey {
        case emergencyFundPlan, budgetAllocationPlan, longTermGoalSuggestion
    }
}

struct PlanSection: Identifiable, Decodable {
    var id = UUID()
    let title: String
    let iconName: String
    let summary: String
    let steps: [String]
}

struct BudgetPlanSection: Identifiable, Decodable {
    var id = UUID()
    let title: String
    let iconName: String
    let summary: String
    let allocations: [BudgetAllocation]
}

struct BudgetAllocation: Identifiable, Decodable {
    var  id = UUID()
    let category: String
    let percentage: Double
    let amount: Double
    let colorHex: String // We expect a hex string like "#RRGGBB" from the server

    var color: Color {
        Color(hex: colorHex)
    }
    
    private enum CodingKeys: String, CodingKey {
        case category, percentage, amount, colorHex = "color"
    }
}

