// MARK: - Data Model for a single Debt
// File: Models/DebtItem.swift

import Foundation

struct DebtItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var remainingBalance: Double
    var interestRate: Double // Annual Percentage Rate (APR)
    var minimumPayment: Double
    var debtType: DebtType = .other // For custom icons and grouping

    enum DebtType: String, Codable, CaseIterable {
        case creditCard = "Credit Card"
        case personalLoan = "Personal Loan"
        case autoLoan = "Auto Loan"
        case studentLoan = "Student Loan"
        case mortgage = "Mortgage"
        case other = "Other"
    }

    // A computed property to know when it's paid off
    var isPaidOff: Bool {
        return remainingBalance <= 0
    }
}