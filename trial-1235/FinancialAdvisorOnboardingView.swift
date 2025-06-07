//
//  FinancialAdvisorOnboardingView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 02/06/25.
//
//  MODIFIED by Gemini AI on 07/06/25 for safe, educational plan generation.
//

import SwiftUI

struct FinancialAdvisorOnboardingView: View {
    @State private var monthlyIncome: String = ""
    @State private var monthlyExpenses: String = ""
    @State private var financialGoals: String = ""
    
    // State variables for the feature
    @State private var isLoading: Bool = false
    @State private var showPlanSheet: Bool = false
    @State private var financialPlan: FinancialPlan?
    @State private var showAlert = false
    @State private var alertMessage = ""

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

                    Text("AI Financial Planner")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(buttonAndTitleAccentColor)
                        .padding(.bottom, 5)

                    Text("Get an educational plan based on established financial frameworks.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(subtitleTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)

                    CustomStyledTextField(placeholder: "Your Monthly Income", text: $monthlyIncome, keyboardType: .decimalPad)
                    CustomStyledTextField(placeholder: "Your Monthly Expenses", text: $monthlyExpenses, keyboardType: .decimalPad)
                    CustomStyledTextField(placeholder: "Your Main Financial Goal (e.g., Buy a car)", text: $financialGoals)
                        .lineLimit(3)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            
            VStack {
                Spacer()
                Button(action: generateFinancialPlan) {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Text("Generate My Plan")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(buttonAndTitleAccentColor)
                .cornerRadius(14)
                .disabled(isLoading)
                .padding(.horizontal, 25)
                .padding(.bottom, (UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?.windows.first?.safeAreaInsets.bottom ?? 0) + 15)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .sheet(isPresented: $showPlanSheet) {
            if let plan = financialPlan {
                FinancialPlanView(plan: plan) {
                    showPlanSheet = false
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .preferredColorScheme(.dark)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    @MainActor
    private func generateFinancialPlan() {
        guard let income = Double(monthlyIncome), income > 0 else {
            alertMessage = "Please enter a valid monthly income."
            showAlert = true
            return
        }
        
        guard let expenses = Double(monthlyExpenses), expenses >= 0 else {
            alertMessage = "Please enter a valid number for monthly expenses."
            showAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // Call the network service to generate the financial plan
                let plan = try await NetworkService.shared.generateFinancialPlan(
                    monthlyIncome: income,
                    monthlyExpenses: expenses,
                    financialGoals: financialGoals
                )
                
                // Update the UI on the main thread
                self.financialPlan = plan
                self.showPlanSheet = true
                self.isLoading = false
                
            } catch let error as NetworkError {
                // Handle network errors
                alertMessage = error.localizedDescription
                showAlert = true
                isLoading = false
                
            } catch {
                // Handle any other errors
                alertMessage = "An unexpected error occurred. Please try again."
                showAlert = true
                isLoading = false
            }
        }
    }
}

// CustomStyledTextField (No changes needed)
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
