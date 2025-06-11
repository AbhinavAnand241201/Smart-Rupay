// In file: TransactionDetailView.swift

import SwiftUI

struct TransactionDetailView: View {
    // MARK: - Properties
    let transaction: TransactionDetail
    @State private var isPresentingEditSheet = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // A new "hero" section to make the amount the focus
                    HeaderView(transaction: transaction)
                    
                    // Details are now organized in a clean card
                    DetailsCard(transaction: transaction)
                }
                .padding(.top, 20)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Transaction Details")
                    .fontWeight(.bold) // You can use .bold, .semibold, or .heavy
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isPresentingEditSheet.toggle()
                }
                .tint(Color.App.accent)
            }
        }
        .sheet(isPresented: $isPresentingEditSheet) {
            // The editing functionality is preserved
            AddTransactionView(transactionToEdit: transaction)
        }
    }
}


// MARK: - Subviews

private struct HeaderView: View {
    let transaction: TransactionDetail
    
    var body: some View {
        VStack(spacing: 8) {
            // Displaying the icon in our standard modern style
            Image(systemName: transaction.iconName)
                .font(.title.weight(.semibold))
                .foregroundColor(transaction.iconBackgroundColor)
                .frame(width: 60, height: 60)
                .background(transaction.iconBackgroundColor.opacity(0.15))
                .clipShape(Circle())
            
            // Large, clear amount
            Text("₹\(transaction.amount, specifier: "%.2f")")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(transaction.isCredit ? .App.accentGreen : .App.textPrimary)
            
            Text(transaction.name)
                .font(.title3)
                .foregroundColor(Color.App.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}

private struct DetailsCard: View {
    let transaction: TransactionDetail
    
    var body: some View {
        VStack(spacing: 0) {
            DetailRow(label: "Category", value: transaction.category)
            Divider().background(Color.App.background)
            DetailRow(label: "Date", value: transaction.date.formatted(date: .long, time: .omitted))
            Divider().background(Color.App.background)
            DetailRow(label: "Status", value: "Completed", valueColor: .App.accentGreen)
        }
        .background(Color.App.card)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .App.textPrimary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.App.textSecondary)
            Spacer()
            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundColor(valueColor)
        }
        .padding()
    }
}


// MARK: - Preview
struct TransactionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample transaction to preview
        let sampleTransaction = TransactionDetail(
            id: UUID(),
            date: Date(),
            iconName: "cart.fill",
            iconBackgroundColorHex: "#30D158", // Corresponds to Color.App.accentGreen
            name: "Weekly Groceries",
            category: "Groceries",
            amount: -3450.75
        )
        
        NavigationView {
            TransactionDetailView(transaction: sampleTransaction)
                .preferredColorScheme(.dark)
        }
    }
}
