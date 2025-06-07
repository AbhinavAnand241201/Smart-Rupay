import SwiftUI

@main
struct trial_1235App: App {
    // FIXED: Observe the shared AppState to react to login changes.
    @StateObject private var appState = AppState.shared
    
    // FIXED: All data stores are now initialized here and passed via environment
    // to ensure all parts of the app use the SAME data.
    @StateObject private var transactionStore = TransactionStore()
    @StateObject private var financialGoalsViewModel = FinancialGoalsViewModel()
    @StateObject private var debtViewModel = DebtViewModel()
    @StateObject private var recurringPaymentsViewModel = RecurringPaymentsViewModel()
    @StateObject private var billManager = BillManager()
    @StateObject private var rupayOracleViewModel = RupayOracleViewModel()

    var body: some Scene {
        WindowGroup {
            // FIXED: This logic now correctly shows the LoginView first,
            // and switches to the main app when isLoggedIn becomes true.
            if appState.isLoggedIn {
                // Using MainAppView as the primary, most complete tab view.
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
