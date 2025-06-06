// RupayOracleView 2.swift
// Smart-Rupay App - Phase 2 UI Updates - Corrected

//
//  RupayOracleView 2.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 05/06/25.
//


// RupayOracleView.swift
// Smart-Rupay App - Phase 2 UI Updates

import SwiftUI

struct RupayOracleView: View {
    @StateObject private var viewModel: RupayOracleViewModel
    
    // UI Colors
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0") // Assumes Color(hex:) is available
    let accentColorTeal = Color(hex: "3AD7D5") // Assumes Color(hex:) is available
    let headerTextColor = Color(hex: "BEBEBE") // For section headers within this view
    
    init(viewModel: RupayOracleViewModel = RupayOracleViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack {
                screenBackgroundColor.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 25) {
                        OverallWellnessScoreView(score: viewModel.overallWellnessScore, accentColor: accentColorTeal)
                            .padding(.top, 20)

                        VStack(alignment: .leading) {
                            Text("Average Monthly Income")
                                .font(.headline)
                                .foregroundColor(headerTextColor) // Use headerTextColor
                            HStack {
                                Text("$")
                                    .foregroundColor(mainTextColor)
                                TextField("Enter Income", text: $viewModel.averageMonthlyIncomeString)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(mainTextColor)
                                    .tint(accentColorTeal)
                                    .onSubmit(viewModel.recalculateWellnessMetrics)
                                Button("Update") {
                                    viewModel.recalculateWellnessMetrics()
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                .foregroundColor(accentColorTeal)
                            }
                            .padding()
                            .background(cardBackgroundColor)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)

                        VStack(spacing: 15) {
                             MetricCardView(
                                title: "Budget Adherence",
                                value: String(format: "%.0f%%", viewModel.budgetAdherenceScore),
                                interpretation: viewModel.budgetAdherenceScore > 75 ? "Great job!" : (viewModel.budgetAdherenceScore > 50 ? "Doing well" : "Room to improve"),
                                progress: viewModel.budgetAdherenceScore / 100.0,
                                color: getColorForScore(viewModel.budgetAdherenceScore)
                            )
                            MetricCardView(
                                title: "Emergency Fund",
                                value: String(format: "%.0f%% funded", viewModel.emergencyFundProgressScore),
                                interpretation: viewModel.emergencyFundProgressScore > 75 ? "Well prepared!" : (viewModel.emergencyFundProgressScore > 50 ? "Good progress" : "Keep building"),
                                progress: viewModel.emergencyFundProgressScore / 100.0,
                                color: getColorForScore(viewModel.emergencyFundProgressScore)
                            )
                             MetricCardView(
                                title: "Savings Rate",
                                value: String(format: "%.1f%%", viewModel.savingsRate),
                                interpretation: savingsRateInterpretation(viewModel.savingsRate),
                                progress: viewModel.savingsRateScore / 100.0,
                                color: getColorForScore(viewModel.savingsRateScore)
                            )
                            MetricCardView(
                                title: "Avg. Monthly Expenses",
                                value: String(format: "$%.2f", viewModel.averageMonthlyExpenses),
                                interpretation: "Based on last 30 days",
                                color: secondaryTextColor // Use secondaryTextColor as it's informational
                            )
                        }
                        .padding(.horizontal)

                        AchievementsView(badges: viewModel.badges.filter { $0.isAchieved })
                            .padding(.horizontal)

                        OracleTipView(tip: viewModel.oracleTip, accentColor: accentColorTeal)
                            .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("Rupay Oracle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Rupay Oracle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(mainTextColor)
                }
                 ToolbarItem(placement: .navigationBarTrailing) {
                    Button { viewModel.recalculateWellnessMetrics() } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(accentColorTeal)
                    }
                }
            }
            .onAppear { viewModel.recalculateWellnessMetrics() }
        }
        .preferredColorScheme(.dark)
    }
    
    func getColorForScore(_ score: Double) -> Color {
        if score >= 80 { return .green }
        if score >= 50 { return .yellow }
        return .orange
    }

    func savingsRateInterpretation(_ rate: Double) -> String {
        if rate >= 20 { return "Excellent! You're a super saver." }
        if rate >= 15 { return "Great! Solid saving habits." }
        if rate >= 10 { return "Good start! Keep building on it." }
        if rate >= 5 { return "Making progress! Every bit counts." }
        if rate > 0 { return "Saving something is better than nothing!"}
        if rate == 0 && viewModel.getAverageMonthlyIncome() > 0 { return "Aim to save something each month."}
        if viewModel.getAverageMonthlyIncome() <= 0 { return "Update income to see savings rate."}
        return "Consider ways to increase savings."
    }
}

// MARK: - Subviews for RupayOracleView (MUST BE INCLUDED)

struct OverallWellnessScoreView: View {
    let score: Double
    let accentColor: Color
    let mainTextColor = Color.white

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 15)
                    .opacity(0.2)
                    .foregroundColor(accentColor)

                Circle()
                    .trim(from: 0.0, to: CGFloat(min(score / 100.0, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    .foregroundColor(accentColor)
                    .rotationEffect(Angle(degrees: -90.0)) // Start from top
                    .animation(.interactiveSpring(), value: score)

                Text(String(format: "%.0f", score))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(mainTextColor)
            }
            .frame(width: 150, height: 150)
            
            Text("Financial Wellness")
                .font(.title3.weight(.semibold))
                .foregroundColor(mainTextColor)
                .padding(.top, 8)
        }
    }
}

struct MetricCardView: View {
    let title: String
    let value: String
    let interpretation: String?
    var progress: Double? = nil
    let color: Color

    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0") // Assumes Color(hex:) is available

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(mainTextColor)
                Spacer()
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundColor(color)
            }
            if let interpretation = interpretation, !interpretation.isEmpty {
                Text(interpretation)
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
            }
            if let progress = progress {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center) // Thicker progress bar
                    .clipShape(Capsule())
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(10)
    }
}

struct OracleTipView: View {
    let tip: String
    let accentColor: Color
    
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white


    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(accentColor)
                    .font(.title3)
                Text("Rupay Oracle's Tip")
                    .font(.headline)
                    .foregroundColor(accentColor)
            }
            Text(tip)
                .font(.subheadline)
                .foregroundColor(mainTextColor)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackgroundColor.opacity(0.85)) // Slightly different opacity
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(accentColor.opacity(0.6), lineWidth: 1)
        )
    }
}

struct AchievementsView: View {
    let badges: [Badge]
    
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18) // Standard card bg
    let mainTextColor = Color.white
    let headerTextColor = Color(hex: "BEBEBE") // Brighter gray for header

    var body: some View {
        if !badges.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Your Achievements")
                    .font(.headline)
                    .foregroundColor(headerTextColor) // Use specific header text color
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(badges) { badge in
                            VStack(spacing: 6) {
                                Image(systemName: badge.isAchieved ? badge.achievedIconName : badge.iconName)
                                    .font(.system(size: 28)) // Badge icon size
                                    .foregroundColor(badge.isAchieved ? badge.accentColor : Color.gray.opacity(0.4))
                                    .frame(width: 55, height: 55) // Consistent frame for icon part
                                    .background(
                                        (badge.isAchieved ? badge.accentColor : Color.gray)
                                            .opacity(0.1) // Softer background
                                            .clipShape(Circle())
                                    )
                                
                                Text(badge.name)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(mainTextColor)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 70) // Width for text below icon
                                
                                if badge.isAchieved, let date = badge.achievedDate {
                                     Text(date.formatted(.dateTime.month().day())) // Shorter date format
                                        .font(.caption2)
                                        .foregroundColor(Color(hex:"A0A0A0"))
                                } else if !badge.isAchieved {
                                    Text("Locked") // Placeholder for unachieved
                                        .font(.caption2)
                                        .foregroundColor(Color.gray.opacity(0.6))
                                }
                            }
                            .padding(10)
                            .frame(width: 90) // Overall width for each badge item card
                            .background(cardBackgroundColor.opacity(0.7))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 5) // Padding for the scroll content
                }
            }
        } else {
            // Optionally show a placeholder if no badges are achieved yet but badges array is not empty
            // Or simply EmptyView if you only want to show achieved badges.
            EmptyView()
        }
    }
}

// MARK: - Preview
struct RupayOracleView_Previews_Phase2: PreviewProvider {
    static var previews: some View {
        let sampleViewModel = RupayOracleViewModel(
            sampleTransactions: RupayOracleViewModel.generateSampleTransactions(),
            sampleBudgets: RupayOracleViewModel.generateSampleBudgets(colors: [Color.blue, Color.green, Color.orange]),
            sampleGoals: RupayOracleViewModel.generateSampleGoals(colors: [Color.purple, Color.pink])
        )
        sampleViewModel.averageMonthlyIncomeString = "6000"
        sampleViewModel.recalculateWellnessMetrics() // Ensure metrics are calculated for preview

        return RupayOracleView(viewModel: sampleViewModel)
    }
}
