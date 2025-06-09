import Foundation

struct PlanFeature: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let iconName: String
}

struct MembershipPlan: Identifiable, Hashable {
    let id: String
    let name: String
    let price: Double
    let pricePeriod: String
    let features: [PlanFeature]
    let highlight: Bool
    var savings: String?
}

enum PaymentMethod: Identifiable {
    case stripe, razorpay
    
    var id: String {
        switch self {
        case .stripe: return "stripe"
        case .razorpay: return "razorpay"
        }
    }
    
    var title: String {
        switch self {
        case .stripe: return "Stripe"
        case .razorpay: return "Razorpay"
        }
    }
    
    var logoName: String {
        switch self {
        case .stripe: return "stripe_logo"
        case .razorpay: return "razorpay_logo"
        }
    }
}