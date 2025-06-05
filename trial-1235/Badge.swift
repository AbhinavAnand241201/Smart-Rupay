// Badge.swift
// Smart-Rupay App

import SwiftUI

struct Badge: Identifiable, Hashable {
    let id: String // Unique key for the badge, e.g., "budgetPro"
    var name: String
    var description: String
    var iconName: String // SF Symbol for the unachieved state (optional)
    var achievedIconName: String // SF Symbol for the achieved state
    var accentColor: Color // Color associated with the badge
    var isAchieved: Bool = false
    var achievedDate: Date? = nil

    // Conformance for Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Badge, rhs: Badge) -> Bool {
        lhs.id == rhs.id
    }
}
