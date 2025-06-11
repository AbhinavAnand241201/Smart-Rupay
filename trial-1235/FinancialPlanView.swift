// In file: FinancialPlanView.swift

import SwiftUI
import Charts

// MARK: - Main View
struct FinancialPlanView: View {
    let plan: FinancialPlan
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // A more dynamic and radiant background, giving this screen its own identity
            RadialGradient(
                gradient: Gradient(colors: [Color.App.accentBlue.opacity(0.3), Color.App.background]),
                center: .top,
                startRadius: 5,
                endRadius: 900
            ).ignoresSafeArea()
            
            Color.App.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    header
                    
                    BudgetPlanCard(plan: plan.budgetAllocationPlan)
                    
                    PlanSectionCard(plan: plan.emergencyFundPlan, accentColor: Color.App.accentOrange)
                        
                    PlanSectionCard(plan: plan.longTermGoalSuggestion, accentColor: Color.App.accentGreen)
                        
                    disclaimer
                    
                    Color.clear.frame(height: 20)
                }
                .padding(.top, 20)
            }
        }
        .overlay(alignment: .topTrailing) {
            dismissButton
        }
    }
    
    // MARK: - Helper Views
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [Color.App.accent, Color.App.accentBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Spacer()
            }
            
            Text("Your Financial Blueprint")
                .font(.largeTitle).bold()
                .foregroundColor(Color.App.textPrimary)
            
            Text("An educational guide based on established financial principles.")
                .foregroundColor(Color.App.textSecondary)
        }
        .padding(.horizontal)
    }
    
    private var dismissButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.black, Color.App.textSecondary.opacity(0.8))
        }
        .padding()
    }
    
    private var disclaimer: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title3)
                .foregroundColor(Color.App.textSecondary)
            
            Text("Important: This is an AI-generated educational plan, not professional financial advice. Always consult with a certified financial advisor for personal guidance.")
                .font(.caption)
                .foregroundColor(Color.App.textSecondary)
                .lineSpacing(3)
        }
        .padding()
        .background(Color.App.card.opacity(0.5))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}


// MARK: - Plan Section Card (For Emergency Fund, Goals, etc.)
struct PlanSectionCard: View {
    let plan: PlanSection
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                Image(systemName: plan.iconName)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(accentColor)
                Text(plan.title)
                    .font(.title2).bold()
                    .foregroundColor(Color.App.textPrimary)
            }
            
            Text(plan.summary)
                .font(.subheadline)
                .foregroundColor(Color.App.textSecondary)
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(plan.steps, id: \.self) { step in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(accentColor)
                            .padding(.top, 4) // Align checkmark with first line of text
                        Text(try! AttributedString(markdown: step)) // Allows for **bold** text
                            .font(.subheadline)
                            .foregroundColor(Color.App.textPrimary)
                    }
                }
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.App.card)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}


// MARK: - Budget Plan Card (With Chart)
struct BudgetPlanCard: View {
    let plan: BudgetPlanSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                Image(systemName: plan.iconName)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(Color.App.accentPurple)
                Text(plan.title)
                    .font(.title2).bold()
                    .foregroundColor(Color.App.textPrimary)
            }
            
            Text(plan.summary)
                .font(.subheadline)
                .foregroundColor(Color.App.textSecondary)
                .lineSpacing(4)

            Chart(plan.allocations) { allocation in
                BarMark(
                    x: .value("Amount", allocation.amount),
                    y: .value("Category", "") // Hide Y-axis labels for a cleaner look
                )
                .foregroundStyle(allocation.color)
                .cornerRadius(8) // Modern rounded bars
                .annotation(position: .overlay, alignment: .leading, spacing: 8) {
                    Text(allocation.category)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
            }
            .chartLegend(.hidden) // Hide the legend
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(preset: .automatic, values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine(stroke: StrokeStyle(dash: [2, 3]))
                        .foregroundStyle(Color.App.textSecondary.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(Color.App.textSecondary)
                }
            }
            .frame(height: 150)
            .padding(.top, 5)
        }
        .padding()
        .background(Color.App.card)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}


// MARK: - Preview
struct FinancialPlanView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBudgetPlan = BudgetPlanSection(
            title: "Budget Allocation",
            iconName: "chart.pie.fill",
            summary: "The 50/30/20 rule is a popular framework for managing money. It divides your after-tax income into three categories.",
            allocations: [
                .init(category: "Needs", percentage: 0.5, amount: 50000, colorHex: "#0A84FF"),
                .init(category: "Wants", percentage: 0.3, amount: 30000, colorHex: "#AF52DE"),
                .init(category: "Savings", percentage: 0.2, amount: 20000, colorHex: "#30D158")
            ]
        )

        let sampleEmergencyPlan = PlanSection(
            title: "Emergency Fund",
            iconName: "shield.lefthalf.filled",
            summary: "This is a safety net for unexpected events. A common goal is to have 3-6 months of expenses saved.",
            steps: [
                "Your 3-month target is **₹90,000.00**.",
                "Open a separate High-Yield Savings Account for this.",
                "Automate a portion of your savings to this fund."
            ]
        )
        
        let sampleGoalPlan = PlanSection(
            title: "Long-Term Goals",
            iconName: "flag.checkered",
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

        FinancialPlanView(plan: samplePlan, onDismiss: {})
    }
}
