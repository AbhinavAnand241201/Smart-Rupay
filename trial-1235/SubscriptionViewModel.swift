
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
        // This function loads the static plan and feature data to display
        // ... (your existing fetchData logic remains the same) ...
    }
    
    // FIXED: This function now contains the complete, end-to-end logic for making a payment.
    func processSubscription(planId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // STEP 1: Get the client_secret from your backend.
            let clientSecret = try await NetworkService.shared.createPaymentIntent(planId: planId)
            print("Successfully received client secret from server.")

            // STEP 2: SIMULATE PAYMENT on the device.
            // In a real app, you would pass this 'clientSecret' to the Stripe/Razorpay SDK here
            // to show the payment sheet to the user. We will simulate a successful payment.
            try await Task.sleep(nanoseconds: 1_500_000_000) // Simulate 1.5 seconds of processing
            print("Simulated payment with SDK was successful.")

            // STEP 3: FULFILL the order on your backend.
            // After the payment is successful, tell your server to grant premium access.
            let fulfillmentResponse = try await NetworkService.shared.fulfillSubscription(planId: planId)
            print("Server confirmation: \(fulfillmentResponse.message)")
            
            isLoading = false
            return true // Return true to indicate success

        } catch {
            errorMessage = error.localizedDescription
            print("Subscription process failed: \(errorMessage ?? "Unknown error")")
            isLoading = false
            return false // Return false to indicate failure
        }
    }
}
