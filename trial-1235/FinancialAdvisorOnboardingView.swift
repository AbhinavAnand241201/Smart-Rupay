import SwiftUI

struct FinancialAdvisorOnboardingView: View {
    @State private var monthlyIncome: String = ""
    @State private var monthlyExpenses: String = ""
    @State private var financialGoals: String = ""
    
    @State private var isLoading: Bool = false
    @State private var showPlanSheet: Bool = false
    @State private var financialPlan: FinancialPlan?
    @State private var showAlert = false
    @State private var alertMessage = ""

    let backgroundColor = Color(red: 0.07, green: 0.08, blue: 0.09)
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
                    
                    Text("Get an educational plan based on established financial frameworks.")
                        .font(.system(size: 16))
                        .foregroundColor(subtitleTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)

                    CustomStyledTextField(placeholder: "Your Monthly Income (₹)", text: $monthlyIncome, keyboardType: .decimalPad)
                    CustomStyledTextField(placeholder: "Your Monthly Expenses (₹)", text: $monthlyExpenses, keyboardType: .decimalPad)
                    CustomStyledTextField(placeholder: "Your Main Financial Goal (e.g., Buy a car)", text: $financialGoals)
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
                .padding(.bottom, 20)
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
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    @MainActor
    private func generateFinancialPlan() {
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
