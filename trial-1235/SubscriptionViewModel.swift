//
//  SubscriptionViewModel.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 11/06/25.
//


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

enum PaymentMethod: Identifiable , CaseIterable{
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

// The rest of your SubscriptionViewModel class goes below...

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var premiumFeatures: [PlanFeature] = []
    @Published var plans: [MembershipPlan] = []
    @Published var selectedPlanId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?


    var selectedPlan: MembershipPlan? {
        guard let selectedPlanId = selectedPlanId else { return nil }
        return plans.first { $0.id == selectedPlanId }
    }
    
    init() {
        fetchData()
    }
    
    func selectPlan(planId: String) {
        // If the same plan is tapped again, deselect it. Otherwise, select the new one.
        if selectedPlanId == planId {
            selectedPlanId = nil
        } else {
            selectedPlanId = planId
        }
    }
    
    // In SubscriptionViewModel.swift, replace the existing fetchData function with this one.

        func fetchData() {
            self.premiumFeatures = [
                .init(text: "Advanced Analytics", iconName: "chart.bar.xaxis"),
                .init(text: "Market Trend Insights", iconName: "arrow.up.right.dots"),
                .init(text: "Real-time Alerts", iconName: "bell.badge.fill"),
                .init(text: "Priority Support", iconName: "person.3.fill")
            ]
            
            self.plans = [
                .init(id: "monthly_pro", name: "Monthly Pro", price: 499, pricePeriod: "per month", features: [], highlight: false),
                .init(id: "annual_pro", name: "Annual Pro", price: 3999, pricePeriod: "per year", features: [], highlight: true, savings: "Save 20%")
            ]
        }
    
    func processSubscription(planId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // let _ = try await NetworkService.shared.createPaymentIntent(planId: planId)
            print("Successfully received client secret from server.")

            try await Task.sleep(nanoseconds: 2_000_000_000)
            print("Simulated payment with SDK was successful.")

            // let _ = try await NetworkService.shared.fulfillSubscription(planId: planId)
            print("Server confirmation received.")
            
            isLoading = false
            return true

        } catch {
            errorMessage = error.localizedDescription
            print("Subscription process failed: \(errorMessage ?? "Unknown error")")
            isLoading = false
            return false
        }
    }
}
