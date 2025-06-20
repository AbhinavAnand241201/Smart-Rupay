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
                Color(hex: "#151618").ignoresSafeArea()
                Form {
                    Section(header: Text("Debt Details").foregroundColor(Color(hex: "#A0A0A0"))) {
                        TextField("Debt Name (e.g., HDFC Credit Card)", text: $name)
                        Picker("Debt Type", selection: $debtType) {
                            ForEach(DebtItem.DebtType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                    .listRowBackground(Color(hex: "#26292E"))
                    
                    Section(header: Text("Amounts").foregroundColor(Color(hex: "#A0A0A0"))) {
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
                    .listRowBackground(Color(hex: "#26292E"))
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

