import SwiftUI




// The enum is now in the same file as the struct that uses it.
enum RecurrenceInterval: String, CaseIterable, Codable, Hashable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    var id: String { self.rawValue }
}


struct RecurringPayment: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var amount: Double
    var category: String
    var recurrenceInterval: RecurrenceInterval
    var startDate: Date
    var nextDueDate: Date
    var endDate: Date?
    var notes: String?
    var iconName: String
    var colorHex: String

    var accentColor: Color {
        Color(hex: colorHex)
    }

    var isEnded: Bool {
        guard let definiteEndDate = endDate else { return false }
        return definiteEndDate < Calendar.current.startOfDay(for: Date())
    }
    
    var isPastDue: Bool {
        !isEnded && nextDueDate < Calendar.current.startOfDay(for: Date())
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RecurringPayment, rhs: RecurringPayment) -> Bool {
        lhs.id == rhs.id
    }

    init(id: UUID = UUID(), name: String, amount: Double, category: String,
         recurrenceInterval: RecurrenceInterval, startDate: Date,
         nextDueDate: Date? = nil,
         endDate: Date? = nil, notes: String? = nil,
         iconName: String, colorHex: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.category = category
        self.recurrenceInterval = recurrenceInterval
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.endDate = endDate.map { Calendar.current.startOfDay(for: $0) }
        self.notes = notes
        self.iconName = iconName
        self.colorHex = colorHex
        
        if let providedNextDueDate = nextDueDate, providedNextDueDate >= Calendar.current.startOfDay(for: Date()) {
            self.nextDueDate = Calendar.current.startOfDay(for: providedNextDueDate)
        } else {
            self.nextDueDate = RecurringPayment.calculateCorrectNextDueDate(
                from: self.startDate,
                interval: recurrenceInterval,
                after: Calendar.current.startOfDay(for: Date())
            )
        }
        
        if let definiteEndDate = self.endDate, self.nextDueDate > definiteEndDate {
        }
    }

    static func calculateCorrectNextDueDate(from initialStartDate: Date, interval: RecurrenceInterval, after referenceDate: Date) -> Date {
        var potentialNextDate = Calendar.current.startOfDay(for: initialStartDate)
        let calendar = Calendar.current
        let normalizedReferenceDate = Calendar.current.startOfDay(for: referenceDate)

        if potentialNextDate >= normalizedReferenceDate {
            return potentialNextDate
        }

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
            if potentialNextDate == lastPotentialDate { break }
        }
        return potentialNextDate
    }
    
    func getNextSequentialDueDate() -> Date {
        let calendar = Calendar.current
        var newCalculatedDueDate = self.nextDueDate
        
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
