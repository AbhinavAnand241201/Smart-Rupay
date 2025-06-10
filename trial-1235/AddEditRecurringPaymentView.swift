
import SwiftUI

struct AddEditRecurringPaymentView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RecurringPaymentsViewModel
    
    var paymentToEdit: RecurringPayment?

    @State private var name: String = ""
    @State private var amountString: String = ""
    @State private var category: String = "" // Default to first sample or empty
    @State private var recurrenceInterval: RecurrenceInterval = .monthly
    @State private var startDate: Date = Date()
    @State private var hasEndDate: Bool = false
    @State private var endDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date())! // Default end date if toggled
    @State private var notes: String = ""
    

    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Double(amountString) ?? -1) >= 0 && // Allow 0 for amount, but not negative
        !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (!hasEndDate || (endDate >= startDate)) // End date must be after start date if set
    }
    
    var navigationTitleString: String {
        paymentToEdit == nil ? "Add Recurring Item" : "Edit Recurring Item"
    }

    init(viewModel: RecurringPaymentsViewModel, paymentToEdit: RecurringPayment? = nil) {
        self.viewModel = viewModel
        self.paymentToEdit = paymentToEdit
        
        if let payment = paymentToEdit {
            _name = State(initialValue: payment.name)
            _amountString = State(initialValue: String(format: "%.2f", payment.amount))
            _category = State(initialValue: payment.category)
            _recurrenceInterval = State(initialValue: payment.recurrenceInterval)
            _startDate = State(initialValue: payment.startDate)
            _hasEndDate = State(initialValue: payment.endDate != nil)
            _endDate = State(initialValue: payment.endDate ?? Calendar.current.date(byAdding: .year, value: 1, to: payment.startDate)!)
            _notes = State(initialValue: payment.notes ?? "")
        } else {
            // Default category if adding new
             _category = State(initialValue: viewModel.sampleCategories.first ?? "")
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                screenBackgroundColor.ignoresSafeArea()
                Form {
                    Section(header: Text("Payment Details").foregroundColor(secondaryTextColor).textCase(nil)) {
                        TextField("Name (e.g., Netflix, Rent)", text: $name)
                            .listRowBackground(cardBackgroundColor)
                        HStack {
                            Text("$")
                                .foregroundColor(mainTextColor) // Ensure $ is visible
                            TextField("Amount", text: $amountString)
                                .keyboardType(.decimalPad)
                        }
                        .listRowBackground(cardBackgroundColor)
                        
                        Picker("Category", selection: $category) {
                            ForEach(viewModel.sampleCategories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .listRowBackground(cardBackgroundColor)
                        // .tint(mainTextColor) // For picker chevron color
                    }
                    .foregroundColor(mainTextColor) // For TextField text color
                    .tint(accentColorTeal) // For TextField cursor

                    Section(header: Text("Schedule").foregroundColor(secondaryTextColor).textCase(nil)) {
                        Picker("Repeats", selection: $recurrenceInterval) {
                            ForEach(RecurrenceInterval.allCases) { interval in
                                Text(interval.rawValue).tag(interval)
                            }
                        }
                        DatePicker("First Payment On", selection: $startDate, displayedComponents: .date)
                        Toggle("Set End Date", isOn: $hasEndDate.animation())
                            .tint(accentColorTeal)
                        if hasEndDate {
                            DatePicker("Last Payment On", selection: $endDate, in: startDate..., displayedComponents: .date)
                        }
                    }
                    .listRowBackground(cardBackgroundColor)
                    .foregroundColor(mainTextColor)
                    .accentColor(accentColorTeal)


                    Section(header: Text("Additional Information (Optional)").foregroundColor(secondaryTextColor).textCase(nil)) {
                        TextField("Notes (e.g., account number, details)", text: $notes, axis: .vertical)
                            .lineLimit(3...5)
                            .listRowBackground(cardBackgroundColor)
                    }
                    .foregroundColor(mainTextColor)
                    .tint(accentColorTeal)
                }
                .scrollContentBackground(.hidden)
                .environment(\.colorScheme, .dark) // Ensure Form elements adapt
            }
            .navigationTitle(navigationTitleString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(accentColorTeal)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { savePayment() }
                        .foregroundColor(accentColorTeal)
                        .disabled(!isFormValid)
                        .fontWeight(isFormValid ? .bold : .regular)
                }
            }
        }
        .preferredColorScheme(.dark) // Apply to NavigationView
    }

    private func savePayment() {
        guard let amount = Double(amountString) else { return }
        let finalEndDate = hasEndDate ? endDate : nil

        if let paymentId = paymentToEdit?.id { // Editing existing
            // Create a new struct with updated values to ensure all properties are fresh
            let updatedPayment = RecurringPayment(
                id: paymentId, // Keep original ID
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                category: category.trimmingCharacters(in: .whitespacesAndNewlines),
                recurrenceInterval: recurrenceInterval,
                startDate: startDate,
                nextDueDate: paymentToEdit?.nextDueDate, 
                endDate: finalEndDate,
                notes: notes.isEmpty ? nil : notes,
                iconName: paymentToEdit!.iconName, 
                colorHex: paymentToEdit!.colorHex  
            )
            viewModel.updatePayment(updatedPayment)
        } else { // Adding new
            viewModel.addPayment(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                category: category.trimmingCharacters(in: .whitespacesAndNewlines),
                interval: recurrenceInterval,
                startDate: startDate,
                endDate: finalEndDate,
                notes: notes.isEmpty ? nil : notes
            )
        }
        presentationMode.wrappedValue.dismiss()
    }
}
