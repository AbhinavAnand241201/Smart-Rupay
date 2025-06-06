// File: Views/DebtDashboardView.swift
// CORRECTED: This file no longer assumes or needs a local color extension.
// It relies on the global init(hex:) from your BudgetCategoryItem.swift file.

import SwiftUI

struct DebtDashboardView: View {
    
    @StateObject private var viewModel = DebtViewModel()
    @State private var isPresentingAddSheet = false
    @State private var isPresentingInfoSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // CHANGED: Using direct hex color to match your project style
                Color(hex: "#151618").ignoresSafeArea()
                
                List {
                    projectionSection
                        .listRowBackground(Color(hex: "#26292E")) // Card Background
                        .listRowSeparator(.hidden)

                    strategySection
                        .listRowBackground(Color(hex: "#26292E")) // Card Background
                        .listRowSeparator(.hidden)

                    debtsSection
                        .listRowBackground(Color(hex: "#26292E")) // Card Background
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
            // CHANGED: Using direct hex color
            .accentColor(Color(hex: "#3AD7D5"))
        }
    }
    
    private var projectionSection: some View {
        Section {
            let projection = viewModel.calculatePayoffProjection()
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#3AD7D5")) // Primary Accent
                    Text("Projected Payoff Date")
                        .font(.headline)
                        .foregroundColor(.white) // Text Primary
                }
                Text(projection.date)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#3AD7D5")) // Primary Accent
                
                Text("You could save an estimated **\(projection.interestSaved)** in interest with this plan.")
                    .font(.footnote)
                    .foregroundColor(Color(hex: "#A0A0A0")) // Text Secondary
            }
            .padding(.vertical)
        }
    }
    
    private var strategySection: some View {
        Section {
            Picker("Strategy", selection: $viewModel.strategy) {
                ForEach(DebtViewModel.PayoffStrategy.allCases) { strategy in
                    Text(strategy.rawValue).tag(strategy)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            HStack {
                Text("Extra Monthly Payment")
                    .foregroundColor(.white) // Text Primary
                Spacer()
                Text("₹")
                    .foregroundColor(Color(hex: "#A0A0A0")) // Text Secondary
                TextField("Amount", text: $viewModel.monthlyExtraPaymentString)
                    .keyboardType(.decimalPad)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Color(hex: "#3AD7D5")) // Primary Accent
                    .bold()
            }
        } header: {
            Text("Your Strategy")
                .foregroundColor(Color(hex: "#A0A0A0")) // Text Secondary
        }
    }
    
    private var debtsSection: some View {
        Section {
            ForEach(viewModel.sortedDebts) { debt in
                let isTarget = debt.id == viewModel.sortedDebts.first?.id
                DebtRowView(debt: debt, isTarget: isTarget)
                    .padding(.vertical, 8)
            }
            .onDelete(perform: viewModel.deleteDebt)
        } header: {
            Text("Your Debts")
                .foregroundColor(Color(hex: "#A0A0A0")) // Text Secondary
        }
    }
}

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
                .foregroundColor(Color(hex: "#3AD7D5")) // Primary Accent
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(debt.name)
                    .fontWeight(.bold)
                    .foregroundColor(.white) // Text Primary
                Text("₹\(debt.remainingBalance, specifier: "%.0f") remaining")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#A0A0A0")) // Text Secondary
                ProgressView(value: progress > 0 ? progress : 0)
                    .tint(Color(hex: "#3AD7D5")) // Primary Accent
            }
            
            Spacer()
            
            if isTarget && !debt.isPaidOff {
                Text("TARGET")
                    .font(.caption2)
                    .fontWeight(.black)
                    .foregroundColor(Color(hex: "#151618")) // Primary Background
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#3AD7D5")) // Primary Accent
                    .cornerRadius(12)
            }
        }
        .padding(10)
        .background(isTarget ? Color(hex: "#3AD7D5").opacity(0.1) : Color.clear)
        .cornerRadius(10)
    }
}

struct StrategyInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#151618").ignoresSafeArea() // Primary Background
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Avalanche Method")
                                .font(.title2).bold().foregroundColor(Color(hex: "#3AD7D5")) // Primary Accent
                            Text("This method focuses on paying off your debts with the **highest interest rates** first. You make minimum payments on all debts, then put any extra money towards the one with the highest APR. This approach usually saves you the most money in interest over time.")
                                .foregroundColor(.white) // Text Primary
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Snowball Method")
                                .font(.title2).bold().foregroundColor(Color(hex: "#3AD7D5")) // Primary Accent
                            Text("This method focuses on paying off your **smallest debts** first, regardless of interest rate. You make minimum payments on all debts, then put any extra money towards the smallest balance. This provides quick wins and can be more motivating.")
                                .foregroundColor(.white) // Text Primary
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Payoff Strategies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem { Button("Done") { dismiss() }.accentColor(Color(hex: "#3AD7D5")) } // Primary Accent
            }
        }
    }
}

#Preview {
    DebtDashboardView()
        .preferredColorScheme(.dark)
}
