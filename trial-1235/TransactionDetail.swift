
// TransactionDetail.swift
// MODIFIED by Smart-Rupay App (via AI) to include Advanced Filtering

import SwiftUI

// Ensure Color(hex: String) extension is available globally (e.g., in BudgetCategoryItem.swift or an Extensions file)

// MARK: - Data Models for Transactions Screen
struct TransactionDetail: Identifiable, Hashable { // Added Hashable for ForEach
    let id = UUID()
    let date: Date // <<-- ADDED for date filtering and grouping
    let iconName: String
    let iconBackgroundColor: Color
    let name: String
    let category: String
    let amount: Double
    var isCredit: Bool { amount > 0 }

    // To conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: TransactionDetail, rhs: TransactionDetail) -> Bool {
        lhs.id == rhs.id
    }
}

struct TransactionSection: Identifiable {
    let id = UUID() // Can be the date string or a unique identifier for the section
    let title: String // e.g., "Today", "Yesterday", "June 2025"
    var transactions: [TransactionDetail]
}

// MARK: - Main App View (Tab Controller)
struct MainAppView: View {
    @State private var selectedTab: AppScreenTab = .transactions // Updated enum name

    // Create a flat list of all transactions with dates for filtering
    let allTransactionsForScreen: [TransactionDetail] = {
        var transactions: [TransactionDetail] = []
        let today = Date()
        let calendar = Calendar.current

        // Today's Transactions
        transactions.append(TransactionDetail(date: calendar.date(byAdding: .hour, value: -1, to: today)!, iconName: "cart.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "Whole Foods Market", category: "Groceries", amount: -120.00))
        transactions.append(TransactionDetail(date: calendar.date(byAdding: .hour, value: -3, to: today)!, iconName: "film.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "AMC Theatres", category: "Entertainment", amount: -30.00))
        transactions.append(TransactionDetail(date: calendar.date(byAdding: .hour, value: -5, to: today)!, iconName: "car.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "Uber", category: "Transportation", amount: -25.00))
        transactions.append(TransactionDetail(date: calendar.date(byAdding: .minute, value: -30, to: today)!, iconName: "creditcard.fill", iconBackgroundColor: Color(hex: "3AD7D5"), name: "Apple Store", category: "Shopping", amount: -999.00))


        // Yesterday's Transactions
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        transactions.append(TransactionDetail(date: calendar.date(byAdding: .hour, value: -10, to: yesterday)!, iconName: "fork.knife", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "The Italian Place", category: "Dining Out", amount: -75.00))
        transactions.append(TransactionDetail(date: calendar.date(byAdding: .hour, value: -14, to: yesterday)!, iconName: "archivebox.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "Amazon Electronics", category: "Shopping", amount: -50.00))
        transactions.append(TransactionDetail(date: calendar.date(byAdding: .hour, value: -9, to: yesterday)!, iconName: "dollarsign.circle.fill", iconBackgroundColor: Color(red: 0.2, green: 0.8, blue: 0.45), name: "Salary Deposit", category: "Salary", amount: 2500.00))

        // Transactions from 2 days ago
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        transactions.append(TransactionDetail(date: twoDaysAgo, iconName: "pills.fill", iconBackgroundColor: Color(hex: "BF00FF"), name: "Pharmacy", category: "Healthcare", amount: -45.50))
        transactions.append(TransactionDetail(date: twoDaysAgo, iconName: "graduationcap.fill", iconBackgroundColor: Color(hex: "007BFF"), name: "Online Course", category: "Education", amount: -199.00))


        // Transactions from last week
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
        transactions.append(TransactionDetail(date: lastWeek, iconName: "gift.fill", iconBackgroundColor: Color(hex: "FF3399"), name: "Birthday Gift", category: "Gifts", amount: -60.00))
        transactions.append(TransactionDetail(date: lastWeek, iconName: "wrench.and.screwdriver.fill", iconBackgroundColor: Color(hex: "FFD700"), name: "Car Repair", category: "Transportation", amount: -350.00))
        
        // Transactions from last month
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: today)!
        transactions.append(TransactionDetail(date: lastMonth, iconName: "house.fill", iconBackgroundColor: Color.orange, name: "Rent Payment", category: "Rent", amount: -1200.00))
        transactions.append(TransactionDetail(date: lastMonth, iconName: "lightbulb.fill", iconBackgroundColor: Color(hex: "BF00FF"), name: "Electricity Bill", category: "Utilities", amount: -75.00))


        return transactions.sorted(by: { $0.date > $1.date }) // Ensure newest are first for initial flat list
    }()

    init() {
        UITabBar.appearance().isHidden = true // Hides default TabView bar
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()

            VStack(spacing: 0) {
                switch selectedTab {
                case .home:
                    Text("Home Screen (Placeholder)").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
                case .transactions:
                    // Pass the flat list of all transactions
                    TransactionsScreenView(allTransactions: allTransactionsForScreen)
                case .aiAdvisor:
                     Text("AI Advisor Screen (Placeholder)").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
                case .settings:
                     Text("Settings Screen (Placeholder)").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
                // Add other cases for new tabs if AppScreenTab enum changes
                }
                AppCustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Transactions Screen View (MODIFIED)
struct TransactionsScreenView: View {
    let allTransactions: [TransactionDetail] // Receives all transactions

    @State private var activeFilters = TransactionFilterCriteria()
    @State private var showAdvancedFilters = false

    // MARK: - UI Colors
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")
    
    // Computed property to filter and group transactions
    var filteredAndGroupedTransactions: [TransactionSection] {
        var filtered = allTransactions

        // 1. Apply Search Term Filter
        if !activeFilters.searchTerm.isEmpty {
            let term = activeFilters.searchTerm.lowercased()
            filtered = filtered.filter {
                $0.name.lowercased().contains(term) || $0.category.lowercased().contains(term)
            }
        }

        // 2. Apply Transaction Type Filter
        switch activeFilters.transactionType {
        case .income:
            filtered = filtered.filter { $0.isCredit }
        case .expenses:
            filtered = filtered.filter { !$0.isCredit }
        case .all:
            break
        }

        // 3. Apply Category Filter
        if !activeFilters.selectedCategories.isEmpty {
            filtered = filtered.filter { activeFilters.selectedCategories.contains($0.category) }
        }
        
        // 4. Apply Amount Range Filter
        if let minAmount = Double(activeFilters.minAmount), minAmount > 0 {
            filtered = filtered.filter { abs($0.amount) >= minAmount }
        }
        if let maxAmount = Double(activeFilters.maxAmount), maxAmount > 0 {
             filtered = filtered.filter { abs($0.amount) <= maxAmount }
        }

        // 5. Apply Date Range Filter
        if let startDate = activeFilters.startDate {
            let startOfDay = Calendar.current.startOfDay(for: startDate)
            filtered = filtered.filter { $0.date >= startOfDay }
        }
        if let endDate = activeFilters.endDate {
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
            filtered = filtered.filter { $0.date <= endOfDay }
        }

        // 6. Group Filtered Transactions by Date
        let groupedDictionary = Dictionary(grouping: filtered) { transaction -> DateComponents in
            Calendar.current.dateComponents([.year, .month, .day], from: transaction.date)
        }

        let dateFormatter = DateFormatter()
        // In TransactionDetail.swift, inside filteredAndGroupedTransactions computed property:

        // ...
        return groupedDictionary.keys.sorted {
            // Ensure dates are non-optional for sorting, provide a fallback if necessary
            guard let date0 = Calendar.current.date(from: $0), let date1 = Calendar.current.date(from: $1) else {
                return false // Or handle this case based on your app's logic
            }
            return date0 > date1
        }.map { dateComponents -> TransactionSection in
            let date = Calendar.current.date(from: dateComponents)! // Should be safe due to previous guard or filter
            let title: String
            if Calendar.current.isDateInToday(date) {
                title = "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                title = "Yesterday"
            } else {
                dateFormatter.dateFormat = "MMMM d, yyyy" // Corrected format
                title = dateFormatter.string(from: date)
            }
            // REMOVED 'id' argument here:
            return TransactionSection(title: title, transactions: groupedDictionary[dateComponents] ?? [])
        }
        // ...
    }


    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: {
                    // Handle back navigation if this screen can be pushed
                    // For a tab screen, this might be different or not present
                    print("Back button in TransactionsScreen tapped")
                }) {
                    // Example: Use a different icon or no icon if it's a root tab view
                    Image(systemName: "line.3.horizontal") // Or an appropriate icon for a root view
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(mainTextColor)
                }
                .opacity(0) // Making it invisible if it's a root tab, for balance

                Spacer()
                Text("Transactions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(mainTextColor)
                Spacer()
                Button(action: { showAdvancedFilters = true }) {
                    Image(systemName: activeFilters.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.system(size: 22))
                        .foregroundColor(activeFilters.isActive ? accentColorTeal : mainTextColor)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(screenBackgroundColor)

            // Transactions List
            if filteredAndGroupedTransactions.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 50))
                        .foregroundColor(secondaryTextColor.opacity(0.5))
                        .padding(.bottom, 10)
                    Text(activeFilters.isActive ? "No Transactions Match Filters" : "No Transactions Yet")
                        .font(.headline)
                        .foregroundColor(secondaryTextColor)
                    if activeFilters.isActive {
                        Text("Try adjusting your search or filter criteria.")
                            .font(.subheadline)
                            .foregroundColor(secondaryTextColor.opacity(0.7))
                    } else {
                         Text("Add some transactions to see them here.")
                            .font(.subheadline)
                            .foregroundColor(secondaryTextColor.opacity(0.7))
                    }
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(filteredAndGroupedTransactions) { section in
                            Section {
                                ForEach(section.transactions) { transaction in
                                    TransactionListItemView(transaction: transaction)
                                        .padding(.horizontal)
                                        .padding(.vertical, 6) // Add a bit of vertical padding to rows
                                    if section.transactions.last != transaction {
                                        Divider().padding(.leading, 70).background(Color.gray.opacity(0.2)) // Custom divider
                                    }
                                }
                            } header: {
                                Text(section.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(secondaryTextColor)
                                    .padding(.horizontal)
                                    .padding(.top, 15)
                                    .padding(.bottom, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(screenBackgroundColor)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAdvancedFilters) {
            AdvancedFilterView(currentFilters: $activeFilters, isPresented: $showAdvancedFilters)
        }
        .background(screenBackgroundColor.ignoresSafeArea(.all, edges: .bottom))
    }
}

// MARK: - Transaction List Item View (No changes needed from your original)
struct TransactionListItemView: View {
    let transaction: TransactionDetail
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10) // Example color

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: transaction.iconName)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(transaction.iconBackgroundColor)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Text(transaction.category)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "A0A0A0")) // Subtitle gray
            }
            Spacer()
            Text(String(format: "%@$%.2f", transaction.isCredit ? "+" : "-", abs(transaction.amount)))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.isCredit ? Color(hex: "3AD7D5") : .white) // Teal for income
        }
        // Removed padding from here, applied in ForEach for better divider control
    }
}

// MARK: - App Tab Bar Definition (Using a more generic name for clarity)
enum AppScreenTab: String, CaseIterable { // Renamed from AppTab
    case home = "house.fill"
    case transactions = "list.bullet.rectangle.portrait.fill" // More descriptive icon
    case aiAdvisor = "brain.head.profile"
    case settings = "gearshape.fill"
    // Add other tabs like .budgets, .analysis, .profile as needed

    var title: String {
        switch self {
        case .home: return "Home"
        case .transactions: return "Transactions"
        case .aiAdvisor: return "AI Advisor"
        case .settings: return "Settings"
        }
    }
}

struct AppCustomTabBar: View {
    @Binding var selectedTab: AppScreenTab // Updated to AppScreenTab
    private let tabBarHeight: CGFloat = 65
    private let tabIconSize: CGFloat = 22
    private let tabTextColor = Color(hex: "8E8E93")
    private let selectedTabColor = Color.white
    private let tabBarBackgroundColor = Color(red: 0.12, green: 0.13, blue: 0.15)

    var body: some View {
        HStack {
            ForEach(AppScreenTab.allCases, id: \.rawValue) { tab in
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: tab.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: tabIconSize, height: tabIconSize)
                        .foregroundColor(selectedTab == tab ? selectedTabColor : tabTextColor)

                    Text(tab.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(selectedTab == tab ? selectedTabColor : tabTextColor)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTab = tab
                }
                Spacer()
            }
        }
        .frame(height: tabBarHeight)
        .padding(.bottom, (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0) > 0 ? 10 : 5)
        .background(tabBarBackgroundColor)
    }
}

// MARK: - Preview
struct MainAppView_Previews: PreviewProvider { // Renamed preview struct for clarity
    static var previews: some View {
        MainAppView()
    }
}
