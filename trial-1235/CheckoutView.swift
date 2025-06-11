// In file: CheckoutView.swift

import SwiftUI

struct CheckoutView: View {
    // MARK: - Properties
    let plan: MembershipPlan
    @EnvironmentObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var showSuccessAlert = false

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.App.background.ignoresSafeArea()
            
            // The view is broken into computed properties to help the compiler
            mainContent
            
            actionButtons
        }
        .navigationTitle("Complete Purchase")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Payment Successful!", isPresented: $showSuccessAlert) {
            Button("Great!", role: .cancel) { dismiss() }
        } message: {
            Text("Your subscription is now active. Welcome to Pro!")
        }
    }

    // MARK: - Main Content View
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Order Summary Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order Summary")
                        .font(.title2).bold()
                        .foregroundColor(Color.App.textPrimary)
                    
                    Text("You have selected the **\(plan.name)**. You will be billed **₹\(Int(plan.price))** \(plan.pricePeriod).")
                        .font(.subheadline)
                        .foregroundColor(Color.App.textSecondary)
                        .lineSpacing(4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.App.card)
                .cornerRadius(20)
                
                // Payment Method Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Choose Payment Method")
                        .font(.title2).bold()
                        .foregroundColor(Color.App.textPrimary)
                    
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        PaymentMethodButton(method: method, isSelected: selectedPaymentMethod == method)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedPaymentMethod = method
                                }
                            }
                    }
                }
                
                // Spacer at the bottom to ensure content can scroll above the floating button
                Color.clear.frame(height: 120)
            }
            .padding()
            .padding(.top, 20)
        }
    }
    
    // MARK: - Action Buttons View
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(Color.App.accentPink)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                Task {
                    let success = await viewModel.processSubscription(planId: plan.id)
                    if success {
                        showSuccessAlert = true
                    }
                }
            }) {
                if viewModel.isLoading {
                    ProgressView().tint(.black)
                } else {
                    Text("Confirm & Pay ₹\(Int(plan.price))")
                        .font(.headline.bold())
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color.App.accent)
            .cornerRadius(16)
            .shadow(color: Color.App.accent.opacity(0.4), radius: 8, y: 4)
            .disabled(selectedPaymentMethod == nil || viewModel.isLoading)
            .opacity(selectedPaymentMethod == nil ? 0.6 : 1.0)
        }
        .padding(.horizontal, 30)
        .padding(.top)
        .padding(.bottom, 20)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Subviews
struct PaymentMethodButton: View {
    let method: PaymentMethod
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Using placeholder logos adds a professional touch
            // Make sure you have "razorpay_logo" and "stripe_logo" in your Assets.xcassets
            Image(method.logoName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(10)
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
            
            Text(method.title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(Color.App.textPrimary)
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isSelected ? Color.App.accent : Color.App.textSecondary.opacity(0.5))
        }
        .padding()
        .background(Color.App.card)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.App.accent : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Preview
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        // Create sample data needed for the preview
        let samplePlan = MembershipPlan(
            id: "annual_pro",
            name: "Annual Pro",
            price: 3999,
            pricePeriod: "per year",
            features: [],
            highlight: true,
            savings: "Save 20%"
        )
        
        NavigationView {
            CheckoutView(plan: samplePlan)
                .environmentObject(SubscriptionViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
