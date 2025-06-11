// In file: FinancialAdvisorOnboardingView.swift

import SwiftUI

struct FinancialAdvisorOnboardingView: View {
    // MARK: - Properties
    // All original state and logic are preserved
    @State private var monthlyIncome: String = ""
    @State private var monthlyExpenses: String = ""
    @State private var financialGoals: String = ""
    
    @State private var isLoading: Bool = false
    @State private var showPlanSheet: Bool = false
    @State private var financialPlan: FinancialPlan?
    @State private var showAlert = false
    @State private var alertMessage = ""

    // MARK: - Body
    var body: some View {
        ZStack {
            // MARK: - Dynamic Background
            // A subtle radial gradient adds depth and a modern feel
            RadialGradient(
                gradient: Gradient(colors: [Color.App.accentGreen.opacity(0.3), Color.App.background]),
                center: .topLeading,
                startRadius: 5,
                endRadius: 800
            )
            .ignoresSafeArea()
            
            Color.App.background.ignoresSafeArea()

            // Main content stack
            VStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        
                        // MARK: - Header
                        // A more engaging header with a prominent, glowing icon
                        VStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 40))
                                .foregroundColor(Color.App.accentGreen)
                                .padding(20)
                                .background(Color.App.accentGreen.opacity(0.1))
                                .clipShape(Circle())
                                .shadow(color: Color.App.accentGreen.opacity(0.5), radius: 15, x: 0, y: 0) // Glow effect
                            
                            Text("AI Financial Planner")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color.App.textPrimary)
                                .padding(.top, 10)
                            
                            Text("Get a personalized educational plan based on your financial situation.")
                                .font(.headline)
                                .foregroundColor(Color.App.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                        .padding(.vertical, 30)

                        // MARK: - Form Fields
                        // Using a new, enhanced text field style
                        VStack(spacing: 16) {
                            OnboardingTextField(
                                iconName: "indianrupeesign.circle.fill",
                                placeholder: "Your Monthly Income",
                                text: $monthlyIncome,
                                keyboardType: .decimalPad
                            )
                            OnboardingTextField(
                                iconName: "cart.fill",
                                placeholder: "Your Monthly Expenses",
                                text: $monthlyExpenses,
                                keyboardType: .decimalPad
                            )
                            OnboardingTextField(
                                iconName: "target",
                                placeholder: "Your Main Financial Goal",
                                text: $financialGoals
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // MARK: - Action Button
                // A redesigned button with consistent styling
                VStack {
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
                    .padding(.vertical, 18)
                    .background(Color.App.accentGreen) // Using the screen's primary accent
                    .cornerRadius(20)
                    .shadow(color: Color.App.accentGreen.opacity(0.4), radius: 10, y: 5)
                    .disabled(isLoading)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showPlanSheet) {
            if let plan = financialPlan {
                FinancialPlanView(plan: plan) { showPlanSheet = false }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onTapGesture {
            // Dismiss keyboard on tap outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    // MARK: - Functions
    // This logic remains exactly the same
    @MainActor
    private func generateFinancialPlan() {
        // ... your existing generateFinancialPlan logic ...
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
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
                let requestBody = PlanRequestBody(
                    monthlyIncome: income,
                    monthlyExpenses: expenses,
                    financialGoals: financialGoals
                )
                
                let plan = try await NetworkService.shared.generateFinancialPlan(body: requestBody)
                
                self.financialPlan = plan
                self.showPlanSheet = true
                
            } catch let error as NetworkError {
                alertMessage = error.localizedDescription
                showAlert = true
            } catch {
                alertMessage = "An unexpected error occurred: \(error.localizedDescription)"
                showAlert = true
            }
            
            self.isLoading = false
        }
    }
}

// MARK: - Enhanced Onboarding Text Field
// A new, styled component for this screen to make the form feel more modern
struct OnboardingTextField: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(Color.App.textSecondary)
                .frame(width: 25)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .tint(Color.App.accentGreen)
                .foregroundColor(Color.App.textPrimary)
        }
        .padding()
        .background(Color.App.card.opacity(0.7))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.App.textSecondary.opacity(0.3), lineWidth: 1)
        )
    }
}


// MARK: - Preview
struct FinancialAdvisorOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialAdvisorOnboardingView()
    }
}
