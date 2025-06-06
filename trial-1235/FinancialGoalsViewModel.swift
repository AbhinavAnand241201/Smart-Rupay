//
//  FinancialGoalsViewModel.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 03/06/25.
//


// FinancialGoalsViewModel.swift

import SwiftUI
import Combine

class FinancialGoalsViewModel: ObservableObject {
    @Published var goals: [FinancialGoal] = []

    // Predefined set of colors and icons for variety when adding goals
    let goalVisuals: [(icon: String, colorHex: String)] = [
        ("airplane", "007BFF"),      // Electric Blue
        ("house.fill", "39FF14"),    // Neon Green
        ("graduationcap.fill", "BF00FF"), // Bright Purple
        ("car.fill", "FFD700"),      // Vivid Yellow
        ("gift.fill", "FF3399"),     // Radiant Pink
        ("creditcard.fill", "FF4500"),// Sunny Red
        ("briefcase.fill", "3AD7D5") // Teal (App's main accent)
    ]
    private var nextVisualIndex = 0
    // MARK: - Data Persistence
        private let goalsSaveKey = "UserFinancialGoals"

        private func saveGoals() {
            do {
                let data = try JSONEncoder().encode(goals)
                UserDefaults.standard.set(data, forKey: goalsSaveKey)
            } catch {
                print("Failed to save goals: \(error.localizedDescription)")
            }
        }

        private func loadGoals() {
            guard let data = UserDefaults.standard.data(forKey: goalsSaveKey) else {
                self.goals = []
                return
            }
            
            do {
                self.goals = try JSONDecoder().decode([FinancialGoal].self, from: data)
            } catch {
                print("Failed to load goals: \(error.localizedDescription)")
                self.goals = []
            }
        }
//    init() {
//        // Load saved goals or add sample data
//        loadSampleGoals()
//    }
    // What to change
        init() {
            loadGoals()
        }

    func addGoal(name: String, targetAmount: Double, currentAmount: Double, deadline: Date?) {
        let visual = goalVisuals[nextVisualIndex % goalVisuals.count]
        nextVisualIndex += 1
        
        let newGoal = FinancialGoal(
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline,
            iconName: visual.icon,
            colorHex: visual.colorHex
        )
        goals.append(newGoal)
        // Sort goals, e.g., by deadline or completion status
        sortGoals()
        saveGoals()
    }

    func updateGoalContribution(goalId: UUID, additionalAmount: Double) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].currentAmount += additionalAmount
            goals[index].currentAmount = min(goals[index].currentAmount, goals[index].targetAmount) // Cap at target
            // Persist changes if necessary
            saveGoals()
        }
        
    }
    
    func deleteGoal(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
        saveGoals()
        // Persist changes
    }
    
    private func sortGoals() {
        // Example: Incomplete goals first, then by deadline
        goals.sort {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted && $1.isCompleted
            }
            if let deadline0 = $0.deadline, let deadline1 = $1.deadline {
                return deadline0 < deadline1
            }
            return $0.deadline != nil // Goals with deadlines first
        }
    }

    private func loadSampleGoals() {
        // Use a few distinct visuals for sample goals
        let sampleData = [
            FinancialGoal(name: "Vacation to Hawaii", targetAmount: 5000, currentAmount: 1200, deadline: Calendar.current.date(byAdding: .month, value: 12, to: Date()), iconName: goalVisuals[0].icon, colorHex: goalVisuals[0].colorHex),
            FinancialGoal(name: "New Laptop", targetAmount: 1500, currentAmount: 1450, deadline: Calendar.current.date(byAdding: .month, value: 3, to: Date()), iconName: goalVisuals[1].icon, colorHex: goalVisuals[1].colorHex),
            FinancialGoal(name: "Emergency Fund", targetAmount: 10000, currentAmount: 7500, iconName: goalVisuals[2].icon, colorHex: goalVisuals[2].colorHex),
            FinancialGoal(name: "Pay Off Credit Card", targetAmount: 2000, currentAmount: 2000, deadline: Calendar.current.date(byAdding: .month, value: 1, to: Date()), iconName: goalVisuals[3].icon, colorHex: goalVisuals[3].colorHex)
        ]
        self.goals = sampleData
        self.nextVisualIndex = sampleData.count % goalVisuals.count
        sortGoals()
    }
    
    // TODO: Implement persistence (e.g., UserDefaults, Core Data, SwiftData)
    // func saveGoals() { ... }
    // func loadGoals() { ... }
}
