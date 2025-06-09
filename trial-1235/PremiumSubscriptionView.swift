import SwiftUI

struct PremiumSubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var showContent = false

    var body: some View {
        // The NavigationView is essential for the sub-navigation to the CheckoutView.
        NavigationView {
            ZStack {
                AnimatedAuroraBackground()

                // FIXED: The ScrollView now ignores the top safe area, allowing the
                // background and content to go all the way to the top edge of the screen.
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 25) {
                        SubscriptionHeaderView()
                            .opacity(showContent ? 1 : 0)
                            .scaleEffect(showContent ? 1 : 0.95)
                            .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)

                        VStack(spacing: 15) {
                            ForEach(Array(viewModel.plans.enumerated()), id: \.element.id) { index, plan in
                                NavigationLink(destination: CheckoutView(plan: plan).environmentObject(viewModel)) {
                                    PlanCardView(plan: plan, index: index)
                                }
                                .opacity(showContent ? 1 : 0)
                                .scaleEffect(showContent ? 1 : 0.95)
                                .animation(.easeOut(duration: 0.6).delay(0.4 + Double(index) * 0.2), value: showContent)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    // FIXED: Applying a single, deliberate padding at the top of the content.
                    .padding(.top, 60) // This provides space for the close button area.
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            showContent = true
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Animated Background (No Changes)
private struct AnimatedAuroraBackground: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Color(hex: "0D0E0F").ignoresSafeArea()
            Circle().fill(Color.blue.opacity(0.3)).frame(width: 300).blur(radius: 120).offset(x: animate ? 100 : -100, y: -150)
            Circle().fill(Color.green.opacity(0.3)).frame(width: 350).blur(radius: 140).offset(x: animate ? -100 : 100, y: -50)
            Circle().fill(Color.red.opacity(0.3)).frame(width: 250).blur(radius: 100).offset(x: animate ? 50 : 0, y: 200)
        }
        .onAppear { withAnimation(.easeInOut(duration: 10).repeatForever()) { animate.toggle() } }
    }
}

// MARK: - UI Components

private struct SubscriptionHeaderView: View {
    @State private var isGlowing = false

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Image(systemName: "sparkles").font(.system(size: 50)).foregroundStyle(Color.green.opacity(0.5)).blur(radius: isGlowing ? 15 : 5)
                Image(systemName: "sparkles").font(.system(size: 50)).foregroundStyle(LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .onAppear { withAnimation(.easeInOut(duration: 2).repeatForever()) { isGlowing.toggle() } }
            
            Text("Unlock Smart-Rupay Pro")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            
            Text("Get unlimited access to all premium features.")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        // FIXED: Removed the internal `.padding(.top, 40)` which was creating the large unwanted gap.
        // Spacing is now handled by the parent ScrollView for better control.
    }
}

private struct PlanCardView: View {
    let plan: MembershipPlan
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name).font(.title2).bold()
                    Text("₹\(Int(plan.price))").font(.title.weight(.medium)) + Text(" / year").font(.headline.weight(.regular)).foregroundColor(.gray)
                }
                Spacer()
                if let savings = plan.savings {
                    Text(savings)
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                }
            }
            
            Divider().background(.gray.opacity(0.4))
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(plan.features) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: feature.iconName)
                            .foregroundStyle(LinearGradient(colors: [.green, .blue], startPoint: .top, endPoint: .bottom))
                            .frame(width: 20)
                        Text(feature.text)
                    }
                }
            }
            .font(.subheadline)
        }
        .foregroundColor(.white)
        .padding()
        .background(.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(colors: [.green.opacity(0.8), .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 2
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }
}

// NOTE: The other files (`CheckoutView`, `SubscriptionViewModel`, etc.) do not need to be changed.

struct PremiumSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSubscriptionView()
    }
}
