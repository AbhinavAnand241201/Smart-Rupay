import SwiftUI

struct PremiumSubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.dismiss) var dismiss

    // Animation state
    @State private var showContent = false

    var body: some View {
        ZStack {
            // ENHANCEMENT: A more dynamic and layered background
            backgroundView

            ScrollView {
                VStack(spacing: 25) {
                    // --- Header ---
                    SubscriptionHeaderView()
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -30)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    // --- Plan Selection Cards ---
                    VStack(spacing: 15) {
                        ForEach(Array(viewModel.plans.enumerated()), id: \.element.id) { index, plan in
                            PlanCardView(
                                plan: plan,
                                isSelected: viewModel.selectedPlanId == plan.id
                            )
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : -30)
                            // ENHANCEMENT: Staggered animation for each card
                            .animation(.easeOut(duration: 0.5).delay(0.4 + Double(index) * 0.2), value: showContent)
                            .onTapGesture {
                                viewModel.selectPlan(planId: plan.id)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // --- Action Button ---
                    SubscriptionButtonView(viewModel: viewModel)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -30)
                        .animation(.easeOut(duration: 0.5).delay(0.8), value: showContent)

                    Text("Recurring billing. Cancel anytime from your App Store account.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            showContent = true
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray.opacity(0.8))
            }
            .padding()
        }
    }
    
    // ENHANCEMENT: Extracted background view for clarity and layering
    var backgroundView: some View {
        ZStack {
            Color(hex: "0D0E0F").ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: "3AD7D5").opacity(0.2), .clear]),
                center: .top,
                startRadius: 10,
                endRadius: 400
            ).ignoresSafeArea()
            
            Circle()
                .fill(Color(hex: "5E5CE6").opacity(0.1))
                .frame(width: 300)
                .blur(radius: 100)
                .offset(x: -150, y: 100)
        }
    }
}


// MARK: - Subviews for Better Organization

private struct SubscriptionHeaderView: View {
    @State private var isGlowing = false

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // ENHANCEMENT: Glowing effect for the icon
                Image(systemName: "star.shield.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: "FFD700").opacity(0.5))
                    .blur(radius: isGlowing ? 15 : 5)
                
                Image(systemName: "star.shield.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FDB827")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever()) {
                    isGlowing.toggle()
                }
            }
            
            Text("Unlock Smart-Rupay Pro")
                .font(.largeTitle.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            
            Text("Get unlimited access to all premium features and take full control of your finances.")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 40)
    }
}

private struct PlanCardView: View {
    let plan: MembershipPlan
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.title2).bold()
                    Text("₹\(Int(plan.price))")
                        .font(.title.weight(.medium))
                    + Text(" / \(plan.pricePeriod.split(separator: " ").last ?? "")")
                        .font(.headline.weight(.regular))
                        .foregroundColor(.gray)
                }
                Spacer()
                if plan.highlight {
                    // ENHANCEMENT: More prominent "Save" badge
                    Text("SAVE 40%")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: "3AD7D5"))
                        .clipShape(Capsule())
                }
            }
            
            Divider().background(isSelected ? Color.white.opacity(0.5) : .gray.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.features, id: \.self) { feature in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "3AD7D5"))
                        Text(feature)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .font(.subheadline)
        }
        .foregroundColor(.white)
        .padding()
        .background(.ultraThinMaterial.opacity(0.4))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color(hex: "3AD7D5") : Color.gray.opacity(0.3), lineWidth: isSelected ? 2.5 : 1)
        )
        .scaleEffect(isSelected ? 1.0 : 0.98)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

private struct SubscriptionButtonView: View {
    @ObservedObject var viewModel: SubscriptionViewModel

    var body: some View {
        VStack(spacing: 12) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                Task {
                    await viewModel.processSubscription()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Upgrade to Pro")
                        .font(.headline).bold()
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            // ENHANCEMENT: More visually appealing button style
            .background(
                LinearGradient(
                    colors: [Color(hex: "3AD7D5"), Color(hex: "2DD0CE")],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .shadow(color: Color(hex: "3AD7D5").opacity(0.4), radius: 8, y: 4)
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}

struct PremiumSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSubscriptionView()
    }
}
