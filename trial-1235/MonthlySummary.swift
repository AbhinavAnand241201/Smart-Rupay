// In the file containing SpendingAnalysisScreenView

import SwiftUI
import Charts

// MARK: - Data Models
// Models are kept here for self-containment, but could be moved to a shared file.
struct MonthlySummary: Identifiable {
    let id = UUID()
    let month: String
    let income: Double
    let expenses: Double
    var netSavings: Double { income - expenses }
}
// In MonthlySummary.swift, replace the old CategorySpending struct with this one

struct CategorySpending: Identifiable, Equatable, Hashable  {
    let id = UUID()
    let categoryName: String
    var spentAmount: Double
    let color: Color

    // This function tells Swift to use the 'id' for Hashing,
    // which is all that's needed to make the struct Plottable.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct BudgetPerformance: Identifiable {
    let id = UUID()
    let categoryName: String
    let budgetedAmount: Double
    var spentAmount: Double
    let color: Color
    var overBudget: Bool { spentAmount > budgetedAmount }
    var progress: Double { budgetedAmount > 0 ? min(spentAmount / budgetedAmount, 1.0) : 0 }
}

enum AnalysisPeriod: String, CaseIterable, Identifiable {
    case currentMonth = "This Month"
    case last3Months = "Last 3 Months"
    case yearToDate = "Year to Date"
    var id: String { self.rawValue }
}


// MARK: - Main View
struct SpendingAnalysisScreenView: View {
    @State private var selectedPeriod: AnalysisPeriod = .currentMonth
    @State private var selectedCategory: CategorySpending?
    
    // MARK: - Rich Mock Data
    private let monthlySummaryData: [MonthlySummary] = [
        .init(month: "Current", income: 120000, expenses: 75000)
    ]

    private let categorySpendingData: [CategorySpending] = [
        .init(categoryName: "Shopping", spentAmount: 18000, color: Color.App.accentPink),
        .init(categoryName: "Dining Out", spentAmount: 12500, color: Color.App.accentOrange),
        .init(categoryName: "Groceries", spentAmount: 22000, color: Color.App.accentGreen),
        .init(categoryName: "Transport", spentAmount: 8500, color: Color.App.accentPurple),
        .init(categoryName: "Utilities", spentAmount: 14000, color: Color.App.accentBlue)
    ]

    private let budgetPerformanceData: [BudgetPerformance] = [
        .init(categoryName: "Groceries", budgetedAmount: 20000, spentAmount: 22000, color: Color.App.accentGreen),
        .init(categoryName: "Dining Out", budgetedAmount: 15000, spentAmount: 12500, color: Color.App.accentOrange),
        .init(categoryName: "Shopping", budgetedAmount: 25000, spentAmount: 18000, color: Color.App.accentPink)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.App.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Using our modern custom segmented control
                        AnalysisPeriodPicker(selection: $selectedPeriod)
                        
                        // Each analysis section is a redesigned card
                        IncomeVsExpenseCard(summary: monthlySummaryData.first!)
                        
                        SpendingByCategoryCard(
                            spendingData: categorySpendingData,
                            selectedCategory: $selectedCategory
                        )
                        
                        BudgetPerformanceCard(performanceData: budgetPerformanceData)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Spending Analysis")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Analysis Card Subviews

private struct IncomeVsExpenseCard: View {
    let summary: MonthlySummary
    
    var body: some View {
        AnalysisCardView(title: "Income vs. Expenses") {
            Chart {
                BarMark(
                    x: .value("Category", "Income"),
                    y: .value("Amount", summary.income)
                )
                .foregroundStyle(Color.App.accentGreen.gradient)
                .cornerRadius(8)
                
                BarMark(
                    x: .value("Category", "Expenses"),
                    y: .value("Amount", summary.expenses)
                )
                .foregroundStyle(Color.App.accentPink.gradient)
                .cornerRadius(8)
            }
            .chartYAxis {
                AxisMarks(preset: .automatic, position: .leading) {
                    AxisGridLine().foregroundStyle(Color.App.textSecondary.opacity(0.2))
                    AxisValueLabel().foregroundStyle(Color.App.textSecondary)
                }
            }
            .chartXAxis {
                AxisMarks() {
                    AxisValueLabel().foregroundStyle(Color.App.textSecondary)
                }
            }
            .frame(height: 200)
            
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Net Savings")
                        .font(.headline)
                        .foregroundColor(Color.App.textSecondary)
                    Text("₹\(Int(summary.netSavings))")
                        .font(.title.bold())
                        .foregroundColor(summary.netSavings >= 0 ? .App.accentGreen : .App.accentPink)
                }
            }
            .padding(.top, 8)
        }
    }
}

private struct SpendingByCategoryCard: View {
    let spendingData: [CategorySpending]
    @Binding var selectedCategory: CategorySpending?
    
    var totalSpending: Double {
        spendingData.reduce(0) { $0 + $1.spentAmount }
    }
    
    var body: some View {
        AnalysisCardView(title: "Spending by Category") {
            Chart(spendingData) { data in
                SectorMark(
                    angle: .value("Amount", data.spentAmount),
                    innerRadius: .ratio(0.65),
                    angularInset: 1.5
                )
                .foregroundStyle(data.color.gradient)
                .cornerRadius(5)
                .opacity(selectedCategory == nil ? 1.0 : (selectedCategory == data ? 1.0 : 0.5))
            }
            .chartAngleSelection(value: $selectedCategory)
            .frame(height: 200)
            .chartOverlay { _ in
                VStack {
                    Text(selectedCategory?.categoryName ?? "Total Spent")
                        .font(.headline)
                        .foregroundColor(Color.App.textSecondary)
                    Text("₹\(Int(selectedCategory?.spentAmount ?? totalSpending))")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(selectedCategory?.color ?? .App.textPrimary)
                }
            }
            .padding(.bottom)

            VStack(spacing: 12) {
                ForEach(spendingData) { data in
                    HStack {
                        Circle().fill(data.color).frame(width: 12, height: 12)
                        Text(data.categoryName).foregroundColor(Color.App.textPrimary)
                        Spacer()
                        Text("₹\(Int(data.spentAmount))")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color.App.textSecondary)
                    }
                }
            }
        }
    }
}

private struct BudgetPerformanceCard: View {
    let performanceData: [BudgetPerformance]
    
    var body: some View {
        AnalysisCardView(title: "Budget Performance") {
            VStack(spacing: 16) {
                ForEach(performanceData) { budget in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(budget.categoryName)
                                .font(.headline)
                                .foregroundColor(Color.App.textPrimary)
                            Spacer()
                            Text("₹\(Int(budget.spentAmount)) / ₹\(Int(budget.budgetedAmount))")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(budget.overBudget ? Color.App.accentPink : Color.App.textSecondary)
                        }
                        ProgressView(value: budget.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: budget.overBudget ? Color.App.accentPink : budget.color))
                            .scaleEffect(x: 1, y: 2.5, anchor: .center)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}


// MARK: - Reusable Helper Views

// A generic card container to keep styling consistent
struct AnalysisCardView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(Color.App.textPrimary)
            
            content
        }
        .padding(20)
        .background(Color.App.card)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}



// Add this new view to the bottom of your MonthlySummary.swift file

struct AnalysisPeriodPicker: View {
    @Binding var selection: AnalysisPeriod
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AnalysisPeriod.allCases) { period in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selection = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if selection == period {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.App.card)
                                    .matchedGeometryEffect(id: "selection", in: namespace)
                                    .shadow(radius: 3)
                            }
                        }
                        .foregroundColor(selection == period ? Color.App.textPrimary : Color.App.textSecondary)
                }
            }
        }
        .padding(6)
        .background(Color.App.background)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.App.card, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}


// MARK: - Preview
struct SpendingAnalysisScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SpendingAnalysisScreenView()
            .preferredColorScheme(.dark)
    }
}
