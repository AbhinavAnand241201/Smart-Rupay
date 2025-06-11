// In file: BudgetsScreenView.swift

import SwiftUI

// MARK: - Main Screen View
struct BudgetsScreenView: View {
    // We will use the ViewModel to load our new mock data
    @StateObject private var viewModel = BudgetViewModel()
    @State private var isPresentingAddSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                // Use a standard background color for consistency
                Color.App.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Header
                    // A prominent header for clear hierarchy, inspired by your examples
                    Text("Monthly Budgets")
                        .font(.largeTitle.bold())
                        .foregroundColor(Color.App.textPrimary)
                        .padding(.horizontal)
                        .padding(.top, 5) // Add padding for visual space
                        .padding(.bottom, 10)

                    // MARK: - Budgets List
                    // Using a ScrollView gives us more control over spacing than a List
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.budgets) { budget in
                                BudgetCategoryRow(item: budget)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        // Add padding at the bottom to ensure the last card doesn't stick to the button
                        .padding(.bottom, 120)
                    }
                }
                .padding(.top)
            }
            .overlay(alignment: .bottom) {
                // MARK: - Redesigned "Add Budget" Button
                // This design is inspired by the buttons in your examples
                Button(action: { isPresentingAddSheet.toggle() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Add New Budget")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.App.accent)
                    .cornerRadius(20) // Softer, more modern corner radius
                    .shadow(color: Color.App.accent.opacity(0.4), radius: 10, y: 5) // Subtle glow effect
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isPresentingAddSheet) {
                AddBudgetView()
                    .environmentObject(viewModel)
            }
        }
    }
}


// MARK: - The Re-designed Budget Row (The "Card")
// This new view transforms the simple row into a modern data card.
struct BudgetCategoryRow: View {
    let item: BudgetItem
    
    // Check if the budget is overspent to change the color
    var isOverBudget: Bool {
        item.spentAmount > item.amount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Header Section (Icon, Name, Percentage)
            HStack {
                // Icon styling inspired by your screenshots
                Image(systemName: item.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(item.accentColor)
                    .frame(width: 44, height: 44)
                    .background(item.accentColor.opacity(0.15))
                    .clipShape(Circle())

                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.App.textPrimary)

                Spacer()

                Text("\(Int(item.progress * 100))%")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isOverBudget ? Color.App.accentPink : item.accentColor)
            }

            // MARK: - Progress Bar
            ProgressView(value: item.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: isOverBudget ? Color.App.accentPink : item.accentColor))
                .scaleEffect(x: 1, y: 2.5, anchor: .center) // Make the bar thicker
                .clipShape(Capsule())

            // MARK: - Footer Section (Amount details)
            HStack {
                Text("Spent: **₹\(Int(item.spentAmount))**")
                    .font(.caption)
                    .foregroundColor(Color.App.textSecondary)
                
                Spacer()
                
                Text("Budget: ₹\(Int(item.amount))")
                    .font(.caption)
                    .foregroundColor(Color.App.textSecondary)
            }
        }
        .padding()
        .background(Color.App.card) // Using our standard card color
        .cornerRadius(20) // A more modern, softer corner radius
    }
}


// MARK: - Preview
struct BudgetsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetsScreenView()
    }
}


// MARK: - Color Extension
// This extension is kept here as requested, allowing global access.
extension Color {
    // Pre-defined color palette for the app
    struct App {
        static let background = Color(hex: "#151618")
        static let card = Color(hex: "#26292E")
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "#A0A0A0")
        static let accent = Color(hex: "#3AD7D5")
        
        static let accentBlue = Color(hex: "#0A84FF")
        static let accentGreen = Color(hex: "#30D158")
        static let accentOrange = Color(hex: "##FF9F0A")
        static let accentPink = Color(hex: "#FF2D55")
        static let accentPurple = Color(hex: "#AF52DE")
    }

    // Your existing hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
