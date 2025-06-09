//
//  to.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 09/06/25.
//


import Foundation

// ENHANCEMENT: A new struct to hold details for each feature, including an icon.
struct PlanFeature: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let iconName: String
}

// Represents a single subscription plan that the app offers.
struct MembershipPlan: Identifiable, Hashable {
    let id: String // e.g., "monthly_pro", "yearly_pro"
    let name: String
    let price: Double
    let pricePeriod: String // e.g., "per month", "per year"
    let features: [PlanFeature] // ENHANCEMENT: Uses the new PlanFeature struct
    let highlight: Bool
    var savings: String? // e.g., "Save 40%"
}

// Represents the available payment methods.
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
    
    // In a real app, you would use actual logo images here.
    var logoName: String {
        switch self {
        case .stripe: return "stripe_logo" // Placeholder for an asset name
        case .razorpay: return "razorpay_logo" // Placeholder for an asset name
        }
    }
}