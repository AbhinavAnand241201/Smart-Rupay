// In file: DebtDashboardView.swift

import SwiftUI

struct DebtDashboardView: View {
    // MARK: - Properties
    @StateObject private var viewModel = DebtViewModel()
    @State private var isPresentingAddSheet = false
    @State private var isPresentingInfoSheet = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color.App.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // Each section is now a separate, styled card
                        projectionSection
                        strategySection
                        debtsSection
                        
                        // Spacer to ensure content can scroll above the tab bar if needed
                        Color.clear.frame(height: 40)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Debt Payoff Planner")
            .toolbar {
                // Toolbar items remain the same, but with our app's accent color
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresentingInfoSheet = true }) { Image(systemName: "info.circle") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresentingAddSheet = true }) { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $isPresentingInfoSheet) { StrategyInfoSheet() }
            .sheet(isPresented: $isPresentingAddSheet) {
                AddEditDebtView { debt in
                    viewModel.addDebt(debt)
                }
            }
            .accentColor(Color.App.accent)
        }
    }
    
    // MARK: - Sections as Cards
    
    private var projectionSection: some View {
        // The "Hero" card of the screen, with prominent styling
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title3)
                    .foregroundColor(Color.App.accentGreen)
                Text("Projected Payoff Date")
                    .font(.headline)
                    .foregroundColor(Color.App.textPrimary)
            }
            
            Text(viewModel.calculatePayoffProjection().date)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color.App.accentGreen)
            
            Text("You could save an estimated **\(viewModel.calculatePayoffProjection().interestSaved)** in interest with this plan.")
                .font(.footnote)
                .foregroundColor(Color.App.textSecondary)
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.App.card)
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    private var strategySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Strategy")
                .font(.title3.bold())
                .foregroundColor(Color.App.textPrimary)
                .padding(.horizontal)
            
            Picker("Strategy", selection: $viewModel.strategy) {
                ForEach(DebtViewModel.PayoffStrategy.allCases) { strategy in
                    Text(strategy.rawValue).tag(strategy)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Divider().padding(.horizontal)
            
            HStack {
                Text("Extra Monthly Payment")
                    .foregroundColor(Color.App.textPrimary)
                Spacer()
                Text("₹")
                    .foregroundColor(Color.App.textSecondary)
                TextField("Amount", text: $viewModel.monthlyExtraPaymentString)
                    .keyboardType(.decimalPad)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Color.App.accent)
                    .font(.headline.weight(.bold))
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.App.card)
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    private var debtsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your Debts")
                .font(.title3.bold())
                .foregroundColor(Color.App.textPrimary)
                .padding([.horizontal, .bottom])

            // The list of debts now lives inside its own card
            VStack(spacing: 12) {
                ForEach(viewModel.sortedDebts) { debt in
                    let isTarget = debt.id == viewModel.sortedDebts.first?.id
                    DebtRowView(debt: debt, isTarget: isTarget)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Redesigned Debt Row
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
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.App.accent)
                .frame(width: 44, height: 44)
                .background(Color.App.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(debt.name)
                    .fontWeight(.bold)
                    .foregroundColor(Color.App.textPrimary)
                
                Text("₹\(debt.remainingBalance, specifier: "%.0f") remaining")
                    .font(.subheadline)
                    .foregroundColor(Color.App.textSecondary)
                
                ProgressView(value: progress > 0 ? progress : 0)
                    .tint(Color.App.accent)
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            
            Spacer()
            
            if isTarget && !debt.isPaidOff {
                Text("TARGET")
                    .font(.caption2)
                    .fontWeight(.black)
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.App.accent)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(isTarget ? Color.App.accent.opacity(0.1) : Color.App.card)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isTarget ? Color.App.accent : Color.clear, lineWidth: 1.5)
        )
    }
}

// MARK: - Strategy Info Sheet (Unchanged)
struct StrategyInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        // This view's original design is fine for an informational sheet
        NavigationView {
            ZStack {
                Color.App.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Avalanche Method")
                                .font(.title2).bold().foregroundColor(Color.App.accent)
                            Text("This method focuses on paying off your debts with the **highest interest rates** first. You make minimum payments on all debts, then put any extra money towards the one with the highest APR. This approach usually saves you the most money in interest over time.")
                                .foregroundColor(Color.App.textPrimary)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Snowball Method")
                                .font(.title2).bold().foregroundColor(Color.App.accent)
                            Text("This method focuses on paying off your **smallest debts** first, regardless of interest rate. You make minimum payments on all debts, then put any extra money towards the smallest balance. This provides quick wins and can be more motivating.")
                                .foregroundColor(Color.App.textPrimary)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Payoff Strategies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem { Button("Done") { dismiss() }.tint(Color.App.accent) }
            }
        }
    }
}

// MARK: - Preview
struct DebtDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DebtDashboardView()
            .preferredColorScheme(.dark)
    }
}
