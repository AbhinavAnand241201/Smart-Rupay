//
//  SubscriptionViewModel.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 09/06/25.
//


import Foundation

@MainActor
class SubscriptionViewModel: ObservableObject {
    // The available plans to show on the screen.
    @Published var plans: [MembershipPlan] = []
    
    // The user's currently selected plan.
    @Published var selectedPlanId: String?
    
    // State properties for handling the subscription process.
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        fetchAvailablePlans()
    }
    
    // In a real app, this would be an API call to your backend.
    // For now, we'll use local sample data.
    func fetchAvailablePlans() {
        self.plans = [
            MembershipPlan(
                id: "monthly",
                name: "Monthly",
                price: 299,
                pricePeriod: "per month",
                features: [
                    "Unlimited Budgets",
                    "Unlimited Financial Goals",
                    "AI Financial Planner",
                    "Export Transactions"
                ],
                highlight: false
            ),
            MembershipPlan(
                id: "yearly_pro",
                name: "Yearly",
                price: 1999,
                pricePeriod: "per year",
                features: [
                    "Everything in Monthly",
                    "Save 40% with annual billing",
                    "Priority Customer Support",
                    "Advanced AI Insights"
                ],
                highlight: true // This will make the card stand out
            )
        ]
        
        // Default selection to the highlighted plan
        self.selectedPlanId = self.plans.first(where: { $0.highlight })?.id
    }
    
    func selectPlan(planId: String) {
        self.selectedPlanId = planId
    }
    
    func processSubscription() async {
        guard let planId = selectedPlanId else {
            self.errorMessage = "Please select a plan."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // This is where you will trigger the backend payment process.
        // For now, we simulate a network delay.
        print("Initiating subscription process for plan: \(planId)...")
        
        do {
            // Simulate a network call that takes 2 seconds
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            // On success from the backend:
            print("Subscription successful!")
            // You would then update the user's subscription status and dismiss the view.
            
        } catch {
            self.errorMessage = "An error occurred. Please try again."
        }
        
        isLoading = false
    }
}