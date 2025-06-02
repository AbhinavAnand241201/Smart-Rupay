//
//  Transaction.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 02/06/25.
//


import SwiftUI

// MARK: - Data Models (Placeholder)
struct Transaction: Identifiable {
    let id = UUID()
    let iconName: String
    let name: String
    let amount: Double
    var isCredit: Bool { amount > 0 }
}

struct BudgetItem: Identifiable {
    let id = UUID()
    let category: String
    let spent: Double
    let total: Double
    var progress: Double { spent / total }
}

// MARK: - Main ContentView
struct ContentView: View {
    @State private var selectedTab: Tab = .overview

    init() {
        // Customize TabView appearance
        UITabBar.appearance().backgroundColor = UIColor(Color.black.opacity(0.8)) // Slightly more translucent black
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().barTintColor = UIColor.black // For the bar itself
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.09, blue: 0.10) // Dark background color from screenshot
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if selectedTab == .overview {
                    OverviewScreen()
                } else if selectedTab == .transactions {
                    // Placeholder for Transactions Screen
                    Text("Transactions Screen")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if selectedTab == .budget {
                    // Placeholder for Budget Screen
                    Text("Budget Screen")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if selectedTab == .goals {
                    // Placeholder for Goals Screen
                    Text("Goals Screen")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if selectedTab == .profile {
                    // Placeholder for Profile Screen
                    Text("Profile Screen")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Spacer() // Pushes content to the top

                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard) // Ensure content doesn't hide behind keyboard
        }
        .preferredColorScheme(.dark) // Apply dark mode
    }
}

// MARK: - Overview Screen
struct OverviewScreen: View {
    // Sample Data
    let checkingAmount = 2345.67
    let savingsAmount = 10500.00

    let recentTransactions: [Transaction] = [
        Transaction(iconName: "cart.fill", name: "Grocery Store", amount: -75.23),
        Transaction(iconName: "cup.and.saucer.fill", name: "Coffee Shop", amount: -5.50),
        Transaction(iconName: "dollarsign.circle.fill", name: "Paycheck", amount: 1500.00)
    ]

    let budgetItems: [BudgetItem] = [
        BudgetItem(category: "Food", spent: 270, total: 300), // Approx 90%
        BudgetItem(category: "Entertainment", spent: 280, total: 400), // Approx 70%
        BudgetItem(category: "Transportation", spent: 35, total: 100) // Approx 35%
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        // Hamburger menu action
                        print("Menu tapped")
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Overview")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    // To balance the hamburger icon, you could add an invisible element or another icon if needed
                    Image(systemName: "line.horizontal.3")
                        .font(.title2)
                        .opacity(0) // Hidden but takes space
                }
                .padding(.horizontal)
                .padding(.top, 10) // Adjusted top padding

                // Profile Section
                HStack(spacing: 15) {
                    Image("ab1") // Replace "sophia_avatar" with your actual image asset name
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))


                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sophia")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Text("AI Financial Advisor")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Accounts Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Accounts")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    AccountCardView(
                        iconName: "building.columns.fill",
                        accountType: "Checking",
                        amount: checkingAmount
                    )

                    AccountCardView(
                        iconName: "creditcard.fill", // Using a different icon for savings as per typical UI
                        accountType: "Savings",
                        amount: savingsAmount
                    )
                }
                .padding(.top)


                // Recent Transactions Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Transactions")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    ForEach(recentTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
                .padding(.top)

                // Budget Summary Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Budget Summary")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    ForEach(budgetItems) { item in
                        BudgetRowView(item: item)
                    }
                }
                .padding(.top)
                .padding(.bottom, 80) // Space for the tab bar
            }
        }
    }
}

// MARK: - Reusable Components

struct AccountCardView: View {
    let iconName: String
    let accountType: String
    let amount: Double

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.9)) // Icon color
                .frame(width: 30, height: 30) // Consistent icon size

            VStack(alignment: .leading) {
                Text(accountType)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Text(String(format: "$%.2f", amount))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
        .background(Color(red: 0.12, green: 0.13, blue: 0.15)) // Card background
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: transaction.iconName)
                .font(.system(size: 18))
                .foregroundColor(transaction.isCredit ? .green : Color(red: 0.8, green: 0.8, blue: 0.8))
                .frame(width: 30, height: 30)
                .background(Color(red: 0.15, green: 0.16, blue: 0.18)) // Icon background circle
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(transaction.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                // You might want to add a date or category here if available
            }
            Spacer()
            Text(String(format: "%@$%.2f", transaction.isCredit ? "+" : "-", abs(transaction.amount)))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.isCredit ? .green : .white)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct BudgetRowView: View {
    let item: BudgetItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(item.category)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Text(String(format: "$%.0f", item.total)) // Showing total budget amount
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }

            ProgressView(value: item.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: getProgressColor(for: item.category)))
                .frame(height: 8) // Adjusted height for thickness
                .scaleEffect(x: 1, y: 2.5, anchor: .center) // Makes the bar thicker
                .clipShape(Capsule()) // Rounded ends for the progress bar track
                .padding(.top, 2)

        }
        .padding(.horizontal)
    }

    // Helper to get different colors for budget categories if needed
    func getProgressColor(for category: String) -> Color {
        switch category {
        case "Food":
            return Color(red: 0.4, green: 0.8, blue: 0.6) // A greenish color
        case "Entertainment":
            return Color(red: 0.9, green: 0.7, blue: 0.3) // An orangeish color
        case "Transportation":
            return Color(red: 0.3, green: 0.6, blue: 0.9) // A blueish color
        default:
            return .accentColor
        }
    }
}

// MARK: - Custom Tab Bar
enum Tab: String, CaseIterable {
    case overview = "house.fill"
    case transactions = "list.bullet"
    case budget = "chart.pie.fill"
    case goals = "target"
    case profile = "person.fill"

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .transactions: return "Transactions"
        case .budget: return "Budget"
        case .goals: return "Goals"
        case .profile: return "Profile"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    private let tabBarHeight: CGFloat = 65 // Adjusted height

    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: tab.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(selectedTab == tab ? .white : .gray)

                    Text(tab.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(selectedTab == tab ? .white : .gray)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle()) // Makes the whole area tappable
                .onTapGesture {
                    selectedTab = tab
                }
                Spacer()
            }
        }
        .frame(height: tabBarHeight)
        .padding(.bottom, 15) // Padding for home indicator area if any
        .background(Color(red: 0.12, green: 0.13, blue: 0.15)) // Tab bar background
        .edgesIgnoringSafeArea(.bottom) // Extend to the bottom edge
    }
}


// MARK: - Preview
#Preview {
    ContentView()
}
