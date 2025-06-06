
//
//  BudgetCategoryItem.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 02/06/25.
//


import SwiftUI

// MARK: - Color Extension for Hex Values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black if hex is invalid
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Data Model for Budget Category
struct BudgetCategoryItem: Identifiable {
    let id = UUID()
    let iconName: String
    let categoryName: String
    let percentageOfBudget: Int
    let progressColor: Color
    let iconBackgroundColor: Color = Color(red: 0.15, green: 0.16, blue: 0.18) // Consistent icon bg
}

// MARK: - Budgets Screen View
struct BudgetsScreenView: View {
    // Define engaging colors
    let radiantPink = Color(hex: "FF3399")
    let vibrantOrange = Color.orange
    let neonGreen = Color(hex: "39FF14")
    let electricBlue = Color(hex: "007BFF")
    let vividYellow = Color(hex: "FFD700")
    let brightPurple = Color(hex: "BF00FF")
    let sunnyRed = Color(hex: "FF4500")


    // Sample Data for Budget Categories
    // Cycle through colors for variety
    var budgetItems: [BudgetCategoryItem] {
        let colors = [radiantPink, vibrantOrange, neonGreen, electricBlue, vividYellow, brightPurple, sunnyRed]
        return [
            BudgetCategoryItem(iconName: "cart.fill", categoryName: "Groceries", percentageOfBudget: 12, progressColor: colors[0]),
            BudgetCategoryItem(iconName: "fork.knife", categoryName: "Dining Out", percentageOfBudget: 35, progressColor: colors[1]),
            BudgetCategoryItem(iconName: "car.fill", categoryName: "Transportation", percentageOfBudget: 8, progressColor: colors[2]),
            BudgetCategoryItem(iconName: "movieclapper.fill", categoryName: "Entertainment", percentageOfBudget: 20, progressColor: colors[3]),
            BudgetCategoryItem(iconName: "creditcard.fill", categoryName: "Shopping", percentageOfBudget: 5, progressColor: colors[4]),
            BudgetCategoryItem(iconName: "message.fill", categoryName: "Utilities", percentageOfBudget: 15, progressColor: colors[5]),
            BudgetCategoryItem(iconName: "questionmark.circle.fill", categoryName: "Other", percentageOfBudget: 5, progressColor: colors[6])
        ]
    }

    let addBudetButtonColor = Color(hex: "3AD7D5") // Approximated from screenshot for the button

    var body: some View {
        ZStack {
            // Main background color
            Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: {
                        // Action for back button
                        print("Back button tapped")
                        // Add your navigation logic here (e.g., presentationMode.wrappedValue.dismiss())
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Budgets")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    // Invisible placeholder to keep title centered correctly
                    Image(systemName: "arrow.left").opacity(0)
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 20) // Space below nav bar

                // Section Title
                Text("Spending Categories")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.bottom, 15)

                // Budget Categories List
                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach(budgetItems) { item in
                            BudgetCategoryRow(item: item)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20) // Padding at the end of the list
                }

                Spacer() // Pushes button to the bottom if content is short

                // Add Budget Button
                Button(action: {
                    print("Add Budget tapped")
                    // Action for adding a new budget
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Add Budget")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(addBudetButtonColor)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30) // Padding from bottom edge or tab bar area
            }
        }
        .preferredColorScheme(.dark) // Ensure dark mode context
    }
}

// MARK: - Budget Category Row View
struct BudgetCategoryRow: View {
    let item: BudgetCategoryItem

    var body: some View {
        HStack(spacing: 15) {
            // Icon
            Image(systemName: item.iconName)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(item.iconBackgroundColor)
                .cornerRadius(10)

            // Category Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.categoryName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Text("\(item.percentageOfBudget)% of budget")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "A0A0A0")) // Subtitle gray
            }

            Spacer()

            // Progress Bar and Value
            HStack(spacing: 10) {
                ProgressView(value: Double(item.percentageOfBudget), total: 100.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: item.progressColor))
                    .frame(width: 70, height: 6) // Adjusted width and height for thinness
                    .clipShape(Capsule()) // Makes the progress bar track and fill rounded

                Text("\(item.percentageOfBudget)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 25, alignment: .trailing) // Fixed width for number alignment
            }
        }
    }
}

// MARK: - Preview
struct BudgetsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetsScreenView()
            // If this screen is part of a TabView, you might wrap it in MainAppView or similar
            // to see it in full context for preview.
            // For isolated preview:
            // .background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea())
    }
}
