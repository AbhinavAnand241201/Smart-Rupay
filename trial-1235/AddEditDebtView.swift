// File: Views/AddEditDebtView.swift
// CORRECTED: This file no longer assumes or needs a local color extension.
// It relies on the global init(hex:) from your BudgetCategoryItem.swift file.

import SwiftUI

struct AddEditDebtView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (DebtItem) -> Void
    
    @State private var name: String = ""
    @State private var totalAmount: String = ""
    @State private var interestRate: String = ""
    @State private var minimumPayment: String = ""
    @State private var debtType: DebtItem.DebtType = .creditCard
    
    var body: some View {
        NavigationView {
            ZStack {
                // CHANGED: Using direct hex color
                Color(hex: "#151618").ignoresSafeArea()
                Form {
                    Section(header: Text("Debt Details").foregroundColor(Color(hex: "#A0A0A0"))) { // Text Secondary
                        TextField("Debt Name (e.g., HDFC Credit Card)", text: $name)
                        Picker("Debt Type", selection: $debtType) {
                            ForEach(DebtItem.DebtType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                    .listRowBackground(Color(hex: "#26292E")) // Card Background
                    
                    Section(header: Text("Amounts").foregroundColor(Color(hex: "#A0A0A0"))) { // Text Secondary
                        HStack {
                            Text("₹")
                            TextField("Remaining Balance", text: $totalAmount)
                                .keyboardType(.decimalPad)
                        }
                        HStack {
                            Text("%")
                            TextField("Interest Rate (APR)", text: $interestRate)
                                .keyboardType(.decimalPad)
                        }
                        HStack {
                            Text("₹")
                            TextField("Minimum Monthly Payment", text: $minimumPayment)
                                .keyboardType(.decimalPad)
                        }
                    }
                    .listRowBackground(Color(hex: "#26292E")) // Card Background
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add New Debt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveAndDismiss() }
                        .bold()
                }
            }
            // CHANGED: Using direct hex color
            .accentColor(Color(hex: "#3AD7D5"))
        }
    }
    
    private func saveAndDismiss() {
        let debt = DebtItem(
            id: UUID(),
            name: name,
            remainingBalance: Double(totalAmount) ?? 0,
            interestRate: Double(interestRate) ?? 0,
            minimumPayment: Double(minimumPayment) ?? 0,
            debtType: debtType,
            originalBalance: Double(totalAmount) ?? 0
        )
        onSave(debt)
        dismiss()
    }
}
