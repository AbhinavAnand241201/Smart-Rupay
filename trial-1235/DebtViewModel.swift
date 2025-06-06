// File: ViewModels/DebtViewModel.swift

import Foundation
import SwiftUI

@MainActor
class DebtViewModel: ObservableObject {

    @Published var debtItems: [DebtItem] = []
    @Published var strategy: PayoffStrategy = .snowball
    @Published var monthlyExtraPaymentString: String = "0"
    
    // MARK: - Data Persistence
        private let debtsSaveKey = "UserDebtItems"

        private func saveDebts() {
            do {
                let data = try JSONEncoder().encode(debtItems)
                UserDefaults.standard.set(data, forKey: debtsSaveKey)
            } catch {
                print("Failed to save debts: \(error.localizedDescription)")
            }
        }

        private func loadDebts() {
            guard let data = UserDefaults.standard.data(forKey: debtsSaveKey) else {
                // If no saved data, you can start with an empty list
                // or generate sample data for the very first launch.
                // For now, we'll start empty.
                self.debtItems = []
                return
            }
            
            do {
                self.debtItems = try JSONDecoder().decode([DebtItem].self, from: data)
            } catch {
                print("Failed to load debts: \(error.localizedDescription)")
                // If loading fails, start with an empty list to prevent a crash
                self.debtItems = []
            }
        }

    enum PayoffStrategy: String, CaseIterable, Identifiable {
        var id: String { self.rawValue }
        case snowball = "Snowball" // Pay lowest balance first
        case avalanche = "Avalanche" // Pay highest interest first
    }
    
    // Sample data for easy previewing
//    init() {
//        self.debtItems = [
//            DebtItem(id: UUID(), name: "ICICI Credit Card", remainingBalance: 45000, interestRate: 22.5, minimumPayment: 1800, debtType: .creditCard, originalBalance: 50000),
//            DebtItem(id: UUID(), name: "Car Loan", remainingBalance: 350000, interestRate: 8.2, minimumPayment: 12000, debtType: .autoLoan, originalBalance: 400000),
//            DebtItem(id: UUID(), name: "Personal Loan", remainingBalance: 80000, interestRate: 14.0, minimumPayment: 4500, debtType: .personalLoan, originalBalance: 100000)
//        ]
//    }
    
    // What to change
        init() {
            loadDebts()
        }

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

    var totalOutstandingDebt: Double {
        debtItems.reduce(0) { $0 + $1.remainingBalance }
    }
    
    var totalMinimumPayments: Double {
        debtItems.filter { !$0.isPaidOff }.reduce(0) { $0 + $1.minimumPayment }
    }

    func addDebt(_ debt: DebtItem) {
        debtItems.append(debt)
        saveDebts()
    }

    func updateDebt(_ debt: DebtItem) {
        if let index = debtItems.firstIndex(where: { $0.id == debt.id }) {
            debtItems[index] = debt
            saveDebts()
        }
    }
    
    func deleteDebt(at offsets: IndexSet) {
        debtItems.remove(atOffsets: offsets)
        saveDebts()
    }
    
    // Powerful payoff projection logic
    func calculatePayoffProjection() -> (date: String, interestSaved: String) {
        var tempDebts = self.debtItems.filter { !$0.isPaidOff }
        if tempDebts.isEmpty { return ("You are debt free!", "N/A") }

        var months = 0
        var totalInterestPaid = 0.0
        // **FIXED HERE**: Variable name corrected from 'total snowballPayment'
        var totalSnowballPayment = self.monthlyExtraPayment

        while !tempDebts.isEmpty {
            months += 1
            var interestThisMonth = 0.0
            
            // 1. Accrue interest for the month
            for i in 0..<tempDebts.count {
                let monthlyRate = tempDebts[i].interestRate / 100 / 12
                let interest = tempDebts[i].remainingBalance * monthlyRate
                tempDebts[i].remainingBalance += interest
                interestThisMonth += interest
            }
            totalInterestPaid += interestThisMonth
            
            // 2. Make minimum payments
            for i in 0..<tempDebts.count {
                tempDebts[i].remainingBalance -= tempDebts[i].minimumPayment
            }
            
            // 3. Apply snowball to the target debt
            let sortedForPayment = strategy == .snowball ? tempDebts.sorted { $0.remainingBalance < $1.remainingBalance } : tempDebts.sorted { $0.interestRate > $1.interestRate }
            
            if let targetDebt = sortedForPayment.first, let targetIndex = tempDebts.firstIndex(where: { $0.id == targetDebt.id }) {
                 // **FIXED HERE**: Variable name corrected
                tempDebts[targetIndex].remainingBalance -= totalSnowballPayment
            }

            // 4. Check for paid off debts and add their min payment to the snowball
            let paidOffDebts = tempDebts.filter { $0.isPaidOff }
            for debt in paidOffDebts {
                // **FIXED HERE**: Variable name corrected
                totalSnowballPayment += debt.minimumPayment
            }
            tempDebts.removeAll { $0.isPaidOff }
        }
        
        let payoffDate = Calendar.current.date(byAdding: .month, value: months, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        // This is a simplified interest saved calculation for demonstration
        let simplifiedOriginalInterest = (totalOutstandingDebt * 0.15 * (Double(months)/12.0))
        let interestSaved = simplifiedOriginalInterest - totalInterestPaid
        
        return (formatter.string(from: payoffDate), String(format: "₹%.0f", interestSaved > 0 ? interestSaved : 0))
    }
}
