
//  FinancialAdvisorOnboardingView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 02/06/25.
//
//  MODIFIED by Gemini AI on 07/06/25 to be fully functional.
//

import SwiftUI

struct FinancialAdvisorOnboardingView: View {
    // Original State Variables
    @State private var monthlyIncome: String = ""
    @State private var monthlyExpenses: String = ""
    @State private var financialGoals: String = ""
    
    // --- START: ADDED STATE VARIABLES ---
    @State private var isLoading: Bool = false
    @State private var showResponseSheet: Bool = false
    @State private var oracleResponse: OracleResponse?
    // --- END: ADDED STATE VARIABLES ---

    // MARK: - UI Colors & Styles
    let backgroundColor = Color(red: 0.07, green: 0.08, blue: 0.09)
    let inputFieldBackgroundColor = Color(red: 0.12, green: 0.13, blue: 0.15)
    let placeholderTextColor = Color(hex: "8A8A8E")
    let buttonAndTitleAccentColor = Color(hex: "38D9A9")
    let subtitleTextColor = Color(hex: "AEAEB2")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Spacer(minLength: 40)

                    // MARK: - Header
                    Text("AI Financial Advisor")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(buttonAndTitleAccentColor)
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

                    CustomStyledTextField(placeholder: "What are your financial goals? (e.g., buy a car, save for vacation)", text: $financialGoals)
                        .lineLimit(3)

                    Spacer()

                }
                .padding(.horizontal, 20)
            }
            
            VStack {
                Spacer()
                // --- START: MODIFIED NEXT BUTTON ---
                Button(action: {
                    getFinancialAdvice()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Text("Get My Plan")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(buttonAndTitleAccentColor)
                .cornerRadius(14)
                .disabled(isLoading) // Disable button while loading
                // --- END: MODIFIED NEXT BUTTON ---
                .padding(.horizontal, 25)
                .padding(.bottom, (UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?.windows.first?.safeAreaInsets.bottom ?? 0) + 15)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        // --- START: ADDED SHEET MODIFIER ---
        .sheet(isPresented: $showResponseSheet) {
            if let response = oracleResponse {
                OracleResponseView(response: response) {
                    showResponseSheet = false
                }
            }
        }
        // --- END: ADDED SHEET MODIFIER ---
        .preferredColorScheme(.dark)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    // --- START: ADDED METHOD ---
    private func getFinancialAdvice() {
        // In a real app, this is where you would make a network call to your backend.
        // NEVER call a Google AI API directly from the client-side app with your API key.
        
        isLoading = true
        
        // This simulates a network delay of 2 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // This is placeholder data. It is NOT real financial advice.
            self.oracleResponse = OracleResponse(
                summary: "Based on your income and goals, your primary focus should be building an emergency fund while aggressively paying down high-interest debt. Once that's stable, you can start investing for your long-term goals.",
                actionSteps: [
                    .init(iconName: "shield.lefthalf.filled", title: "Build Emergency Fund", description: "Aim to save 3-6 months of essential expenses in a high-yield savings account.", iconColor: .blue),
                    .init(iconName: "creditcard.and.123", title: "Tackle High-Interest Debt", description: "Prioritize paying off any debt with an interest rate above 7% to save money.", iconColor: .orange),
                    .init(iconName: "chart.pie.fill", title: "Automate Your Savings", description: "Set up automatic monthly transfers to your savings and investment accounts.", iconColor: .green)
                ],
                investmentIdeas: [
                    .init(type: "For Beginners (Lower Risk)", description: "Focus on diversified, low-cost funds to start building your portfolio.", ideas: ["Broad Market Index Funds (e.g., S&P 500)", "Target-Date Funds for retirement"]),
                    .init(type: "For Growth (Higher Risk)", description: "As your comfort grows, consider adding exposure to specific sectors you believe in.", ideas: ["Technology Sector ETFs", "Healthcare Innovation Funds"])
                ]
            )
            
            self.isLoading = false
            self.showResponseSheet = true
        }
    }
    // --- END: ADDED METHOD ---
}

// CustomStyledTextField (No changes needed, assumed to be available)
struct CustomStyledTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var backgroundColor: Color = Color(red: 0.12, green: 0.13, blue: 0.15)
    var placeholderColor: Color = Color(hex: "8A8A8E")
    var textColor: Color = Color.white

    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(placeholderColor))
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(placeholderColor))
            }
        }
        .font(.system(size: 16, design: .rounded))
        .keyboardType(keyboardType)
        .foregroundColor(textColor)
        .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview
struct FinancialAdvisorOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialAdvisorOnboardingView()
    }
}
