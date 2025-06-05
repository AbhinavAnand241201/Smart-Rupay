// RecurringPaymentModels.swift
// Smart-Rupay App

import SwiftUI

// Defines the interval for recurring payments
enum RecurrenceInterval: String, CaseIterable, Codable, Hashable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    var id: String { self.rawValue } // Conformance to Identifiable
}

// Represents a single recurring payment or subscription
struct RecurringPayment: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var amount: Double
    var category: String // Should ideally link to a Category model/enum
    var recurrenceInterval: RecurrenceInterval
    var startDate: Date      // The very first date this payment was/is due
    var nextDueDate: Date    // The upcoming due date
    var endDate: Date?       // Optional: For subscriptions with a fixed end
    var notes: String?
    var iconName: String     // SF Symbol name for visual representation
    var colorHex: String     // Hex string for accent color

    // Computed property to get the accent color from the hex string
    var accentColor: Color {
        Color(hex: colorHex) // Assumes Color(hex:) extension is available
    }

    // Computed property to check if the recurring payment has ended based on its endDate
    var isEnded: Bool {
        guard let definiteEndDate = endDate else { return false }
        // Considered ended if the end date is in the past (before the start of today)
        return definiteEndDate < Calendar.current.startOfDay(for: Date())
    }
    
    // Computed property to check if the current nextDueDate is past (and not ended)
    var isPastDue: Bool {
        !isEnded && nextDueDate < Calendar.current.startOfDay(for: Date())
    }


    // Conformance to Hashable and Equatable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: RecurringPayment, rhs: RecurringPayment) -> Bool {
        lhs.id == rhs.id
    }

    // Initializer
    init(id: UUID = UUID(), name: String, amount: Double, category: String,
         recurrenceInterval: RecurrenceInterval, startDate: Date,
         nextDueDate: Date? = nil, // Allows providing an explicit next due date, otherwise calculated
         endDate: Date? = nil, notes: String? = nil,
         iconName: String, colorHex: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.category = category
        self.recurrenceInterval = recurrenceInterval
        // Ensure startDate is at the beginning of its day for consistent calculations
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.endDate = endDate.map { Calendar.current.startOfDay(for: $0) } // Normalize endDate too
        self.notes = notes
        self.iconName = iconName
        self.colorHex = colorHex
        
        // Calculate initial nextDueDate if not explicitly provided or if provided one is in the past
        if let providedNextDueDate = nextDueDate, providedNextDueDate >= Calendar.current.startOfDay(for: Date()) {
            self.nextDueDate = Calendar.current.startOfDay(for: providedNextDueDate)
        } else {
            self.nextDueDate = RecurringPayment.calculateCorrectNextDueDate(
                from: self.startDate, // Use normalized startDate
                interval: recurrenceInterval,
                after: Calendar.current.startOfDay(for: Date()) // Calculate based on today
            )
        }
        
        // Ensure nextDueDate does not exceed endDate if one is set
        if let definiteEndDate = self.endDate, self.nextDueDate > definiteEndDate {
            // This scenario implies the recurrence has already passed its end.
            // Set nextDueDate to something that indicates it's finished, or handle as "ended".
            // For simplicity, if calculated next due date is past end date, it means it's effectively ended.
            // The `isEnded` property will catch this.
            // Or, ensure nextDueDate isn't set beyond endDate if we want the last possible due date.
            // Let's keep nextDueDate as calculated; isEnded will manage display.
        }
    }

    // Static helper to calculate the correct next due date on or after a reference date
    static func calculateCorrectNextDueDate(from initialStartDate: Date, interval: RecurrenceInterval, after referenceDate: Date) -> Date {
        var potentialNextDate = Calendar.current.startOfDay(for: initialStartDate)
        let calendar = Calendar.current
        let normalizedReferenceDate = Calendar.current.startOfDay(for: referenceDate)

        // If the initial start date is already on or after the reference date, it's the one.
        if potentialNextDate >= normalizedReferenceDate {
            return potentialNextDate
        }

        // Otherwise, advance from the initial start date until we are on or after the reference date.
        while potentialNextDate < normalizedReferenceDate {
            let lastPotentialDate = potentialNextDate
            switch interval {
            case .daily:
                potentialNextDate = calendar.date(byAdding: .day, value: 1, to: potentialNextDate)!
            case .weekly:
                potentialNextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: potentialNextDate)!
            case .monthly:
                potentialNextDate = calendar.date(byAdding: .month, value: 1, to: potentialNextDate)!
            case .yearly:
                potentialNextDate = calendar.date(byAdding: .year, value: 1, to: potentialNextDate)!
            }
            // Safety break for misconfiguration, though unlikely with standard intervals
            if potentialNextDate == lastPotentialDate { break }
        }
        return potentialNextDate
    }
    
    // Instance method to get the next due date after the current `self.nextDueDate`
    func  getNextSequentialDueDate() -> Date {
        let calendar = Calendar.current
        var newCalculatedDueDate = self.nextDueDate // Start from the current nextDueDate
        
        switch self.recurrenceInterval {
        case .daily:
            newCalculatedDueDate = calendar.date(byAdding: .day, value: 1, to: newCalculatedDueDate)!
        case .weekly:
            newCalculatedDueDate = calendar.date(byAdding: .weekOfYear, value: 1, to: newCalculatedDueDate)!
        case .monthly:
            newCalculatedDueDate = calendar.date(byAdding: .month, value: 1, to: newCalculatedDueDate)!
        case .yearly:
            newCalculatedDueDate = calendar.date(byAdding: .year, value: 1, to: newCalculatedDueDate)!
        }
        return newCalculatedDueDate
    }
}
