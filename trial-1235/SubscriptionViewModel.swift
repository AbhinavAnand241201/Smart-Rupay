import Foundation

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var plans: [MembershipPlan] = []
    @Published var selectedPlanId: String? // We can still use this if needed elsewhere
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        fetchAvailablePlans()
    }
    
    func fetchAvailablePlans() {
        self.plans = [
            MembershipPlan(
                id: "monthly",
                name: "Monthly",
                price: 299,
                pricePeriod: "per month",
                features: [
                    .init(text: "Unlimited Budgets", iconName: "chart.pie.fill"),
                    .init(text: "Unlimited Financial Goals", iconName: "target"),
                    .init(text: "AI Financial Planner", iconName: "brain.head.profile"),
                    .init(text: "Export All Transactions", iconName: "square.and.arrow.up.fill")
                ],
                highlight: false,
                savings: nil
            ),
            MembershipPlan(
                id: "yearly_pro",
                name: "Yearly",
                price: 1999,
                pricePeriod: "per year",
                features: [
                    .init(text: "Everything in Monthly", iconName: "plus.diamond.fill"),
                    .init(text: "Priority Customer Support", iconName: "phone.bubble.fill"),
                    .init(text: "Advanced AI Insights", iconName: "sparkles"),
                    .init(text: "Exclusive App Icons", iconName: "app.gift.fill")
                ],
                highlight: true,
                savings: "SAVE 40%" // Explicit savings text
            )
        ]
        self.selectedPlanId = self.plans.first(where: { $0.highlight })?.id
    }

    func processSubscription() async {
        isLoading = true
        errorMessage = nil
        print("Initiating subscription process...")
        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            print("Subscription successful!")
        } catch {
            self.errorMessage = "An error occurred."
        }
        isLoading = false
    }
}
