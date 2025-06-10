// In AddTransactionView.swift, replace the whole file content

import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @Environment(\.dismiss) var dismiss

    @State private var amountString: String = ""
    @State private var name: String = ""
    @State private var category: TransactionCategory = .other // Default category
    @State private var transactionType: TransactionType = .expense
    @State private var date: Date = Date()
    
    // --- NEW: State for AI Suggestion ---
    @State private var isSuggestingCategory = false
    @State private var showSuggestionAlert = false
    @State private var suggestedCategory: TransactionCategory?

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !amountString.isEmpty && Double(amountString) != nil
    }

    enum TransactionCategory: String, CaseIterable, Identifiable {
        case groceries, dining, transport, entertainment, shopping, utilities, salary, gifts, other
        var id: String { self.rawValue.capitalized }
    }
    
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
                        // --- NEW: Suggestion Button ---
                        HStack {
                            Picker("Category", selection: $category) {
                                ForEach(TransactionCategory.allCases) { category in
                                    Text(category.id).tag(category)
                                }
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
            .navigationTitle("Add Transaction")
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
            // --- NEW: Alert to show the suggestion ---
            .alert("AI Suggestion", isPresented: $showSuggestionAlert, presenting: suggestedCategory) { category in
                Button("Use \"\(category.id)\"") {
                    self.category = category
                }
                Button("Cancel", role: .cancel) {}
            } message: { category in
                Text("Based on your transaction name, we suggest the category \"\(category.id)\".")
            }
            .preferredColorScheme(.dark)
        }
    }
    
    // --- NEW: Function to call the backend ---
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
                // Optionally show an error to the user
            }
            isSuggestingCategory = false
        }
    }
    
    private func saveTransaction() {
        guard let amount = Double(amountString) else { return }
        let finalAmount = transactionType == .expense ? -abs(amount) : abs(amount)
        
        let newTransaction = TransactionDetail(
            id: UUID(),
            date: date,
            iconName: categoryIcon(for: category),
            iconBackgroundColorHex: "#2c2c2e",
            name: name,
            category: category.id,
            amount: finalAmount
        )
        
        transactionStore.addTransaction(detail: newTransaction)
        dismiss()
    }
    
    private func categoryIcon(for category: TransactionCategory) -> String {
        switch category {
        case .groceries: "cart.fill"; case .dining: "fork.knife"; case .transport: "car.fill"; case .entertainment: "film.fill"; case .shopping: "bag.fill"; case .utilities: "lightbulb.fill"; case .salary: "dollarsign.circle.fill"; case .gifts: "gift.fill"; default: "tag.fill"
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
