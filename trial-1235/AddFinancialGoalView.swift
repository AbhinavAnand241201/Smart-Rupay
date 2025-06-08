import SwiftUI

struct AddFinancialGoalView: View {
    @Environment(\.dismiss) var dismiss
    
    // FIXED: Using @EnvironmentObject is cleaner than passing the viewModel in the initializer.
    @EnvironmentObject var viewModel: FinancialGoalsViewModel

    @State private var goalName: String = ""
    @State private var targetAmountString: String = ""
    @State private var currentAmountString: String = "0"
    @State private var deadline: Date = Date()
    @State private var hasDeadline: Bool = false

    var isFormValid: Bool {
        !goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(targetAmountString) ?? 0 > 0 &&
        (Double(currentAmountString) ?? 0) >= 0
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()
                Form {
                    Section(header: Text("Goal Details").foregroundColor(.gray)) {
                        TextField("Goal Name (e.g., Dream Vacation)", text: $goalName)
                            .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                        
                        HStack {
                            // FIXED: Currency symbol changed to Rupee.
                            Text("₹").foregroundColor(.gray)
                            TextField("Target Amount", text: $targetAmountString)
                                .keyboardType(.decimalPad)
                        }
                        .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                        
                        HStack {
                            // FIXED: Currency symbol changed to Rupee.
                            Text("₹").foregroundColor(.gray)
                            TextField("Currently Saved (Optional)", text: $currentAmountString)
                                .keyboardType(.decimalPad)
                        }
                        .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                    }

                    Section(header: Text("Deadline (Optional)").foregroundColor(.gray)) {
                        Toggle("Set a Deadline", isOn: $hasDeadline.animation())
                            .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                            .tint(Color(hex: "3AD7D5"))

                        if hasDeadline {
                            DatePicker("Goal Deadline", selection: $deadline, in: Date()..., displayedComponents: .date)
                                .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .tint(Color(hex: "3AD7D5"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .tint(Color(hex: "3AD7D5"))
                    .disabled(!isFormValid || viewModel.isLoading) // Also disable while network request is in progress
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func saveGoal() {
        guard let targetAmount = Double(targetAmountString),
              let currentAmount = Double(currentAmountString) else { return }
        
        // FIXED: Wrap the call in a Task to run the async function.
        Task {
            await viewModel.addGoal(
                name: goalName.trimmingCharacters(in: .whitespacesAndNewlines),
                targetAmount: targetAmount,
                currentAmount: currentAmount,
                deadline: hasDeadline ? deadline : nil
            )
            // Only dismiss if the operation was successful (no error message was set)
            if viewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}
