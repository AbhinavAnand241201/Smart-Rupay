//
//  AddBudgetView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 08/06/25.
//


import SwiftUI

struct AddBudgetView: View {
    @EnvironmentObject var viewModel: BudgetViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var amountString: String = ""
    
    private var isFormValid: Bool {
        !name.isEmpty && !amountString.isEmpty && Double(amountString) != nil
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()
                
                Form {
                    Section(header: Text("Budget Details").foregroundColor(.gray)) {
                        TextField("Budget Name (e.g., Groceries)", text: $name)
                            .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                        
                        HStack {
                            Text("₹")
                                .foregroundColor(.gray)
                            TextField("Monthly Amount", text: $amountString)
                                .keyboardType(.decimalPad)
                        }
                        .listRowBackground(Color(red: 0.15, green: 0.16, blue: 0.18))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .tint(Color(hex: "3AD7D5"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBudget()
                    }
                    .tint(Color(hex: "3AD7D5"))
                    .disabled(!isFormValid)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func saveBudget() {
        guard let amount = Double(amountString) else { return }
        viewModel.addBudget(name: name, amount: amount)
        dismiss()
    }
}




