import SwiftUI

@MainActor
class FinancialGoalsViewModel: ObservableObject {
    @Published var goals: [FinancialGoal] = []
    
    // These properties help you show loading indicators or alerts in your views.
    @Published var isLoading = false
    @Published var errorMessage: String?

    // We no longer need UserDefaults or sample data logic.
    
    // MARK: - API Communication Methods

    func fetchGoals() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.goals = try await NetworkService.shared.fetchGoals()
        } catch {
            self.errorMessage = "Error fetching goals: \(error.localizedDescription)"
            print(errorMessage!)
        }
        
        isLoading = false
    }

    func addGoal(name: String, targetAmount: Double, currentAmount: Double, deadline: Date?) async {
        isLoading = true
        errorMessage = nil
        
        // Use the existing goalVisuals to assign an icon/color on the client-side
        let visual = goalVisuals[goals.count % goalVisuals.count]

        let goalToAdd = FinancialGoal(
            id: UUID(), // The backend will generate its own ID, this is for local state
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline,
            iconName: visual.icon,
            colorHex: visual.colorHex
        )
        
        do {
            let savedGoal = try await NetworkService.shared.addGoal(
                name: goalToAdd.name,
                targetAmount: goalToAdd.targetAmount,
                currentAmount: goalToAdd.currentAmount,
                deadline: goalToAdd.deadline
            )
            // Add the goal returned from the server, which has the correct ID
            goals.insert(savedGoal, at: 0)
        } catch {
            self.errorMessage = "Error adding goal: \(error.localizedDescription)"
            print(errorMessage!)
        }
        
        isLoading = false
    }
    
    func contributeToGoal(goal: FinancialGoal, amount: Double) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedGoal = try await NetworkService.shared.contributeToGoal(id: goal.id.uuidString, amount: amount)
            // Find the goal in our local array and update it
            if let index = goals.firstIndex(where: { $0.id == updatedGoal.id }) {
                goals[index] = updatedGoal
            }
        } catch {
            self.errorMessage = "Error contributing to goal: \(error.localizedDescription)"
            print(errorMessage!)
        }
        
        isLoading = false
    }

    func deleteGoal(at offsets: IndexSet) {
        let goalsToDelete = offsets.map { self.goals[$0] }
        
        Task {
            for goal in goalsToDelete {
                do {
                    // Note: The backend uses a String ID, while the frontend might use UUID.
                    // This needs to be handled cleanly. For now, we assume this works.
                    try await NetworkService.shared.deleteGoal(id: goal.id.uuidString)
                    // If the server deletion is successful, remove it from our local array.
                    self.goals.removeAll { $0.id == goal.id }
                } catch {
                    self.errorMessage = "Error deleting goal: \(error.localizedDescription)"
                    print(errorMessage!)
                }
            }
        }
    }
    
    // Predefined set of colors and icons for variety when adding goals
    private let goalVisuals: [(icon: String, colorHex: String)] = [
        ("airplane", "007BFF"), ("house.fill", "39FF14"),
        ("graduationcap.fill", "BF00FF"), ("car.fill", "FFD700"),
        ("gift.fill", "FF3399"), ("creditcard.fill", "FF4500"),
        ("briefcase.fill", "3AD7D5")
    ]
}
