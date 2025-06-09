import SwiftUI

struct PremiumSubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var showContent = false

    var body: some View {
        // ENHANCEMENT: Wrapped in NavigationView to handle navigation to the checkout screen.
        NavigationView {
            ZStack {
                backgroundView

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 25) {
                        SubscriptionHeaderView()
                        
                        VStack(spacing: 15) {
                            ForEach(viewModel.plans) { plan in
                                // ENHANCEMENT: Each card is now a NavigationLink
                                NavigationLink(destination: CheckoutView(plan: plan).environmentObject(viewModel)) {
                                    PlanCardView(plan: plan)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationBarHidden(true) // We use a custom close button
        }
        .preferredColorScheme(.dark)
    }
    
    var backgroundView: some View {
        ZStack {
            Color(hex: "0D0E0F").ignoresSafeArea()
            RadialGradient(gradient: Gradient(colors: [Color(hex: "3AD7D5").opacity(0.2), .clear]), center: .top, startRadius: 10, endRadius: 400).ignoresSafeArea()
            Circle().fill(Color(hex: "5E5CE6").opacity(0.1)).frame(width: 300).blur(radius: 100).offset(x: -150, y: 100)
        }
    }
}

// MARK: - Subviews

private struct SubscriptionHeaderView: View {
    @State private var isGlowing = false

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Image(systemName: "star.shield.fill").font(.system(size: 50)).foregroundColor(Color(hex: "FFD700").opacity(0.5)).blur(radius: isGlowing ? 15 : 5)
                Image(systemName: "star.shield.fill").font(.system(size: 50)).foregroundStyle(LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "FDB827")], startPoint: .top, endPoint: .bottom))
            }
            .onAppear { withAnimation(.easeInOut(duration: 2).repeatForever()) { isGlowing.toggle() } }
            
            Text("Unlock Smart-Rupay Pro").font(.largeTitle.bold()).foregroundStyle(LinearGradient(colors: [.white, .white.opacity(0.8)], startPoint: .top, endPoint: .bottom))
            Text("Get unlimited access to all premium features.").font(.headline).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal)
        }
        .padding(.top, 40)
    }
}

private struct PlanCardView: View {
    let plan: MembershipPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name).font(.title2).bold()
                    Text("₹\(Int(plan.price))").font(.title.weight(.medium)) + Text(" / \(plan.pricePeriod.split(separator: " ").last ?? "")").font(.headline.weight(.regular)).foregroundColor(.gray)
                }
                Spacer()
                if let savings = plan.savings {
                    Text(savings).font(.caption.bold()).foregroundColor(.black).padding(.horizontal, 10).padding(.vertical, 5).background(Color(hex: "3AD7D5")).clipShape(Capsule())
                }
            }
            
            Divider().background(.gray.opacity(0.4))
            
            VStack(alignment: .leading, spacing: 10) {
                // ENHANCEMENT: Displaying features with icons.
                ForEach(plan.features) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: feature.iconName)
                            .foregroundColor(Color(hex: "3AD7D5"))
                            .frame(width: 20)
                        Text(feature.text)
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
                .stroke(plan.highlight ? Color(hex: "3AD7D5") : Color.gray.opacity(0.3), lineWidth: plan.highlight ? 2.5 : 1)
        )
    }
}

struct PremiumSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSubscriptionView()
    }
}
