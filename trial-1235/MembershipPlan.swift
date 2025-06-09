//
//  MembershipPlan.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 09/06/25.
//


import Foundation
import SwiftUI

// Represents a single subscription plan that the app offers.
struct MembershipPlan: Identifiable, Hashable {
    let id: String // e.g., "monthly", "yearly"
    let name: String
    let price: Double
    let pricePeriod: String // e.g., "per month", "per year"
    let features: [String]
    let highlight: Bool // To make one plan stand out (e.g., "Most Popular")
    var pricePerMonth: Double {
        // Helper to compare plans
        if id.contains("yearly") {
            return price / 12.0
        }
        return price
    }
}

// Represents the current user's subscription status.
struct UserSubscription: Codable {
    let planId: String
    let subscribedUntil: Date
    var isActive: Bool {
        return subscribedUntil > Date()
    }
}