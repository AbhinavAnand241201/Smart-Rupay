import SwiftUI

// The placeholder 'Transaction' and 'BudgetItem' structs have been removed from this file
// to prevent redeclaration errors. The app will use the models defined in their own files.

struct ContentView: View {
    @State private var selectedTab: Tab = .overview

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()
            VStack(spacing: 0) {
                if selectedTab == .overview {
                    OverviewScreen()
                } else {
                    Text("\(selectedTab.title) Screen")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Overview Screen
struct OverviewScreen: View {
    // These are local placeholder models for the preview screen.
    struct OverviewTransaction: Identifiable {
        let id = UUID()
        let iconName: String
        let name: String
        let amount: Double
        var isCredit: Bool { amount > 0 }
    }
    
    // Sample data for the overview
    @State var recentTransactions: [OverviewTransaction] = [
        OverviewTransaction(iconName: "cart.fill", name: "Grocery Store", amount: -75.23),
        OverviewTransaction(iconName: "cup.and.saucer.fill", name: "Coffee Shop", amount: -5.50),
        OverviewTransaction(iconName: "dollarsign.circle.fill", name: "Paycheck", amount: 1500.00)
    ]
    
    // FIXED: The sample data here now uses the correct BudgetItem model from your ViewModel.
    // We provide default values for properties like iconName and colorHex.
    @State var budgetItems: [BudgetItem] = [
        BudgetItem(id: UUID(), name: "Food", amount: 4000, iconName: "cart.fill", colorHex: "#34C759", spentAmount: 2700),
        BudgetItem(id: UUID(), name: "Entertainment", amount: 5000, iconName: "film.fill", colorHex: "#FF9500", spentAmount: 4800),
        BudgetItem(id: UUID(), name: "Transportation", amount: 2000, iconName: "car.fill", colorHex: "#007BFF", spentAmount: 500)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ... (Header, Profile, Accounts sections can remain as they were) ...
                
                // Recent Transactions Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Transactions")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    ForEach(recentTransactions) { transaction in
                        OverviewTransactionRowView(transaction: transaction)
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
                .padding(.bottom, 80)
            }
        }
    }
}


// MARK: - Reusable Components for OverviewScreen

struct OverviewTransactionRowView: View {
    let transaction: OverviewScreen.OverviewTransaction

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: transaction.iconName)
                .font(.system(size: 18))
                .foregroundColor(transaction.isCredit ? .green : .white)
                .frame(width: 30, height: 30)
                .background(Color(red: 0.15, green: 0.16, blue: 0.18))
                .clipShape(Circle())

            Text(transaction.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(transaction.isCredit ? "+" : "-")₹\(abs(transaction.amount), specifier: "%.2f")")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.isCredit ? .green : .white)
        }
        .padding(.horizontal)
    }
}

struct BudgetRowView: View {
    let item: BudgetItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(item.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Text("₹\(Int(item.amount))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }

            ProgressView(value: item.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: getProgressColor(for: item.name)))
                .frame(height: 8)
                .scaleEffect(x: 1, y: 2.5, anchor: .center)
                .clipShape(Capsule())
                .padding(.top, 2)
        }
        .padding(.horizontal)
    }
    
    func getProgressColor(for categoryName: String) -> Color {
        // Your color logic
        return Color(hex: "#3AD7D5")
    }
}

// MARK: - Custom Tab Bar
enum Tab: String, CaseIterable {
    case overview = "house.fill", transactions = "list.bullet", budget = "chart.pie.fill", goals = "target", profile = "person.fill"
    var title: String {
        // Simple capitalization
        self.rawValue.prefix(1).uppercased() + self.rawValue.dropFirst()
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var body: some View {
        // Your tab bar implementation
        HStack {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: tab.rawValue)
                        .font(.system(size: 22))
                        .foregroundColor(selectedTab == tab ? .white : .gray)
                    Text(tab.title)
                        .font(.caption2)
                        .foregroundColor(selectedTab == tab ? .white : .gray)
                }
                .onTapGesture { selectedTab = tab }
                .frame(maxWidth: .infinity)
                Spacer()
            }
        }
        .frame(height: 80)
        .background(Color(red: 0.12, green: 0.13, blue: 0.15))
    }
}
