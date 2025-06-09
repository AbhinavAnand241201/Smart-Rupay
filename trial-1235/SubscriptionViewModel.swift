
import Foundation

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var premiumFeatures: [PlanFeature] = []
    @Published var plans: [MembershipPlan] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        fetchData()
    }
    
    func fetchData() {
    }
    
    func processSubscription(planId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let clientSecret = try await NetworkService.shared.createPaymentIntent(planId: planId)
            print("Successfully received client secret from server.")

            try await Task.sleep(nanoseconds: 1_500_000_000)
            print("Simulated payment with SDK was successful.")

            let fulfillmentResponse = try await NetworkService.shared.fulfillSubscription(planId: planId)
            print("Server confirmation: \(fulfillmentResponse.message)")
            
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
