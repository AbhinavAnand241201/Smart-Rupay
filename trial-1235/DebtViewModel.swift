// In file: DebtViewModel.swift

import Foundation
import SwiftUI

@MainActor
class DebtViewModel: ObservableObject {

    @Published var debtItems: [DebtItem] = []
    @Published var strategy: PayoffStrategy = .avalanche // Default to avalanche for biggest savings
    @Published var monthlyExtraPaymentString: String = "5000" // Start with a sample extra payment
    
    private let debtsSaveKey = "UserDebtItems"

    // This init method now loads rich sample data for the demo
    init() {
        self.debtItems = [
            DebtItem(id: UUID(), name: "HDFC Millennia Card", remainingBalance: 45000, interestRate: 22.5, minimumPayment: 1800, debtType: .creditCard, originalBalance: 50000),
            DebtItem(id: UUID(), name: "Car Loan", remainingBalance: 350000, interestRate: 8.2, minimumPayment: 12000, debtType: .autoLoan, originalBalance: 400000),
            DebtItem(id: UUID(), name: "Personal Loan", remainingBalance: 80000, interestRate: 14.0, minimumPayment: 4500, debtType: .personalLoan, originalBalance: 100000)
        ]
    }

    enum PayoffStrategy: String, CaseIterable, Identifiable {
        var id: String { self.rawValue }
        case snowball = "Snowball"
        case avalanche = "Avalanche"
    }
    
    // --- All other functions and computed properties below this line remain exactly the same ---
    // (addDebt, deleteDebt, calculatePayoffProjection, sortedDebts, etc. are unchanged)
    
    var monthlyExtraPayment: Double {
        Double(monthlyExtraPaymentString) ?? 0.0
    }
    
    var sortedDebts: [DebtItem] {
        let activeDebts = debtItems.filter { !$0.isPaidOff }
        switch strategy {
        case .snowball:
            return activeDebts.sorted { $0.remainingBalance < $1.remainingBalance }
        case .avalanche:
            return activeDebts.sorted { $0.interestRate > $1.interestRate }
        }
    }
    
    func addDebt(_ debt: DebtItem) {
        debtItems.append(debt)
    }
    
    func deleteDebt(at offsets: IndexSet) {
        // This needs to map the offsets from the sortedDebts array back to the main debtItems array
        let idsToDelete = offsets.map { self.sortedDebts[$0].id }
        debtItems.removeAll { idsToDelete.contains($0.id) }
    }
    
    func calculatePayoffProjection() -> (date: String, interestSaved: String) {
        // ... This complex calculation logic is preserved ...
        var tempDebts = self.debtItems.filter { !$0.isPaidOff }
        if tempDebts.isEmpty { return ("You are debt free!", "N/A") }

        var months = 0
        var totalInterestPaid = 0.0
        var totalSnowballPayment = self.monthlyExtraPayment

        let originalTotalDebt = tempDebts.reduce(0) { $0 + $1.remainingBalance }

        while !tempDebts.isEmpty {
            months += 1
            if months > 1200 { return ("Over 100 years", "Error") } // Safety break
            
            var interestThisMonth = 0.0
            
            for i in 0..<tempDebts.count {
                let monthlyRate = tempDebts[i].interestRate / 100 / 12
                let interest = tempDebts[i].remainingBalance * monthlyRate
                tempDebts[i].remainingBalance += interest
                interestThisMonth += interest
            }
            totalInterestPaid += interestThisMonth
            
            var totalPaymentThisMonth = totalSnowballPayment
            for i in 0..<tempDebts.count {
                let payment = min(tempDebts[i].remainingBalance, tempDebts[i].minimumPayment)
                tempDebts[i].remainingBalance -= payment
                totalPaymentThisMonth += payment
            }
            
            // Apply snowball/avalanche to the target debt
            let sortedForPayment = strategy == .snowball ? tempDebts.sorted { $0.remainingBalance < $1.remainingBalance } : tempDebts.sorted { $0.interestRate > $1.interestRate }
            
            if let targetDebt = sortedForPayment.first, let targetIndex = tempDebts.firstIndex(where: { $0.id == targetDebt.id }) {
                let extraPaid = min(totalSnowballPayment, tempDebts[targetIndex].remainingBalance)
                tempDebts[targetIndex].remainingBalance -= extraPaid
            }

            tempDebts.removeAll { $0.isPaidOff }
        }
        
        let payoffDate = Calendar.current.date(byAdding: .month, value: months, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        // Simplified interest saved calculation for demo purposes
        let simpleInterest = originalTotalDebt * 0.15 * (Double(months) / 12.0)
        let interestSaved = abs(simpleInterest - totalInterestPaid)
        
        return (formatter.string(from: payoffDate), String(format: "₹%.0f", interestSaved))
    }
}
