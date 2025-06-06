//
//
//  UrgentPaymentAlarmView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 06/06/25.
//


// File: Views/UrgentPaymentAlarmView.swift
// REDESIGNED: A modern, minimalist, and sleek UI.

import SwiftUI

struct UrgentPaymentAlarmView: View {
    let bill: BillItem
    var onDismiss: () -> Void
    
    // MARK: - App Theme Colors
    let screenBackgroundColor = Color(hex: "#0D0E0F") // A deep, near-black for focus
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")
    let warningColorOrange = Color(hex: "#F39C12")

    // MARK: - Animation State
    @State private var hasAppeared = false
    
    var body: some View {
        ZStack {
            // MARK: - Background Gradient
            // A subtle gradient from the top creates a "spotlight" or "alert" effect.
            screenBackgroundColor.ignoresSafeArea()
            LinearGradient(
                gradient: Gradient(colors: [warningColorOrange.opacity(0.4), .clear]),
                startPoint: .top,
                endPoint: .center
            ).ignoresSafeArea()

            // MARK: - Main Content
            VStack(spacing: 0) {
                Spacer()

                // Animated Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(warningColorOrange)
                    .shadow(color: warningColorOrange.opacity(0.8), radius: 20, x: 0, y: 5)
                    .scaleEffect(hasAppeared ? 1.0 : 0.8)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.2), value: hasAppeared)

                // Title Text
                Text("URGENT PAYMENT")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(mainTextColor)
                    .kerning(2.0) // Letter spacing for a modern feel
                    .padding(.top, 30)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(0.4), value: hasAppeared)
                
                // Bill Name
                Text(bill.name)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(mainTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(0.5), value: hasAppeared)
                
                // Bill Amount
                Text("₹\(bill.amount, specifier: "%.2f")")
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .foregroundColor(secondaryTextColor)
                    .padding(.top, 4)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(0.6), value: hasAppeared)
                
                Spacer()
                Spacer()

                // Action Buttons
                VStack(spacing: 15) {
                    // PAY NOW BUTTON (Primary)
                    if let urlString = bill.paymentURL, let url = URL(string: urlString) {
                        Link(destination: url) {
                            Text("Pay Now")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(accentColorTeal)
                                .cornerRadius(16)
                        }
                    }

                    // MARK AS PAID BUTTON (Secondary)
                    Button(action: {
                        onDismiss()
                    }) {
                        Text("I've Already Paid")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(secondaryTextColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.clear) // Minimalist secondary button
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                .opacity(hasAppeared ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.5).delay(0.8), value: hasAppeared)
            }
            .padding(.vertical)
        }
        .onAppear {
            hasAppeared = true
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleUrgentBill = BillItem(
        id: UUID(),
        name: "Apartment Rent",
        amount: 85000.00,
        dueDate: Date().addingTimeInterval(4 * 60 * 60), // Due in 4 hours
        category: .rent,
        paymentURL: "https://www.google.com"
    )
    
    return UrgentPaymentAlarmView(bill: sampleUrgentBill, onDismiss: {
        print("Dismissed!")
    })
}
