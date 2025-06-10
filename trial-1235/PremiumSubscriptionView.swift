import SwiftUI

struct PremiumSubscriptionView: View {
    // Use @StateObject to create and own the ViewModel instance.
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var contentHasAppeared: Bool = false
    // In PremiumSubscriptionView.swift, replace the body property
    
    var body: some View {
        NavigationView { // <-- ADD THIS
            ZStack {
                Color(hex: "1C1D21").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with the close button
                    HeaderActions(dismissAction: { dismiss() })
                    
                    // All other content in a ScrollView
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 30) {
                            HeaderTextView()
                            FeaturesListView(features: viewModel.premiumFeatures)
                            PlanSelectionView(viewModel: viewModel)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // The button at the very bottom
                    SubscribeButton(viewModel: viewModel)
                }
                .foregroundColor(.white)
                .opacity(contentHasAppeared ? 1 : 0)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.5)) {
                        contentHasAppeared = true
                    }
                }
            }
            .navigationBarHidden(true) // <-- ADD THIS
            .preferredColorScheme(.dark)
        }
        .accentColor(Color(hex: "3AD7D5")) // <-- ADD THIS to color the navigation back button
    }
}
// MARK: - Helper Subviews (Corrected)

private struct HeaderActions: View {
    var dismissAction: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: dismissAction) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray.opacity(0.8))
            }
        }
        .padding([.horizontal, .top])
    }
}

private struct HeaderTextView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Unlock premium features")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text("Get access to advanced tools and insights to maximize your financial potential.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

private struct FeaturesListView: View {
    let features: [PlanFeature]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(features) { feature in
                HStack(spacing: 15) {
                    Image(systemName: feature.iconName)
                        .font(.title2)
                        .foregroundColor(Color(hex: "3AD7D5"))
                        .frame(width: 30)
                    Text(feature.text)
                        .font(.headline)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

private struct PlanSelectionView: View {
    // Use @ObservedObject to observe an existing ViewModel instance.
    @ObservedObject var viewModel: SubscriptionViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Choose your plan")
                .font(.title3).bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            // This ForEach will now work correctly.
            ForEach(viewModel.plans) { plan in
                PlanSelectionRow(
                    plan: plan,
                    // These properties now exist on the viewModel
                    isSelected: viewModel.selectedPlanId == plan.id
                )
                .onTapGesture {
                    // This method now exists on the viewModel
                    viewModel.selectPlan(planId: plan.id)
                }
            }
        }
    }
}

private struct PlanSelectionRow: View {
    let plan: MembershipPlan
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(plan.name).font(.headline)
                Text("₹\(Int(plan.price)) / \(plan.pricePeriod.split(separator: " ").last ?? "")")
                    .font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            ZStack {
                Circle().stroke(isSelected ? Color(hex: "3AD7D5") : Color.gray, lineWidth: 2)
                if isSelected {
                    Circle().fill(Color(hex: "3AD7D5")).frame(width: 14, height: 14).transition(.scale)
                }
            }.frame(width: 24, height: 24)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color(hex: "3AD7D5") : Color.clear, lineWidth: 1.5))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

private struct SubscribeButton: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                // This guard will now work as expected.
                guard let planId = viewModel.selectedPlanId else { return }
                Task {
                    await viewModel.processSubscription(planId: planId)
                }
            }) {
                if viewModel.isLoading {
                    ProgressView().progressViewStyle(.circular).tint(.black)
                } else {
                    Text("Subscribe").font(.headline.bold()).foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color(hex: "3AD7D5"))
            .cornerRadius(12)
            .disabled(viewModel.isLoading || viewModel.selectedPlanId == nil)
            .opacity(viewModel.selectedPlanId == nil ? 0.7 : 1.0)
        }
        .padding()
    }
}

// Preview
struct PremiumSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSubscriptionView()
    }
}

