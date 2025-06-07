//
//  FinancialPlan.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 07/06/25.
//


//
//  FinancialPlanModels.swift
//  trial-1235
//
//  Created by Gemini AI on 07/06/25.
//

import SwiftUI

// The main structure for the entire plan
struct FinancialPlan: Identifiable {
    let id = UUID()
    let emergencyFundPlan: PlanSection
    let budgetAllocationPlan: BudgetPlanSection
    let longTermGoalSuggestion: PlanSection
}

// A generic section for text-based advice
struct PlanSection: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let summary: String
    let steps: [String]
}

// A special section for the budget breakdown
struct BudgetPlanSection: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let summary: String
    let allocations: [BudgetAllocation]
}

// Represents a single slice of the budget pie (e.g., "Needs")
struct BudgetAllocation: Identifiable {
    let id = UUID()
    let category: String
    let percentage: Double
    let amount: Double
    let color: Color
}