//
//  FinancialPlanView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 07/06/25.
//


//
//  FinancialPlanView.swift (previously OracleResponseView.swift)
//  trial-1235
//
//  Created by Gemini AI on 07/06/25.
//

import SwiftUI
import Charts

struct FinancialPlanView: View {
    let plan: FinancialPlan
    let onDismiss: () -> Void

    // UI Colors
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    
    var body: some View {
        ZStack {
            screenBackgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Financial Blueprint")
                            .font(.largeTitle).bold()
                            .foregroundColor(mainTextColor)
                        Text("An educational guide based on established financial principles.")
                            .foregroundColor(secondaryTextColor)
                    }
                    .padding([.horizontal, .top])

                    // MARK: - Budget Allocation Plan
                    BudgetPlanCard(plan: plan.budgetAllocationPlan)

                    // MARK: - Emergency Fund Plan
                    PlanSectionCard(plan: plan.emergencyFundPlan, accentColor: .blue)
                    
                    // MARK: - Long-Term Goal Suggestion
                    PlanSectionCard(plan: plan.longTermGoalSuggestion, accentColor: .green)
                    
                    // MARK: - Disclaimer
                    Text("Important: This is an AI-generated educational plan, not professional financial advice. Always consult with a certified financial advisor for personal guidance.")
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(cardBackgroundColor)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

// MARK: - Subviews for FinancialPlanView
struct PlanSectionCard: View {
    let plan: PlanSection
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                Image(systemName: plan.iconName)
                    .font(.title2)
                    .foregroundColor(accentColor)
                Text(plan.title)
                    .font(.title2).bold()
                    .foregroundColor(.white)
            }
            
            Text(plan.summary)
                .font(.subheadline)
                .foregroundColor(Color(hex: "A0A0A0"))
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(plan.steps, id: \.self) { step in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(accentColor)
                        Text(step)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color(red: 0.15, green: 0.16, blue: 0.18))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct BudgetPlanCard: View {
    let plan: BudgetPlanSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                Image(systemName: plan.iconName)
                    .font(.title2)
                    .foregroundColor(.purple)
                Text(plan.title)
                    .font(.title2).bold()
                    .foregroundColor(.white)
            }
            
            Text(plan.summary)
                .font(.subheadline)
                .foregroundColor(Color(hex: "A0A0A0"))
                .lineSpacing(4)

            Chart(plan.allocations) { allocation in
                BarMark(
                    x: .value("Amount", allocation.amount),
                    y: .value("Category", allocation.category)
                )
                .foregroundStyle(allocation.color)
                .annotation(position: .overlay, alignment: .center) {
                    Text(String(format: "%.0f%%", allocation.percentage * 100))
                        .font(.caption.bold())
                        .foregroundColor(.black)
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 120)
            .padding(.top)
        }
        .padding()
        .background(Color(red: 0.15, green: 0.16, blue: 0.18))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}


// MARK: - Preview
#Preview {
    // 1. Create sample data for the preview
    let sampleBudgetPlan = BudgetPlanSection(
        title: "Budget Allocation",
        iconName: "chart.pie.fill",
        summary: "The 50/30/20 rule is a popular framework for managing money. It divides your after-tax income into three categories.",
        allocations: [
            .init(category: "Needs", percentage: 0.5, amount: 2500, color: .blue),
            .init(category: "Wants", percentage: 0.3, amount: 1500, color: .orange),
            .init(category: "Savings", percentage: 0.2, amount: 1000, color: .green)
        ]
    )

    let sampleEmergencyPlan = PlanSection(
        title: "Emergency Fund",
        iconName: "shield.lefthalf.filled",
        summary: "This is a safety net for unexpected events. A common goal is to have 3-6 months of expenses saved.",
        steps: [
            "Your 3-month target is ₹90,000.00.",
            "Open a separate High-Yield Savings Account for this.",
            "Automate a portion of your savings to this fund."
        ]
    )
    
    let sampleGoalPlan = PlanSection(
        title: "Long-Term Goals",
        iconName: "flag.fill",
        summary: "Your savings from the 50/30/20 plan can be used to invest towards your long-term goals like 'buying a new car'.",
        steps: [
            "Define a target amount and timeline for your goal.",
            "Research low-cost, diversified investment options.",
            "Consider setting up automated investments (SIPs)."
        ]
    )

    let samplePlan = FinancialPlan(
        emergencyFundPlan: sampleEmergencyPlan,
        budgetAllocationPlan: sampleBudgetPlan,
        longTermGoalSuggestion: sampleGoalPlan
    )

    // 2. Return the view with the sample data
    return FinancialPlanView(plan: samplePlan, onDismiss: {
        print("Preview dismiss tapped.")
    })
}
