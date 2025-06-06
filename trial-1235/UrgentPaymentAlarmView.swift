// File: Views/UrgentPaymentAlarmView.swift

import SwiftUI

struct UrgentPaymentAlarmView: View {
    
    let bill: BillItem
    var onDismiss: () -> Void
    
    // MARK: - GenZ Colors
    let brightPink = Color(hex: "#FF007F")
    let brightYellow = Color(hex: "#FFFF33")
    let brightCyan = Color(hex: "#00FFFF")
    
    @State private var isPulsating = false
    
    var body: some View {
        ZStack {
            // Pulsating Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [brightPink, brightYellow, brightCyan, brightPink]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(isPulsating ? 0.9 : 0.7)
            .ignoresSafeArea()
            
            // Glassmorphism card effect
            VStack(spacing: 25) {
                HStack {
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 40))
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                }
                .foregroundColor(brightYellow)
                
                Text("URGENT PAYMENT DUE")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                VStack {
                    Text(bill.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Amount: ₹\(bill.amount, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    // Countdown
                    Text("Due in: \(bill.dueDate, style: .relative)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top, 5)
                }
                .foregroundColor(Color(hex: "#1A1A1A")) // Dark text for readability
                
                // --- Action Buttons ---
                
                // MARK AS PAID BUTTON
                Button(action: {
                    // Add logic to mark the bill as paid here
                    onDismiss()
                }) {
                    Text("I'VE PAID THIS BILL")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(16)
                }
                
                // PAY NOW BUTTON (only shows if a URL exists)
                if let urlString = bill.paymentURL, let url = URL(string: urlString) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "link")
                            Text("PAY NOW")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(brightYellow)
                        .cornerRadius(16)
                    }
                }
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(brightPink, lineWidth: 4)
            )
            .padding(20)
            .shadow(color: brightPink.opacity(0.5), radius: 20, x: 0, y: 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsating = true
            }
        }
    }
}

// Add a Preview to see your design
#Preview {
    // This is a sample bill for previewing the alarm
    let sampleUrgentBill = BillItem(
        id: UUID(),
        name: "Credit Card Bill",
        amount: 15000.00,
        dueDate: Date().addingTimeInterval(12 * 60 * 60), // Due in 12 hours
        category: .creditCard,
        paymentURL: "https://www.google.com"
    )
    
    return UrgentPaymentAlarmView(bill: sampleUrgentBill, onDismiss: {
        print("Dismissed!")
    })
}