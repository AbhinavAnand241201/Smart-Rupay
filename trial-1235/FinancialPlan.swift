//
//  FinancialPlanModels.swift
//  trial-1235
//
//
//
//  CORRECTED: Added Decodable conformance to all structs.
//

import SwiftUI

// Add `: Decodable` to allow this struct to be created from JSON
struct FinancialPlan: Identifiable, Decodable {
    let id = UUID()
    let emergencyFundPlan: PlanSection
    let budgetAllocationPlan: BudgetPlanSection
    let longTermGoalSuggestion: PlanSection
    
    // This tells the decoder how to match the JSON keys to your struct's properties.
    private enum CodingKeys: String, CodingKey {
        case emergencyFundPlan, budgetAllocationPlan, longTermGoalSuggestion
    }
}

// Add `: Decodable` here as well
struct PlanSection: Identifiable, Decodable {
    var id = UUID()
    let title: String
    let iconName: String
    let summary: String
    let steps: [String]
}

// Add `: Decodable` here as well
struct BudgetPlanSection: Identifiable, Decodable {
    var id = UUID()
    let title: String
    let iconName: String
    let summary: String
    let allocations: [BudgetAllocation]
}

// Add `: Decodable` here as well
struct BudgetAllocation: Identifiable, Decodable {
    var  id = UUID()
    let category: String
    let percentage: Double
    let amount: Double
    let colorHex: String // We expect a hex string like "#RRGGBB" from the server

    // This computed property translates the hex string into a SwiftUI Color
    var color: Color {
        Color(hex: colorHex)
    }
    
    // This maps the "color" key from your JSON to the "colorHex" property in this struct
    private enum CodingKeys: String, CodingKey {
        case category, percentage, amount, colorHex = "color"
    }
}
