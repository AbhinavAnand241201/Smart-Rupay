import Foundation
import SwiftUI

struct DebtItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var remainingBalance: Double
    var interestRate: Double
    var minimumPayment: Double
    var debtType: DebtType = .other
    var originalBalance: Double?

    var isPaidOff: Bool {
        return remainingBalance <= 0
    }

    enum DebtType: String, Codable, CaseIterable, Identifiable {
        var id: String { self.rawValue }
        case creditCard = "Credit Card"
        case personalLoan = "Personal Loan"
        case autoLoan = "Auto Loan"
        case studentLoan = "Student Loan"
        case mortgage = "Mortgage"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .creditCard: "creditcard.fill"
            case .personalLoan: "person.fill"
            case .autoLoan: "car.fill"
            case .studentLoan: "graduationcap.fill"
            case .mortgage: "house.fill"
            case .other: "dollarsign.circle.fill"
            }
        }
    }
}
