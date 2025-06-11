import SwiftUI

@MainActor
class FinancialGoalsViewModel: ObservableObject {
    @Published var goals: [FinancialGoal] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {}
    
    // In FinancialGoalsViewModel.swift, replace the fetchGoals function

    func fetchGoals() async {
        // For the demo, we will load rich mock data instead of calling the network.
        // In your final app, you would remove this and use your NetworkService.
        
        // Using our app's predefined accent colors for variety
        let accentColors = [
            Color.App.accentGreen.toHex() ?? "30D158",
            Color.App.accentBlue.toHex() ?? "0A84FF",
            Color.App.accentPurple.toHex() ?? "AF52DE",
            Color.App.accentOrange.toHex() ?? "FF9F0A",
            Color.App.accentPink.toHex() ?? "FF2D55"
        ]
        
        // A diverse set of goals to showcase the UI
        self.goals = [
            FinancialGoal(name: "Buy New MacBook Pro", targetAmount: 250000, currentAmount: 185000, deadline: Calendar.current.date(byAdding: .month, value: 3, to: Date()), iconName: "laptopcomputer", colorHex: accentColors[1]),
            FinancialGoal(name: "Vacation to Europe", targetAmount: 400000, currentAmount: 150000, deadline: Calendar.current.date(byAdding: .year, value: 1, to: Date()), iconName: "airplane", colorHex: accentColors[2]),
            FinancialGoal(name: "Emergency Fund", targetAmount: 100000, currentAmount: 100000, deadline: nil, iconName: "shield.lefthalf.filled", colorHex: accentColors[0]), // Completed
            FinancialGoal(name: "Down Payment for Car", targetAmount: 300000, currentAmount: 80000, deadline: nil, iconName: "car.fill", colorHex: accentColors[3])
        ]
        
        self.isLoading = false
        self.errorMessage = nil
    }

    func addGoal(name: String, targetAmount: Double, currentAmount: Double, deadline: Date?) async {
        isLoading = true
        errorMessage = nil
        
        let body = GoalRequestBody(name: name, targetAmount: targetAmount, currentAmount: currentAmount, deadline: deadline)
        
        do {
            let savedGoal = try await NetworkService.shared.addGoal(body: body)
            // Add the goal returned from the server, which has the correct server-side ID
            goals.insert(savedGoal, at: 0)
        } catch {
            self.errorMessage = "Error adding goal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func contributeToGoal(goal: FinancialGoal, amount: Double) async {
        let goalIdAsString = goal.id.uuidString
        let body = ContributionRequestBody(amount: amount)
        
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedGoal = try await NetworkService.shared.contributeToGoal(id: goalIdAsString, body: body)
            // Find the goal in our local array and update it with the new data from the server.
            if let index = goals.firstIndex(where: { $0.id == updatedGoal.id }) {
                goals[index] = updatedGoal
            }
        } catch {
            self.errorMessage = "Error contributing to goal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }

    /// Sends a delete request to the server for each selected goal.
    func deleteGoal(at offsets: IndexSet) {
        let goalsToDelete = offsets.map { self.goals[$0] }
        
        Task {
            isLoading = true
            for goal in goalsToDelete {
                do {
                    try await NetworkService.shared.deleteGoal(id: goal.id.uuidString)
                    // If the server deletion is successful, remove it from our local array on the main thread.
                    await MainActor.run {
                        self.goals.removeAll { $0.id == goal.id }
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = "Error deleting goal: \(error.localizedDescription)"
                    }
                }
            }
            isLoading = false
        }
    }
}
