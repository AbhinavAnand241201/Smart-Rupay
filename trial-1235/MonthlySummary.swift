import SwiftUI
import Charts // Ensure Charts is imported
//trying to resolve some issues here , will do it tmr.

struct MonthlySummary: Identifiable {
    let id = UUID()
    let month: String
    let income: Double
    let expenses: Double
    var netSavings: Double { income - expenses }
}

struct CategorySpending: Identifiable {
    let id = UUID()
    let categoryName: String
    var spentAmount: Double
    let color: Color
}

struct BudgetPerformance: Identifiable {
    let id = UUID()
    let categoryName: String
    let budgetedAmount: Double
    var spentAmount: Double
    let color: Color
    var overBudget: Bool { spentAmount > budgetedAmount }
    var progress: Double { budgetedAmount > 0 ? min(spentAmount / budgetedAmount, 1.2) : 0 }
}

enum AnalysisPeriod: String, CaseIterable, Identifiable {
    case currentMonth = "This Month"
    case last3Months = "Last 3 Months"
    case yearToDate = "Year to Date"
    var id: String { self.rawValue }
}

struct SpendingAnalysisScreenView: View {
    @State private var selectedPeriod: AnalysisPeriod = .currentMonth

    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")

    let categoryColors = [
        Color(hex: "FF3399"), Color.orange, Color(hex: "39FF14"),
        Color(hex: "007BFF"), Color(hex: "FFD700"), Color(hex: "BF00FF"),
        Color(hex: "FF4500")
    ]
    
    // MARK: - Sample Data
    @State private var monthlySummaryData: [MonthlySummary] = [
        MonthlySummary(month: "Current", income: 5200, expenses: 3150)
    ]

    @State private var categorySpendingData: [CategorySpending] = [
        CategorySpending(categoryName: "Groceries", spentAmount: 800, color: Color(hex: "FF3399")),
        CategorySpending(categoryName: "Dining Out", spentAmount: 650, color: Color.orange),
        CategorySpending(categoryName: "Transport", spentAmount: 300, color: Color(hex: "39FF14")),
        CategorySpending(categoryName: "Entertainment", spentAmount: 450, color: Color(hex: "007BFF")),
        CategorySpending(categoryName: "Shopping", spentAmount: 500, color: Color(hex: "FFD700")),
        CategorySpending(categoryName: "Utilities", spentAmount: 350, color: Color(hex: "BF00FF")),
        CategorySpending(categoryName: "Other", spentAmount: 100, color: Color(hex: "FF4500"))
    ]

    @State private var budgetPerformanceData: [BudgetPerformance] = [
        BudgetPerformance(categoryName: "Groceries", budgetedAmount: 700, spentAmount: 800, color: Color(hex: "FF3399")),
        BudgetPerformance(categoryName: "Dining Out", budgetedAmount: 500, spentAmount: 650, color: Color.orange),
        BudgetPerformance(categoryName: "Entertainment", budgetedAmount: 400, spentAmount: 450, color: Color(hex: "007BFF"))
    ]

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            screenBackgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Navigation Bar
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(mainTextColor)
                    }
                    Spacer()
                    Text("Spending Analysis")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(mainTextColor)
                    Spacer()
                    Image(systemName: "arrow.left").opacity(0)
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 15)

                // MARK: - Period Selector
                Picker("Select Period", selection: $selectedPeriod) {
                    ForEach(AnalysisPeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 25) {
                        AnalysisCardView(title: "Income vs Expenses") {
                            if let currentSummary = monthlySummaryData.first {
                                Chart {
                                    BarMark(x: .value("Category", "Income"), y: .value("Amount", currentSummary.income))
                                        .foregroundStyle(accentColorTeal)
                                        .cornerRadius(6)
                                    BarMark(x: .value("Category", "Expenses"), y: .value("Amount", currentSummary.expenses))
                                        .foregroundStyle(categoryColors[1]) // Orange for expenses
                                        .cornerRadius(6)
                                }
                                .chartYAxis {
                                    AxisMarks(preset: .automatic, position: .leading) { value in
                                        AxisGridLine().foregroundStyle(secondaryTextColor.opacity(0.3))
                                        AxisTick().foregroundStyle(secondaryTextColor.opacity(0.5))
                                        AxisValueLabel().foregroundStyle(secondaryTextColor)
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(preset: .automatic) { value in
                                        AxisGridLine().foregroundStyle(secondaryTextColor.opacity(0.3))
                                        AxisTick().foregroundStyle(secondaryTextColor.opacity(0.5))
                                        AxisValueLabel().foregroundStyle(secondaryTextColor)
                                    }
                                }
                                .frame(height: 200)
                                .accessibilityLabel("Bar chart showing income of \(currentSummary.income, specifier: "%.0f") and expenses of \(currentSummary.expenses, specifier: "%.0f")")
                                
                                HStack {
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("Net Savings")
                                            .font(.caption)
                                            .foregroundColor(secondaryTextColor)
                                        Text(String(format: "$%.2f", currentSummary.netSavings))
                                            .font(.title3.bold())
                                            .foregroundColor(currentSummary.netSavings >= 0 ? accentColorTeal : categoryColors[6])
                                    }
                                }
                                .padding(.top, 5)
                            }
                        }

                        AnalysisCardView(title: "Spending by Category") {
                            HStack(spacing: 15) {
                                Chart(categorySpendingData) { data in
                                    SectorMark(
                                        angle: .value("Amount", data.spentAmount),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle(data.color)
                                    .cornerRadius(5)
                                    .accessibilityLabel("\(data.categoryName): \(data.spentAmount, specifier: "%.0f") dollars")
                                }
                                .frame(width: 150, height: 150)
                                
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(categorySpendingData) { data in
                                            HStack {
                                                Circle().fill(data.color).frame(width: 10, height: 10)
                                                Text(data.categoryName)
                                                    .font(.caption)
                                                    .foregroundColor(mainTextColor)
                                                Spacer()
                                                Text(String(format: "$%.0f", data.spentAmount))
                                                    .font(.caption.weight(.medium))
                                                    .foregroundColor(secondaryTextColor)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 150)
                            }
                        }

                        // MARK: - Budget vs Actual Spending
                        AnalysisCardView(title: "Budget Performance") {
                            VStack(spacing: 15) {
                                ForEach(budgetPerformanceData) { budgetItem in
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(budgetItem.categoryName)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundColor(mainTextColor)
                                            Spacer()
                                            Text(String(format: "$%.0f / $%.0f", budgetItem.spentAmount, budgetItem.budgetedAmount))
                                                .font(.caption)
                                                .foregroundColor(budgetItem.overBudget ? categoryColors[6] : secondaryTextColor)
                                        }
                                        ProgressView(value: budgetItem.progress)
                                            .progressViewStyle(LinearProgressViewStyle(tint: budgetItem.overBudget ? categoryColors[6] : budgetItem.color))
                                            .scaleEffect(x: 1, y: 2.5, anchor: .center)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        Spacer(minLength: 20)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct AnalysisCardView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(mainTextColor)
                .padding(.bottom, 4)
            
            content
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SpendingAnalysisScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SpendingAnalysisScreenView()
        }
    }
}
