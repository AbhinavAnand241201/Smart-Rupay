import SwiftUI

struct TransactionDetail: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let iconName: String
    let iconBackgroundColorHex: String
    let name: String
    let category: String
    let amount: Double
    var isCredit: Bool { amount > 0 }

    var iconBackgroundColor: Color {
        Color(hex: iconBackgroundColorHex)
    }
}

struct TransactionSection: Identifiable {
    let id: String
    let title: String
    var transactions: [TransactionDetail]
}

struct MainAppView: View {
    @State private var selectedTab: AppScreenTab = .transactions

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()
            VStack(spacing: 0) {
                switch selectedTab {
                case .home:
                    Text("Home Screen").foregroundColor(.white)
                case .transactions:
                    TransactionsScreenView()
                case .aiAdvisor:
                    Text("AI Advisor Screen").foregroundColor(.white)
                case .settings:
                    Text("Settings Screen").foregroundColor(.white)
                }
                AppCustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
        .preferredColorScheme(.dark)
    }
}

fileprivate struct TransactionSectionView: View {
    var section: TransactionSection

    var body: some View {
        Section {
            ForEach(section.transactions) { transaction in
                TransactionListItemView(transaction: transaction)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
            }
        } header: {
            Text(section.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "A0A0A0"))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
    }
}

struct TransactionsScreenView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @State private var showAdvancedFilters = false
    @State private var activeFilters = TransactionFilterCriteria()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Transactions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.white)
                Spacer()
                Button(action: { showAdvancedFilters = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "3AD7D5"))
                }
            }
            .padding([.horizontal, .top])
            .padding(.bottom, 8)

            // FIXED: The List now correctly and efficiently iterates over the stable
            // `groupedTransactions` property from the store.
            List {
                ForEach(transactionStore.groupedTransactions) { section in
                    TransactionSectionView(section: section)
                }
            }
            .listStyle(.plain)
            .background(Color(red: 0.08, green: 0.09, blue: 0.10))
            .sheet(isPresented: $showAdvancedFilters) {
                // You would pass the activeFilters binding here
                // AdvancedFilterView(currentFilters: $activeFilters, isPresented: $showAdvancedFilters)
            }
            // This modifier will automatically re-group the transactions
            // whenever the user changes the filter criteria.
            .onChange(of: activeFilters) { newFilters in
                transactionStore.groupTransactions(criteria: newFilters)
            }
        }
    }
}

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
                    .foregroundColor(Color(hex: "A0A0A0"))
            }
            Spacer()
            Text(String(format: "%@₹%.2f", transaction.isCredit ? "+" : "-", abs(transaction.amount)))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.isCredit ? Color(hex: "3AD7D5") : .white)
        }
    }
}

enum AppScreenTab: String, CaseIterable {
    case home = "house.fill"
    case transactions = "list.bullet.rectangle.portrait.fill"
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
    @Binding var selectedTab: AppScreenTab
    
    var body: some View {
        HStack {
            ForEach(AppScreenTab.allCases, id: \.rawValue) { tab in
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: tab.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(selectedTab == tab ? .white : Color(hex: "8E8E93"))

                    Text(tab.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(selectedTab == tab ? .white : Color(hex: "8E8E93"))
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { selectedTab = tab }
                Spacer()
            }
        }
        .frame(height: 65)
        .padding(.bottom, (UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first?.safeAreaInsets.bottom ?? 0) > 0 ? 10 : 5)
        .background(Color(red: 0.12, green: 0.13, blue: 0.15))
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
            .environmentObject(TransactionStore())
    }
}
