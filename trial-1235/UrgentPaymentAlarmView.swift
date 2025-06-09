import SwiftUI

struct UrgentPaymentAlarmView: View {
    let bill: BillItem
    var onDismiss: () -> Void
    
    let screenBackgroundColor = Color(hex: "#0D0E0F")
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")
    let warningColorOrange = Color(hex: "#F39C12")

    @State private var hasAppeared = false
    
    var body: some View {
        ZStack {
            screenBackgroundColor.ignoresSafeArea()
            LinearGradient(
                gradient: Gradient(colors: [warningColorOrange.opacity(0.4), .clear]),
                startPoint: .top,
                endPoint: .center
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(warningColorOrange)
                    .shadow(color: warningColorOrange.opacity(0.8), radius: 20, x: 0, y: 5)
                    .scaleEffect(hasAppeared ? 1.0 : 0.8)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.2), value: hasAppeared)

                Text("URGENT PAYMENT")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(mainTextColor)
                    .kerning(2.0)
                    .padding(.top, 30)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(0.4), value: hasAppeared)

                Text(bill.name)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(mainTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(0.5), value: hasAppeared)

                Text("₹\(bill.amount, specifier: "%.2f")")
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .foregroundColor(secondaryTextColor)
                    .padding(.top, 4)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(0.6), value: hasAppeared)
                
                Spacer()
                Spacer()

                VStack(spacing: 15) {

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

                    Button(action: {
                        onDismiss()
                    }) {
                        Text("I've Already Paid")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(secondaryTextColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.clear)
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

struct UrgentPaymentAlarmView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUrgentBill = BillItem(
            id: UUID(),
            name: "Apartment Rent",
            amount: 85000.00,
            dueDate: Date().addingTimeInterval(4 * 60 * 60),
            category: .rent,
            paymentURL: "https://www.google.com"
        )
        
        return UrgentPaymentAlarmView(bill: sampleUrgentBill, onDismiss: {
            print("Dismissed!")
        })
    }
}
