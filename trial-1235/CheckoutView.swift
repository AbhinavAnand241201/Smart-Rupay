import SwiftUI

struct CheckoutView: View {
    let plan: MembershipPlan
    // This expects the ViewModel to be in the environment.
    @EnvironmentObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var showSuccessAlert = false

    var body: some View {
        ZStack {
            Color(hex: "0D0E0F").ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Order Summary").font(.title2).bold()
                            Text("You have selected the \(plan.name) plan. You will be billed ₹\(Int(plan.price)) \(plan.pricePeriod).")
                                .foregroundColor(.gray)
                        }
                        .padding().background(Material.ultraThinMaterial.opacity(0.4)).cornerRadius(16)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Choose Payment Method").font(.title2).bold()
                            PaymentMethodButton(method: .razorpay, isSelected: selectedPaymentMethod == .razorpay)
                                .onTapGesture { selectedPaymentMethod = .razorpay }
                            PaymentMethodButton(method: .stripe, isSelected: selectedPaymentMethod == .stripe)
                                .onTapGesture { selectedPaymentMethod = .stripe }
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage).foregroundColor(.red).font(.caption)
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
                            ProgressView().progressViewStyle(.circular)
                        } else {
                            Text("Confirm & Pay ₹\(Int(plan.price))")
                                .font(.headline.bold())
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color(hex: "3AD7D5"))
                    .cornerRadius(12)
                    .disabled(selectedPaymentMethod == nil || viewModel.isLoading)
                    .opacity(selectedPaymentMethod == nil ? 0.6 : 1.0)
                }
                .padding()
            }
        }
        .foregroundColor(.white)
        .navigationTitle("Complete Your Purchase")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Payment Successful!", isPresented: $showSuccessAlert) {
            Button("Great!", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Your subscription is now active. Welcome to Pro!")
        }
    }
}

struct PaymentMethodButton: View {
    let method: PaymentMethod
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "creditcard.fill").font(.title)
            Text(method.title).font(.headline)
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isSelected ? Color(hex: "3AD7D5") : .gray)
        }
        .padding()
        .background(Material.ultraThinMaterial.opacity(0.4))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(hex: "3AD7D5") : Color.gray.opacity(0.4), lineWidth: isSelected ? 2.5 : 1)
        )
    }
}
