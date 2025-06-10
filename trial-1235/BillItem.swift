

import Foundation

struct BillItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var dueDate: Date
    var category: BillCategory = .other
    var paymentURL: String? // Optional: for a "Pay Now" button
    var isPaid: Bool = false
    
    var isUrgent: Bool {
        // Due within the next 24 hours and not yet paid
        return !isPaid && dueDate > Date() && dueDate < Date().addingTimeInterval(24 * 60 * 60)
    }
}

enum BillCategory: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case creditCard = "Credit Card"
    case utility = "Utility"
    case subscription = "Subscription"
    case rent = "Rent"
    case loan = "Loan"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .creditCard: "creditcard.fill"
        case .utility: "bolt.fill"
        case .subscription: "arrow.2.squarepath"
        case .rent: "house.fill"
        case .loan: "dollarsign.circle.fill"
        case .other: "tag.fill"
        }
    }
}