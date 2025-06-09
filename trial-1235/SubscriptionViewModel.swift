import Foundation

@MainActor
class SubscriptionViewModel: ObservableObject {
    // A separate list of features to display at the top of the screen.
    @Published var premiumFeatures: [PlanFeature] = []
    
    // The available subscription plans.
    @Published var plans: [MembershipPlan] = []
    
    @Published var selectedPlanId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        // This data now matches the new design from your screenshot.
        self.premiumFeatures = [
            .init(text: "AI-powered financial advisor", iconName: "sparkles.square.filled.on.square"),
            .init(text: "Personalized investment recommendations", iconName: "chart.line.uptrend.xyaxis"),
            .init(text: "Advanced budgeting and forecasting", iconName: "dollarsign.arrow.circlepath"),
            .init(text: "Priority customer support", iconName: "headphones.circle.fill")
        ]
        
        self.plans = [
            MembershipPlan(
                id: "monthly",
                name: "Monthly",
                price: 829, // Approx $9.99
                pricePeriod: "per month",
                features: [], // Features are now displayed globally
                highlight: false,
                savings: nil
            ),
            MembershipPlan(
                id: "yearly_pro",
                name: "Annual",
                price: 8299, // Approx $99.99
                pricePeriod: "per year",
                features: [],
                highlight: true,
                savings: "SAVE 17%"
            )
        ]
        
        // Default selection to the annual plan
        self.selectedPlanId = self.plans.first(where: { $0.highlight })?.id
    }
    
    func selectPlan(planId: String) {
        self.selectedPlanId = planId
    }
    
    func processSubscription() async {
        // ... (Your existing subscription processing logic remains here) ...
    }
}
