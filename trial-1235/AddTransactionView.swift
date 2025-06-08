//
//  AddTransactionView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 08/06/25.
//


import SwiftUI

// This view allows the user to add a new transaction.
struct AddTransactionView: View {
    // Access to the central data store to save the transaction
    @EnvironmentObject var transactionStore: TransactionStore
    // A way to close the sheet
    @Environment(\.dismiss) var dismiss

    // State for all the input fields
    @State private var amountString: String = ""
    @State private var name: String = ""
    @State private var category: TransactionCategory = .groceries
    @State private var transactionType: TransactionType = .expense
    @State private var date: Date = Date()
    
    // Simple validation to enable the Save button
    private var isFormValid: Bool {
        !name.isEmpty && !amountString.isEmpty && Double(amountString) != nil
    }

    // A list of categories for the user to choose from
    enum TransactionCategory: String, CaseIterable, Identifiable {
        case groceries, dining, transport, entertainment, shopping, utilities, salary, gifts, other
        var id: String { self.rawValue.capitalized }
    }
    
    // Enum to define if the transaction is income or an expense
    enum TransactionType: String, CaseIterable {
        case expense = "Expense"
        case income = "Income"
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()
                
                Form {
                    Section(header: Text("Details").foregroundColor(.gray)) {
                        // Picker for Income/Expense
                        Picker("Type", selection: $transactionType) {
                            ForEach(TransactionType.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                        
                        // Amount Text Field
                        HStack {
                            Text("₹")
                                .font(.title2)
                                .foregroundColor(.gray)
                            TextField("0.00", text: $amountString)
                                .font(.system(size: 28, weight: .bold))
                                .keyboardType(.decimalPad)
                                .foregroundColor(transactionType == .income ? Color(hex: "3AD7D5") : .white)
                        }
                        .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                        
                        // Transaction Name
                        TextField("Transaction Name (e.g., Coffee, Salary)", text: $name)
                            .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                    }
                    
                    Section(header: Text("Categorization").foregroundColor(.gray)) {
                        // Category Picker
                        Picker("Category", selection: $category) {
                            ForEach(TransactionCategory.allCases) { category in
                                Text(category.id).tag(category)
                            }
                        }
                        .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                        
                        // Date Picker
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(Color(hex: "3AD7D5"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .tint(Color(hex: "3AD7D5"))
                    .disabled(!isFormValid)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    // In AddTransactionView.swift

    private func saveTransaction() {
        guard let amount = Double(amountString) else { return }
        
        // This correctly sets the amount to be negative for an expense
        let finalAmount = transactionType == .expense ? -abs(amount) : abs(amount)
        
        let newTransaction = TransactionDetail(
            id: UUID(),
            date: date,
            iconName: categoryIcon(for: category),
            iconBackgroundColorHex: "#2c2c2e", // Default background color
            name: name,
            category: category.rawValue.capitalized,
            amount: finalAmount
            // FIXED: The `isCredit` argument has been removed. It will be computed automatically.
        )
        
        // Add the new transaction to the central store
        transactionStore.addTransaction(detail: newTransaction)
        
        // Close the sheet
        dismiss()
    }
    // Helper to return an icon based on the category
    private func categoryIcon(for category: TransactionCategory) -> String {
        switch category {
        case .groceries: return "cart.fill"
        case .dining: return "fork.knife"
        case .transport: return "car.fill"
        case .entertainment: return "film.fill"
        case .shopping: return "bag.fill"
        case .utilities: return "lightbulb.fill"
        case .salary: return "dollarsign.circle.fill"
        case .gifts: return "gift.fill"
        case .other: return "tag.fill"
        }
    }
}

// Preview provider for the new view
struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView()
            .environmentObject(TransactionStore())
    }
}
