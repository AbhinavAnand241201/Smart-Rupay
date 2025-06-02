//
//  FinancialGoal.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 03/06/25.
//


// FinancialGoal.swift

import SwiftUI

struct FinancialGoal: Identifiable, Codable, Hashable { // Added Hashable for ForEach if needed
    let id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date?
    var iconName: String       // SF Symbol name for the goal
    var colorHex: String       // Store color as hex string for Codability

    // Computed properties
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0) // Cap progress at 100%
    }

    var remainingAmount: Double {
        max(0, targetAmount - currentAmount)
    }

    var isCompleted: Bool {
        currentAmount >= targetAmount && targetAmount > 0
    }
    
    var accentColor: Color {
        Color(hex: colorHex)
    }

    // Default initializer
    init(id: UUID = UUID(), name: String, targetAmount: Double, currentAmount: Double = 0.0, deadline: Date? = nil, iconName: String, colorHex: String) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.deadline = deadline
        self.iconName = iconName
        self.colorHex = colorHex
    }
}