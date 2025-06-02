//
//  AddFinancialGoalView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 03/06/25.
//


// AddFinancialGoalView.swift

import SwiftUI

struct AddFinancialGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: FinancialGoalsViewModel // Pass the ViewModel

    @State private var goalName: String = ""
    @State private var targetAmountString: String = ""
    @State private var currentAmountString: String = "0"
    @State private var deadline: Date? = nil
    @State private var hasDeadline: Bool = false

    // MARK: - UI Colors
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")
    let placeholderTextColor = Color(hex: "A0A0A0") // For TextFields

    var isFormValid: Bool {
        !goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(targetAmountString) ?? 0 > 0 &&
        (Double(currentAmountString) ?? 0) >= 0
    }

    var body: some View {
        NavigationView {
            ZStack {
                screenBackgroundColor.ignoresSafeArea()
                Form {
                    Section(header: Text("Goal Details").foregroundColor(secondaryTextColor)) {
                        TextField("Goal Name (e.g., Dream Vacation)", text: $goalName)
                            .listRowBackground(cardBackgroundColor)
                            .foregroundColor(mainTextColor)
                            .tint(accentColorTeal)

                        HStack {
                            Text("$").foregroundColor(secondaryTextColor)
                            TextField("Target Amount", text: $targetAmountString)
                                .keyboardType(.decimalPad)
                                .listRowBackground(cardBackgroundColor)
                                .foregroundColor(mainTextColor)
                                .tint(accentColorTeal)
                        }
                        
                        HStack {
                            Text("$").foregroundColor(secondaryTextColor)
                            TextField("Currently Saved (Optional)", text: $currentAmountString)
                                .keyboardType(.decimalPad)
                                .listRowBackground(cardBackgroundColor)
                                .foregroundColor(mainTextColor)
                                .tint(accentColorTeal)
                        }
                    }
                    .listRowBackground(cardBackgroundColor)


                    Section(header: Text("Deadline (Optional)").foregroundColor(secondaryTextColor)) {
                        Toggle("Set a Deadline", isOn: $hasDeadline.animation())
                            .listRowBackground(cardBackgroundColor)
                            .foregroundColor(mainTextColor)
                            .tint(accentColorTeal)

                        if hasDeadline {
                            DatePicker(
                                "Goal Deadline",
                                selection: Binding(
                                    get: { deadline ?? Date() },
                                    set: { deadline = $0 }
                                ),
                                in: Date()..., // Deadline must be in the future
                                displayedComponents: .date
                            )
                            .listRowBackground(cardBackgroundColor)
                            .accentColor(accentColorTeal)
                            .environment(\.colorScheme, .dark) // Ensures DatePicker text is light
                        }
                    }
                    .listRowBackground(cardBackgroundColor)
                    .foregroundColor(mainTextColor)
                }
                .scrollContentBackground(.hidden) // Make Form background transparent
            }
            .navigationTitle("Add New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(accentColorTeal)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .foregroundColor(accentColorTeal)
                    .disabled(!isFormValid)
                    .fontWeight(isFormValid ? .bold : .regular)
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func saveGoal() {
        guard let targetAmount = Double(targetAmountString),
              let currentAmount = Double(currentAmountString) else { return }
        
        viewModel.addGoal(
            name: goalName.trimmingCharacters(in: .whitespacesAndNewlines),
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: hasDeadline ? deadline : nil
        )
        presentationMode.wrappedValue.dismiss()
    }
}