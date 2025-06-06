// File: Views/DebtDashboardView.swift

import SwiftUI

struct DebtDashboardView: View {
    
    @StateObject private var viewModel = DebtViewModel()
    @State private var isPresentingAddSheet = false
    @State private var isPresentingInfoSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground.ignoresSafeArea()
                
                List {
                    // --- SECTION 1: PROJECTION ---
                    projectionSection
                        .listRowBackground(Color.cardBackground)
                        .listRowSeparator(.hidden)

                    // --- SECTION 2: STRATEGY & EXTRA PAYMENT ---
                    strategySection
                        .listRowBackground(Color.cardBackground)
                        .listRowSeparator(.hidden)

                    // --- SECTION 3: DEBTS LIST ---
                    debtsSection
                        .listRowBackground(Color.cardBackground)
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Debt Payoff Planner")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresentingInfoSheet = true }) {
                        Image(systemName: "info.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresentingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingInfoSheet) { StrategyInfoSheet() }
            .sheet(isPresented: $isPresentingAddSheet) {
                AddEditDebtView { debt in
                    viewModel.addDebt(debt)
                }
            }
            .accentColor(.primaryAccent)
        }
    }
    
    // --- SUBVIEWS for better organization ---
    
    private var projectionSection: some View {
        Section {
            let projection = viewModel.calculatePayoffProjection()
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundColor(.primaryAccent)
                    Text("Projected Payoff Date")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                }
                Text(projection.date)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryAccent)
                
                Text("You could save an estimated **\(projection.interestSaved)** in interest with this plan.")
                    .font(.footnote)
                    .foregroundColor(.textSecondary)
            }
            .padding(.vertical)
        }
    }
    
    private var strategySection: some View {
        Section(header: Text("Your Strategy").foregroundColor(.textSecondary)) {
            Picker("Strategy", selection: $viewModel.strategy) {
                ForEach(DebtViewModel.PayoffStrategy.allCases) { strategy in
                    Text(strategy.rawValue).tag(strategy)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            HStack {
                Text("Extra Monthly Payment")
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("₹")
                    .foregroundColor(.textSecondary)
                TextField("Amount", text: $viewModel.monthlyExtraPaymentString)
                    .keyboardType(.decimalPad)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.primaryAccent)
                    .bold()
            }
        }
    }
    
    private var debtsSection: some View {
        Section(header: Text("Your Debts").foregroundColor(.textSecondary)) {
            ForEach(viewModel.sortedDebts) { debt in
                let isTarget = debt.id == viewModel.sortedDebts.first?.id
                DebtRowView(debt: debt, isTarget: isTarget)
                    .padding(.vertical, 8)
            }
            .onDelete(perform: viewModel.deleteDebt)
        }
    }
}

// MARK: - Sub-views for the Dashboard

struct DebtRowView: View {
    let debt: DebtItem
    let isTarget: Bool
    
    var progress: Double {
        guard let original = debt.originalBalance, original > 0 else { return 0 }
        return (original - debt.remainingBalance) / original
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: debt.debtType.icon)
                .font(.title2)
                .foregroundColor(.primaryAccent)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(debt.name)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                Text("₹\(debt.remainingBalance, specifier: "%.0f") remaining")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                ProgressView(value: progress > 0 ? progress : 0)
                    .tint(.primaryAccent)
            }
            
            Spacer()
            
            if isTarget && !debt.isPaidOff {
                Text("TARGET")
                    .font(.caption2)
                    .fontWeight(.black)
                    .foregroundColor(.primaryBackground)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primaryAccent)
                    .cornerRadius(12)
            }
        }
        .padding(10)
        .background(isTarget ? Color.primaryAccent.opacity(0.1) : Color.clear)
        .cornerRadius(10)
    }
}

struct StrategyInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Avalanche Method")
                                .font(.title2).bold().foregroundColor(.primaryAccent)
                            Text("This method focuses on paying off your debts with the **highest interest rates** first. You make minimum payments on all debts, then put any extra money towards the one with the highest APR. This approach usually saves you the most money in interest over time.")
                                .foregroundColor(.textPrimary)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Snowball Method")
                                .font(.title2).bold().foregroundColor(.primaryAccent)
                            Text("This method focuses on paying off your **smallest debts** first, regardless of interest rate. You make minimum payments on all debts, then put any extra money towards the smallest balance. This provides quick wins and can be more motivating.")
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Payoff Strategies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem { Button("Done") { dismiss() }.foregroundColor(.primaryAccent) }
            }
        }
    }
}

#Preview {
    DebtDashboardView()
        .preferredColorScheme(.dark)
}