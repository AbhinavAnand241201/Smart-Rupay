import SwiftUI

struct PremiumSubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            Color(hex: "1C1D21").ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // --- Header ---
                    HeaderView()
                        .padding(.bottom, 30)

                    // --- Features List ---
                    FeaturesListView(features: viewModel.premiumFeatures)
                        .padding(.bottom, 40)
                    
                    // --- Plan Selection ---
                    VStack(spacing: 15) {
                        Text("Choose your plan")
                            .font(.title3).bold()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(viewModel.plans) { plan in
                            PlanSelectionRow(
                                plan: plan,
                                isSelected: viewModel.selectedPlanId == plan.id
                            )
                            .onTapGesture {
                                viewModel.selectPlan(planId: plan.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                    
                    // --- Subscribe Button ---
                    SubscribeButton(viewModel: viewModel)
                }
                .padding()
            }
            .foregroundColor(.white)
            .opacity(contentOpacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    contentOpacity = 1.0
                }
            }
        }
        .overlay(alignment: .topLeading) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.subheadline.bold())
                    .foregroundColor(.gray)
                    .padding(12)
                    .background(.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .padding()
        }
    }
}

// MARK: - Subviews

private struct HeaderView: View {
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

private struct PlanSelectionRow: View {
    let plan: MembershipPlan
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading) {
                Text(plan.name)
                    .font(.headline)
                Text("₹\(Int(plan.price)) / \(plan.pricePeriod.split(separator: " ").last ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            if let savings = plan.savings {
                Text(savings)
                    .font(.caption.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "3AD7D5"))
                    .clipShape(Capsule())
            }
            // Custom Radio Button
            ZStack {
                Circle()
                    .stroke(isSelected ? Color(hex: "3AD7D5") : Color.gray, lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isSelected {
                    Circle()
                        .fill(Color(hex: "3AD7D5"))
                        .frame(width: 14, height: 14)
                        .transition(.scale)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(hex: "3AD7D5") : Color.clear, lineWidth: 1.5)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

private struct SubscribeButton: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    
    var body: some View {
        Button(action: {
            Task { await viewModel.processSubscription() }
        }) {
            if viewModel.isLoading {
                ProgressView().progressViewStyle(.circular)
            } else {
                Text("Subscribe")
                    .font(.headline.bold())
                    .foregroundColor(.black)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(Color(hex: "3AD7D5"))
        .cornerRadius(12)
        .shadow(color: Color(hex: "3AD7D5").opacity(0.4), radius: 8, y: 4)
        .disabled(viewModel.isLoading)
    }
}

struct PremiumSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSubscriptionView()
    }
}
