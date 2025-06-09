//
//  PremiumSubscriptionView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 09/06/25.
//


import SwiftUI

struct PremiumSubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background gradient for a premium feel
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "1C1C1E"), Color(hex: "0D0E0F")]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 20) {
                // Header Section
                VStack {
                    Image(systemName: "star.shield.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: "FFD700"))
                    Text("Unlock Smart-Rupay Pro")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    Text("Get unlimited access to all premium features and take full control of your finances.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Plan Selection
                VStack(spacing: 15) {
                    ForEach(viewModel.plans) { plan in
                        PlanCardView(
                            plan: plan,
                            isSelected: viewModel.selectedPlanId == plan.id
                        )
                        .onTapGesture {
                            viewModel.selectPlan(planId: plan.id)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Button
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
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text("Upgrade to Pro")
                                .font(.headline).bold()
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color(hex: "3AD7D5"))
                    .cornerRadius(12)
                    .disabled(viewModel.isLoading)
                    
                    Text("Recurring billing. Cancel anytime.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

// Subview for displaying a single subscription plan
struct PlanCardView: View {
    let plan: MembershipPlan
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.name)
                        .font(.title2).bold()
                    Text("₹\(Int(plan.price)) / \(plan.pricePeriod.split(separator: " ").last ?? "")")
                        .font(.headline)
                }
                Spacer()
                if plan.highlight {
                    Text("POPULAR")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "3AD7D5"))
                        .cornerRadius(6)
                }
            }
            
            Divider().background(isSelected ? Color.white.opacity(0.5) : .gray.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.features, id: \.self) { feature in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "3AD7D5"))
                        Text(feature)
                    }
                }
            }
            .font(.subheadline)
        }
        .foregroundColor(.white)
        .padding()
        .background(Color(red: 0.15, green: 0.16, blue: 0.18))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(hex: "3AD7D5") : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}


struct PremiumSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSubscriptionView()
    }
}
