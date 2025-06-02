//
//  TransactionDetail.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 02/06/25.
//


import SwiftUI

// MARK: - Data Models for Transactions Screen
struct TransactionDetail: Identifiable {
    let id = UUID()
    let iconName: String
    let iconBackgroundColor: Color
    let name: String
    let category: String
    let amount: Double
    var isCredit: Bool { amount > 0 }
}

struct TransactionSection: Identifiable {
    let id = UUID()
    let title: String // "Today", "Yesterday"
    let transactions: [TransactionDetail]
}

// MARK: - Main ContentView (Modified for new Tabs)
struct MainAppView: View { // Renamed from ContentView to avoid confusion if running separately
    @State private var selectedTab: AppTab = .transactions // Default to transactions for this example

    // Sample data for the Transactions Screen - This will be used by TransactionsScreenView
    let transactionSectionsForScreen: [TransactionSection] = [
        TransactionSection(title: "Today", transactions: [
            TransactionDetail(iconName: "cart.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "Whole Foods Market", category: "Groceries", amount: -120.00),
            TransactionDetail(iconName: "film.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "AMC Theatres", category: "Entertainment", amount: -30.00),
            TransactionDetail(iconName: "car.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "Uber", category: "Transportation", amount: -25.00)
        ]),
        TransactionSection(title: "Yesterday", transactions: [
            TransactionDetail(iconName: "fork.knife", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "The Italian Place", category: "Dining", amount: -75.00),
            TransactionDetail(iconName: "archivebox.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "Amazon", category: "Shopping", amount: -50.00),
            TransactionDetail(iconName: "dollarsign.circle.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "Salary", category: "Income", amount: 2500.00)
        ])
    ]

    init() {
        // This appearance setting is global.
        // If you use a standard TabView elsewhere and want it visible, this might need adjustment.
        // For a fully custom tab bar as implemented, this hides any residual default TabView.
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack {
            // Main background for the entire app
            Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()

            VStack(spacing: 0) {
                // Content based on selected tab
                switch selectedTab {
                case .home:
                    // Replace with your actual Home Screen View
                    Text("Home Screen")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .transactions:
                    TransactionsScreenView(sections: transactionSectionsForScreen) // Pass the data
                case .aiAdvisor:
                    // Replace with your actual AI Advisor Screen View
                    Text("AI Advisor Screen")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .settings:
                    // Replace with your actual Settings Screen View
                    Text("Settings Screen")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Custom Tab Bar at the bottom
                AppCustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
        .preferredColorScheme(.dark)
    }
}


// MARK: - Transactions Screen View
struct TransactionsScreenView: View {
    @State private var searchText: String = ""
    @State private var selectedFilter: String = "All"
    let filters = ["All", "Income", "Expenses", "Transfers"]
    let sections: [TransactionSection] // Expect pre-grouped data

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: {
                    print("Back button tapped")
                    // Add actual back navigation logic here if needed
                    // e.g., if this view is part of a NavigationView:
                    // presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Transactions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.left") // Invisible placeholder
                    .font(.system(size: 18, weight: .semibold))
                    .opacity(0)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(red: 0.08, green: 0.09, blue: 0.10))

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                TextField("Search transactions", text: $searchText)
                    .foregroundColor(.white)
                    .tint(Color.white) // Cursor color
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(red: 0.15, green: 0.16, blue: 0.18))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 15)

            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(filters, id: \.self) { filter in
                        Text(filter)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(selectedFilter == filter ? Color(red: 0.25, green: 0.26, blue: 0.28) : Color(red: 0.2, green: 0.21, blue: 0.23))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .onTapGesture {
                                selectedFilter = filter
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)

            // Transactions List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15, pinnedViews: [.sectionHeaders]) {
                    ForEach(sections) { section in
                        Section {
                            ForEach(section.transactions) { transaction in
                                TransactionListItemView(transaction: transaction)
                                    .padding(.horizontal)
                            }
                        } header: {
                            Text(section.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(red: 0.08, green: 0.09, blue: 0.10))
                        }
                    }
                }
            }
            .padding(.bottom, 1)
        }
        .background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea(.all, edges: .top)) // Extend bg to top, below custom nav bar
    }
}

// MARK: - Transaction List Item View
struct TransactionListItemView: View {
    let transaction: TransactionDetail

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
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
            Spacer()
            Text(String(format: "%@$%.2f", transaction.isCredit ? "+" : "-", abs(transaction.amount)))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.isCredit ? Color(red: 0.2, green: 0.8, blue: 0.45) : .white)
        }
        .padding(.vertical, 8)
    }
}


// MARK: - New Custom Tab Bar Definition
enum AppTab: String, CaseIterable {
    case home = "house.fill"
    case transactions = "list.bullet"
    case aiAdvisor = "brain.head.profile"
    case settings = "gearshape.fill"

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
    @Binding var selectedTab: AppTab
    private let tabBarHeight: CGFloat = 65

    var body: some View {
        HStack {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: tab.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(selectedTab == tab ? .white : Color(red: 0.5, green: 0.5, blue: 0.55))

                    Text(tab.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(selectedTab == tab ? .white : Color(red: 0.5, green: 0.5, blue: 0.55))
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
        .padding(.bottom, UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0 > 0 ? 15 : 5) // Adjust padding for home indicator
        .background(Color(red: 0.12, green: 0.13, blue: 0.15))
    }
}


// MARK: - Preview
struct TransactionsScreenView_Previews: PreviewProvider {
    // Sample data for the preview if TransactionsScreenView is previewed in isolation
    static let previewSections: [TransactionSection] = [
        TransactionSection(title: "Today", transactions: [
            TransactionDetail(iconName: "cart.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "Whole Foods Market", category: "Groceries", amount: -120.00),
            TransactionDetail(iconName: "film.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "AMC Theatres", category: "Entertainment", amount: -30.00)
        ]),
        TransactionSection(title: "Yesterday", transactions: [
            TransactionDetail(iconName: "dollarsign.circle.fill", iconBackgroundColor: Color(red: 0.15, green: 0.16, blue: 0.18), name: "Salary", category: "Income", amount: 2500.00)
        ])
    ]

    static var previews: some View {
        // To preview the full screen with tab bar context:
        MainAppView() // <<-- THIS IS THE CORRECTED LINE

        // To preview just the TransactionsScreenView in isolation:
        // TransactionsScreenView(sections: previewSections)
        //    .preferredColorScheme(.dark) // Ensure dark mode for isolated preview
        //    .background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea())
    }
}