//
//  TransactionDetailView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 11/06/25.
//

import SwiftUI

struct TransactionDetailView: View {
    let transaction: TransactionDetail
    
    // State to control the presentation of the edit sheet
    @State private var isPresentingEditSheet = false
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(transaction.name)
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Amount")
                    Spacer()
                    Text(String(format: "₹%.2f", transaction.amount))
                        .foregroundColor(transaction.isCredit ? .green : .primary)
                }
                HStack {
                    Text("Category")
                    Spacer()
                    Text(transaction.category)
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Date")
                    Spacer()
                    Text(transaction.date, style: .date)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isPresentingEditSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $isPresentingEditSheet) {
            // Present the existing AddTransactionView, but for editing
            AddTransactionView(transactionToEdit: transaction)
        }
    }
}


struct TransactionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample transaction to preview
        let sampleTransaction = TransactionDetail(
            id: UUID(),
            date: Date(),
            iconName: "cart.fill",
            iconBackgroundColorHex: "#2c2c2e",
            name: "Sample Grocery Purchase",
            category: "Groceries",
            amount: -125.50
        )
        
        // Wrap the view in a NavigationView for the preview to look correct
        NavigationView {
            TransactionDetailView(transaction: sampleTransaction)
                .preferredColorScheme(.dark)
        }
    }
}
