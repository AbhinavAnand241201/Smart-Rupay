//
//  FinancialAdvisorOnboardingView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 02/06/25.
//


import SwiftUI

// (Re-using the Color extension for hex values if not already in your project)
// extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0) // Default to black if hex is invalid
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}

struct FinancialAdvisorOnboardingView: View {
    @State private var monthlyIncome: String = ""
    @State private var monthlyExpenses: String = ""
    @State private var financialGoals: String = ""

    // MARK: - UI Colors & Styles
    let backgroundColor = Color(red: 0.07, green: 0.08, blue: 0.09) // Slightly deeper dark
    let inputFieldBackgroundColor = Color(red: 0.12, green: 0.13, blue: 0.15)
    let placeholderTextColor = Color(hex: "8A8A8E") // Softer gray for placeholder
    let buttonAndTitleAccentColor = Color(hex: "38D9A9") // A vibrant, modern teal
    let subtitleTextColor = Color(hex: "AEAEB2")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Spacer(minLength: 40) // Space from top

                    // MARK: - Header
                    Text("AI Financial Advisor")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(buttonAndTitleAccentColor) // Using accent for title
                        .padding(.bottom, 5)

                    Text("To give you the best advice, we need to understand your financial situation and goals.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(subtitleTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)

                    // MARK: - Input Fields
                    CustomStyledTextField(placeholder: "What's your monthly income?", text: $monthlyIncome, keyboardType: .decimalPad)
                    CustomStyledTextField(placeholder: "What are your monthly expenses?", text: $monthlyExpenses, keyboardType: .decimalPad)

                    // For financial goals, TextEditor might be better for longer input
                    // but using TextField to match the visual style of other fields.
                    CustomStyledTextField(placeholder: "What are your financial goals?", text: $financialGoals)
                        .lineLimit(3) // Allow a bit more vertical space if needed for TextField

                    Spacer() // Pushes the button towards the bottom if content is short

                }
                .padding(.horizontal, 20)
            }
            
            VStack {
                Spacer()
                // MARK: - Next Button
                Button(action: {
                    // Action: Collect data and proceed
                    print("Monthly Income: \(monthlyIncome)")
                    print("Monthly Expenses: \(monthlyExpenses)")
                    print("Financial Goals: \(financialGoals)")
                    // Navigate to next screen or call API
                }) {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.black) // Dark text on bright button for contrast
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(buttonAndTitleAccentColor)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, (UIApplication.shared.connectedScenes
                                       .compactMap { $0 as? UIWindowScene }
                                       .first?.windows.first?.safeAreaInsets.bottom ?? 0) + 15) // Safe area + extra padding
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)


        }
        .preferredColorScheme(.dark)
        .onTapGesture {
            // Dismiss keyboard when tapping outside TextFields
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Custom TextField Style Component
struct CustomStyledTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    private let inputFieldBackgroundColor = Color(red: 0.12, green: 0.13, blue: 0.15)
    private let placeholderTextColor = Color(hex: "8A8A8E")
    private let inputTextColor = Color.white

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(placeholderTextColor))
            .font(.system(size: 16, design: .rounded))
            .keyboardType(keyboardType)
            .foregroundColor(inputTextColor)
            .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
            .background(inputFieldBackgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5) // Subtle border
            )
    }
}

// MARK: - Preview
struct FinancialAdvisorOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialAdvisorOnboardingView()
    }
}