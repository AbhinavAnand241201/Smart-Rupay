// In file: PremiumSubscriptionView.swift

import SwiftUI

struct PremiumSubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var contentHasAppeared: Bool = false

    var body: some View {
        // The view is already wrapped in a NavigationView from our previous fix
        ZStack {
            // A more dynamic and premium background
            RadialGradient(
                gradient: Gradient(colors: [Color.App.accentPurple.opacity(0.3), Color.App.background]),
                center: .top,
                startRadius: 5,
                endRadius: 800
            ).ignoresSafeArea()
            
            Color.App.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderActions(dismissAction: { dismiss() })
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) { // Increased spacing for a more premium feel
                        HeaderTextView()
                        FeaturesListView(features: viewModel.premiumFeatures)
                        PlanSelectionView(viewModel: viewModel)
                    }
                    .padding()
                    .padding(.bottom, 120) // Ensure space for the floating button
                }
            }
            .overlay(alignment: .bottom) {
                SubscribeButton(viewModel: viewModel)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .opacity(contentHasAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                contentHasAppeared = true
            }
        }
    }
}

// MARK: - Redesigned Helper Subviews

private struct HeaderActions: View {
    var dismissAction: () -> Void
    var body: some View {
        HStack {
            Spacer()
            Button(action: dismissAction) {
                Image(systemName: "xmark")
                    .font(.body.weight(.bold))
                    .foregroundColor(Color.App.textSecondary)
                    .padding(8)
                    .background(Color.App.card.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding([.horizontal, .top])
    }
}

private struct HeaderTextView: View {
    var body: some View {
        VStack(spacing: 16) {
            // A prominent icon to convey "premium"
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    .linearGradient(
                        colors: [Color(hex: "#FFD700"), Color.App.accentOrange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.App.accentOrange.opacity(0.5), radius: 10)
            
            Text("Unlock Premium")
                .font(.largeTitle.bold())
                .foregroundColor(Color.App.textPrimary)
            
            Text("Get unlimited access to our most powerful features and insights.")
                .font(.headline)
                .foregroundColor(Color.App.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct FeaturesListView: View {
    let features: [PlanFeature]
    // A palette of colors for the feature icons
    private let iconColors: [Color] = [.App.accent, .App.accentGreen, .App.accentBlue, .App.accentPurple]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(features.indices, id: \.self) { index in
                HStack(spacing: 16) {
                    Image(systemName: features[index].iconName)
                        .font(.headline.weight(.bold))
                        .foregroundColor(iconColors[index % iconColors.count])
                        .frame(width: 36, height: 36)
                        .background(iconColors[index % iconColors.count].opacity(0.15))
                        .clipShape(Circle())
                    
                    Text(features[index].text)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.App.textPrimary)
                }
            }
        }
    }
}

private struct PlanSelectionView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    var body: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.plans) { plan in
                PlanSelectionRow(
                    plan: plan,
                    isSelected: viewModel.selectedPlanId == plan.id
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.selectPlan(planId: plan.id)
                    }
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
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.name)
                    .font(.title3.bold())
                Text("₹\(Int(plan.price)) / \(plan.pricePeriod.split(separator: " ").last ?? "")")
                    .font(.subheadline)
                    .foregroundColor(Color.App.textSecondary)
            }
            Spacer()
            if let savings = plan.savings {
                Text(savings)
                    .font(.caption.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.App.accentGreen)
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(Color.App.card)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.App.accent : Color.clear, lineWidth: 2.5)
        )
        .shadow(color: .black.opacity(0.2), radius: isSelected ? 10 : 0)
    }
}

private struct SubscribeButton: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    
    var body: some View {
        VStack {
            NavigationLink(
                destination: {
                    if let plan = viewModel.selectedPlan {
                        CheckoutView(plan: plan)
                            .environmentObject(viewModel)
                    }
                },
                label: {
                    Text("Continue")
                        .font(.headline.bold())
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.App.accent)
                        .cornerRadius(16)
                        .shadow(color: Color.App.accent.opacity(0.4), radius: 10, y: 5)
                }
            )
            .disabled(viewModel.selectedPlanId == nil)
            .opacity(viewModel.selectedPlanId == nil ? 0.6 : 1.0)
        }
        .padding(.horizontal, 30)
        .padding(.top)
        .padding(.bottom, 20)
    }
}

// MARK: - Preview
struct PremiumSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSubscriptionView()
    }
}
