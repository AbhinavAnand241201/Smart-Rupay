import SwiftUI

struct PremiumSubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var contentOpacity: Double = 0

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1C1D21").ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        HeaderView()
                            .padding(.bottom, 30)

                        FeaturesListView(features: viewModel.premiumFeatures)
                            .padding(.bottom, 40)
                        
                        VStack(spacing: 15) {
                            Text("Choose your plan")
                                .font(.title3).bold()
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(viewModel.plans) { plan in
                                NavigationLink(destination: CheckoutView(plan: plan).environmentObject(viewModel)) {
                                    PlanSelectionRow(plan: plan)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                        
                        Text("You will be able to confirm your purchase on the next screen.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()

                    }
                    .padding()
                }
                .foregroundColor(.white)
                .opacity(contentOpacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.5)) {
                        contentOpacity = 1.0
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}

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

    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading) {
                Text(plan.name)
                    .font(.headline)
                Text("₹\(Int(plan.price)) /\(plan.pricePeriod.split(separator: " ").last ?? "")")
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
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}

struct PremiumSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSubscriptionView()
    }
}
