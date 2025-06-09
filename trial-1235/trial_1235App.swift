import SwiftUI

@main
struct trial_1235App: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var transactionStore = TransactionStore()
    @StateObject private var financialGoalsViewModel = FinancialGoalsViewModel()
    @StateObject private var debtViewModel = DebtViewModel()
    @StateObject private var recurringPaymentsViewModel = RecurringPaymentsViewModel()
    @StateObject private var billManager = BillManager()
    @StateObject private var rupayOracleViewModel = RupayOracleViewModel()

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                MainAppView()
                    .environmentObject(transactionStore)
                    .environmentObject(financialGoalsViewModel)
                    .environmentObject(debtViewModel)
                    .environmentObject(recurringPaymentsViewModel)
                    .environmentObject(billManager)
                    .environmentObject(rupayOracleViewModel)
            } else {
                LoginScreenView()
            }
        }
    }
}
