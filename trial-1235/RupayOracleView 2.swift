// In file: RupayOracleView.swift

import SwiftUI

struct RupayOracleView: View {
    @StateObject private var viewModel: RupayOracleViewModel
    
    // Grid layout for the metric cards
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    init(viewModel: RupayOracleViewModel = RupayOracleViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.App.background.ignoresSafeArea()
                // A new, radiant background gradient
                RadialGradient(gradient: Gradient(colors: [Color.App.accentBlue.opacity(0.3), Color.App.background]), center: .topLeading, startRadius: 5, endRadius: 800)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        OverallWellnessScoreView(score: viewModel.overallWellnessScore)
                            .padding(.top, 20)
                        
                        // Using a grid for a more dynamic dashboard layout
                        LazyVGrid(columns: columns, spacing: 16) {
                            MetricCardView(metric: .budgetAdherence(viewModel.budgetAdherenceScore))
                            MetricCardView(metric: .emergencyFund(viewModel.emergencyFundProgressScore))
                            MetricCardView(metric: .savingsRate(viewModel.savingsRate))
                            MetricCardView(metric: .avgExpenses(viewModel.averageMonthlyExpenses))
                        }
                        .padding(.horizontal)
                        
                        AchievementsView(badges: viewModel.badges)
                            .padding(.horizontal)
                        
                        OracleTipView(tip: viewModel.oracleTip)
                            .padding(.horizontal)
                        
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Rupay Oracle")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { viewModel.recalculateWellnessMetrics() } label: { Image(systemName: "arrow.clockwise") }
                }
            }
            .accentColor(Color.App.accent)
        }
    }
}


// MARK: - Redesigned Subviews
private struct OverallWellnessScoreView: View {
    let score: Double
    
    var scoreColor: Color {
        if score >= 80 { return .App.accentGreen }
        if score >= 50 { return .App.accentOrange }
        return .App.accentPink
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.App.card.opacity(0.5))
                    .shadow(radius: 20)

                Circle()
                    .stroke(lineWidth: 12)
                    .opacity(0.2)
                    .foregroundColor(scoreColor)

                Circle()
                    .trim(from: 0.0, to: CGFloat(min(score / 100.0, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    .fill(scoreColor.gradient)
                    .rotationEffect(Angle(degrees: -90.0))
                    .shadow(color: scoreColor, radius: 10)

                Text(String(format: "%.0f", score))
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.App.textPrimary)
            }
            .frame(width: 180, height: 180)
            
            Text("Financial Wellness")
                .font(.title2.weight(.semibold))
        }
    }
}

// A new enum to make MetricCardView more reusable and powerful
enum FinancialMetric {
    case budgetAdherence(Double)
    case emergencyFund(Double)
    case savingsRate(Double)
    case avgExpenses(Double)
    
    var title: String {
        switch self {
        case .budgetAdherence: "Budget Adherence"
        case .emergencyFund: "Emergency Fund"
        case .savingsRate: "Savings Rate"
        case .avgExpenses: "Avg. Expenses"
        }
    }
    
    var valueString: String {
        switch self {
        case .budgetAdherence(let val): String(format: "%.0f%%", val)
        case .emergencyFund(let val): String(format: "%.0f%%", val)
        case .savingsRate(let val): String(format: "%.1f%%", val)
        case .avgExpenses(let val): "₹\(Int(val))"
        }
    }
    
    var progress: Double? {
        switch self {
        case .budgetAdherence(let val): val / 100.0
        case .emergencyFund(let val): val / 100.0
        case .savingsRate(let val): val / 20.0 // Assume 20% is a good target
        case .avgExpenses: nil
        }
    }
    
    var color: Color {
        let score: Double
        switch self {
        case .budgetAdherence(let val), .emergencyFund(let val), .savingsRate(let val):
            score = val
        case .avgExpenses: return .App.textSecondary
        }
        if score >= 80 || (self.title == "Savings Rate" && score >= 15) { return .App.accentGreen }
        if score >= 50 || (self.title == "Savings Rate" && score >= 5) { return .App.accentOrange }
        return .App.accentPink
    }
}


private struct MetricCardView: View {
    let metric: FinancialMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(metric.title)
                .font(.headline)
                .foregroundColor(.App.textSecondary)
            
            Spacer()
            
            Text(metric.valueString)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(metric.color)
            
            if let progress = metric.progress {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: metric.color))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .frame(height: 120)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial.opacity(0.8)) // Glassmorphism effect
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.App.textSecondary.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct OracleTipView: View {
    let tip: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.title2)
                .foregroundColor(Color.App.accentOrange)
                .shadow(color: Color.App.accentOrange, radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Rupay Oracle's Tip")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.App.textPrimary)
                Text(tip)
                    .font(.subheadline)
                    .foregroundColor(.App.textSecondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct AchievementsView: View {
    let badges: [Badge]
    var body: some View {
        // ... Code for this view can be enhanced similarly, this is a good start
        // To keep focus, this component's visual style is mostly preserved
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Achievements")
                .font(.title3.bold())
                .foregroundColor(.App.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(badges.filter { $0.isAchieved }) { badge in
                        VStack {
                            Image(systemName: badge.achievedIconName)
                                .font(.system(size: 28))
                                .foregroundColor(badge.accentColor)
                                .shadow(color: badge.accentColor, radius: 5)
                                .frame(width: 60, height: 60)
                                .background(badge.accentColor.opacity(0.15).clipShape(Circle()))
                            Text(badge.name)
                                .font(.caption.weight(.medium))
                                .foregroundColor(.App.textSecondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct RupayOracleView_Previews: PreviewProvider {
    static var previews: some View {
        RupayOracleView()
    }
}
