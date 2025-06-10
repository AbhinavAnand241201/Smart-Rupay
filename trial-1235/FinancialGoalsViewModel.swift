import SwiftUI

@MainActor
class FinancialGoalsViewModel: ObservableObject {
    @Published var goals: [FinancialGoal] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {}
    

    func fetchGoals() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.goals = try await NetworkService.shared.fetchGoals()
        } catch {
            self.errorMessage = "Error fetching goals: \(error.localizedDescription)"
        }
        
        isLoading = false
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
