// FilterModels.swift
// Created by Smart-Rupay App (via AI)

import Foundation // Or SwiftUI if needed, but Foundation is fine for these models

enum TransactionTypeFilter: String, CaseIterable, Identifiable, Hashable {
    case all = "All"
    case income = "Income"
    case expenses = "Expenses"
    var id: String { self.rawValue }
}

struct TransactionFilterCriteria: Equatable, Hashable {
    var searchTerm: String = ""
    var startDate: Date? = nil
    var endDate: Date? = nil
    var transactionType: TransactionTypeFilter = .all
    var selectedCategories: Set<String> = [] // Store names of selected categories
    var minAmount: String = "" // Store as String for TextField, convert to Double for filtering
    var maxAmount: String = "" // Store as String for TextField, convert to Double for filtering

    // Computed property to check if any filters are active
    var isActive: Bool {
        return startDate != nil || endDate != nil ||
               !selectedCategories.isEmpty ||
               (!minAmount.isEmpty && Double(minAmount) != nil) ||
               (!maxAmount.isEmpty && Double(maxAmount) != nil) ||
               transactionType != .all ||
               !searchTerm.isEmpty
    }

    // Make it Hashable if you plan to use it in ways that require it (e.g., certain SwiftUI views)
    // For Equatable, ensure all properties are compared.
    static func == (lhs: TransactionFilterCriteria, rhs: TransactionFilterCriteria) -> Bool {
        return lhs.searchTerm == rhs.searchTerm &&
               lhs.startDate == rhs.startDate &&
               lhs.endDate == rhs.endDate &&
               lhs.transactionType == rhs.transactionType &&
               lhs.selectedCategories == rhs.selectedCategories &&
               lhs.minAmount == rhs.minAmount &&
               lhs.maxAmount == rhs.maxAmount
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(searchTerm)
        hasher.combine(startDate)
        hasher.combine(endDate)
        hasher.combine(transactionType)
        hasher.combine(selectedCategories)
        hasher.combine(minAmount)
        hasher.combine(maxAmount)
    }
}
