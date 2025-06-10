// In AddTransactionView.swift

import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @Environment(\.dismiss) var dismiss

    // This property holds the transaction we are editing.
    // If it's nil, the view is in "Add New" mode.
    var transactionToEdit: TransactionDetail?

    // MARK: State Variables
    @State private var amountString: String = ""
    @State private var name: String = ""
    @State private var category: TransactionCategory = .other
    @State private var transactionType: TransactionType = .expense
    @State private var date: Date = Date()
    
    // State for AI Suggestion
    @State private var isSuggestingCategory = false
    @State private var showSuggestionAlert = false
    @State private var suggestedCategory: TransactionCategory?

    // MARK: Computed Properties
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !amountString.isEmpty && Double(amountString) != nil
    }
    
    // The title changes depending on whether we are adding or editing.
    private var navigationTitle: String {
        transactionToEdit == nil ? "Add Transaction" : "Edit Transaction"
    }

    // MARK: Enums
    enum TransactionCategory: String, CaseIterable, Identifiable {
        case groceries, dining, transport, entertainment, shopping, utilities, salary, gifts, other
        var id: String { self.rawValue.capitalized }
    }
    
    enum TransactionType: String, CaseIterable {
        case expense = "Expense"
        case income = "Income"
    }

    // MARK: Body
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()
                
                Form {
                    Section(header: Text("Details").foregroundColor(.gray)) {
                        Picker("Type", selection: $transactionType) {
                            ForEach(TransactionType.allCases, id: \.self) { Text($0.rawValue) }
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                        
                        HStack {
                            Text("₹").font(.title2).foregroundColor(.gray)
                            TextField("0.00", text: $amountString)
                                .font(.system(size: 28, weight: .bold))
                                .keyboardType(.decimalPad)
                                .foregroundColor(transactionType == .income ? Color(hex: "3AD7D5") : .white)
                        }
                        .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                        
                        TextField("Transaction Name (e.g., Coffee, Salary)", text: $name)
                            .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                    }
                    
                    Section(header: Text("Categorization").foregroundColor(.gray)) {
                        HStack {
                            Picker("Category", selection: $category) {
                                ForEach(TransactionCategory.allCases) { Text($0.id).tag($0) }
                            }
                            
                            Spacer()
                            
                            Button(action: fetchCategorySuggestion) {
                                if isSuggestingCategory {
                                    ProgressView()
                                } else {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(Color(hex: "3AD7D5"))
                                }
                            }
                            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(navigationTitle) // Use the dynamic title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.tint(Color(hex: "3AD7D5"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveTransaction() }
                        .tint(Color(hex: "3AD7D5"))
                        .disabled(!isFormValid)
                }
            }
            .alert("AI Suggestion", isPresented: $showSuggestionAlert, presenting: suggestedCategory) { category in
                Button("Use \"\(category.id)\"") { self.category = category }
                Button("Cancel", role: .cancel) {}
            } message: { category in
                Text("Based on your transaction name, we suggest the category \"\(category.id)\".")
            }
            .preferredColorScheme(.dark)
            .onAppear(perform: setupForEditing) // Pre-fill the form if editing
        }
    }
    
    // MARK: Functions
    
    /// Pre-fills the form fields if a transaction is passed in for editing.
    private func setupForEditing() {
        guard let transaction = transactionToEdit else { return }
        
        name = transaction.name
        amountString = String(abs(transaction.amount))
        transactionType = transaction.isCredit ? .income : .expense
        date = transaction.date
        if let matchedCategory = TransactionCategory(rawValue: transaction.category.lowercased()) {
            category = matchedCategory
        }
    }

    /// Handles both updating an existing transaction and adding a new one.
    private func saveTransaction() {
        guard let amount = Double(amountString) else { return }
        let finalAmount = transactionType == .expense ? -abs(amount) : abs(amount)

        // If transactionToEdit exists, we UPDATE it.
        if let existingTransaction = transactionToEdit {
            let updatedTransaction = TransactionDetail(
                id: existingTransaction.id, // Keep the original ID
                date: date,
                iconName: categoryIcon(for: category),
                iconBackgroundColorHex: "#2c2c2e",
                name: name,
                category: category.id,
                amount: finalAmount
            )
            Task {
                await transactionStore.updateTransaction(updatedTransaction)
            }
        // Otherwise, we ADD a new one.
        } else {
            let newTransaction = TransactionDetail(
                id: UUID(), // Create a new ID
                date: date,
                iconName: categoryIcon(for: category),
                iconBackgroundColorHex: "#2c2c2e",
                name: name,
                category: category.id,
                amount: finalAmount
            )
            transactionStore.addTransaction(detail: newTransaction)
        }
        
        dismiss()
    }
    
    private func fetchCategorySuggestion() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSuggestingCategory = true
        
        Task {
            do {
                let response = try await NetworkService.shared.suggestCategory(for: name)
                if let matchedCategory = TransactionCategory(rawValue: response.category) {
                    self.suggestedCategory = matchedCategory
                    self.showSuggestionAlert = true
                }
            } catch {
                print("Error fetching category suggestion: \(error)")
            }
            isSuggestingCategory = false
        }
    }
    
    private func categoryIcon(for category: TransactionCategory) -> String {
        switch category {
        case .groceries: "cart.fill"; case .dining: "fork.knife"; case .transport: "car.fill"; case .entertainment: "film.fill"; case .shopping: "bag.fill"; case .utilities: "lightbulb.fill"; case .salary: "dollarsign.circle.fill"; case .gifts: "gift.fill"; default: "tag.fill"
        }
    }
}
struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView()
            .environmentObject(TransactionStore())
    }
}
