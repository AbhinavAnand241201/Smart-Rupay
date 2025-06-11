// In the file containing MainAppView and TransactionsScreenView

import SwiftUI

// MARK: - Models (Should be in a shared file)
struct TransactionDetail: Identifiable, Codable, Hashable {
    let id: UUID; let date: Date; let iconName: String; let iconBackgroundColorHex: String;
    let name: String; let category: String; let amount: Double
    var isCredit: Bool { amount > 0 }
    var iconBackgroundColor: Color { Color(hex: iconBackgroundColorHex) }
}
struct TransactionSection: Identifiable {
    let id: String; let title: String; var transactions: [TransactionDetail]
}
enum AppScreenTab: String, CaseIterable {
    case home = "house.fill", transactions = "list.bullet.rectangle.portrait.fill",
         aiAdvisor = "brain.head.profile", settings = "gearshape.fill"
    var title: String {
        switch self {
        case .home: "Home"; case .transactions: "Transactions";
        case .aiAdvisor: "AI Advisor"; case .settings: "Settings"
        }
    }
}

// MARK: - Main App View (with Navigation enabled)
struct MainAppView: View {
    @State private var selectedTab: AppScreenTab = .transactions
    init() { UITabBar.appearance().isHidden = true }

    var body: some View {
        NavigationView {
            ZStack {
                Color.App.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    switch selectedTab {
                    case .transactions: TransactionsScreenView()
                    default: Text("\(selectedTab.title) Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    AppCustomTabBar(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(.keyboard)
            }
            .navigationBarHidden(true)
        }
        .accentColor(Color.App.accent)
    }
}

// MARK: - Redesigned Transactions Screen
struct TransactionsScreenView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @State private var showAddTransactionSheet = false
    @State private var showFilterSheet = false
    @State private var activeFilters = TransactionFilterCriteria()
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced header with a larger title and filter button
            HStack {
                Text("Transactions")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color.App.textPrimary)
                Spacer()
                Button { showFilterSheet.toggle() } label: { Image(systemName: "slider.horizontal.3") }
                Button { showAddTransactionSheet.toggle() } label: { Image(systemName: "plus") }
                    .padding(.leading, 8)
            }
            .font(.title2)
            .foregroundColor(Color.App.accent)
            .padding([.horizontal, .top])
            .padding(.bottom, 15)

            // Using a List to preserve native swipe-to-delete functionality
            List {
                ForEach(transactionStore.groupedTransactions) { section in
                    TransactionSectionView(section: section)
                }
            }
            .listStyle(.plain)
            .background(Color.App.background)
        }
        .sheet(isPresented: $showAddTransactionSheet) {
            AddTransactionView().environmentObject(transactionStore)
        }
        .sheet(isPresented: $showFilterSheet) {
            AdvancedFilterView(currentFilters: $activeFilters, isPresented: $showFilterSheet)
        }
    }
}

// MARK: - Helper Views for the List
private struct TransactionSectionView: View {
    var section: TransactionSection

    var body: some View {
        Section {
            ForEach(section.transactions) { transaction in
                NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                    TransactionListItemView(transaction: transaction)
                }
            }
            // Applying custom styling to each row
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.App.background)
            .padding(.bottom, 12)
            
        } header: {
            // Enhanced section header styling
            Text(section.title)
                .font(.headline.weight(.semibold))
                .foregroundColor(Color.App.textSecondary)
                .padding(.vertical, 8)
        }
        .listRowSeparator(.hidden)
    }
}

// MARK: - Redesigned Transaction List Item
private struct TransactionListItemView: View {
    let transaction: TransactionDetail

    var body: some View {
        HStack(spacing: 16) {
            // Icon styled to match our modern design language
            Image(systemName: transaction.iconName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(transaction.iconBackgroundColor)
                .frame(width: 50, height: 50)
                .background(transaction.iconBackgroundColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(transaction.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.App.textPrimary)
                Text(transaction.category)
                    .font(.subheadline)
                    .foregroundColor(.App.textSecondary)
            }
            
            Spacer()
            
            Text("₹\(transaction.amount, specifier: "%.2f")")
                .font(.headline.weight(.bold))
                .foregroundColor(transaction.isCredit ? .App.accentGreen : .App.textPrimary)
        }
        .padding(.horizontal) // Padding is now inside the row for better tappable area
    }
}

// MARK: - Tab Bar and Preview
struct AppCustomTabBar: View {
    @Binding var selectedTab: AppScreenTab
    var body: some View { /* ... Unchanged ... */ }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
            .environmentObject(TransactionStore())
    }
}
