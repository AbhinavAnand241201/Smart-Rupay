// AdvancedFilterView.swift

// AdvancedFilterView.swift
// Created by Smart-Rupay App (via AI) - Fully Revised

import SwiftUI

struct AdvancedFilterView: View {
    @Binding var currentFilters: TransactionFilterCriteria
    @Binding var isPresented: Bool
    
    @State private var editableFilters: TransactionFilterCriteria

    // Sample categories - in a real app, these would come from user data or a central service
    let allCategories: [String] = [
        "Groceries", "Dining Out", "Transportation", "Entertainment", "Shopping",
        "Utilities", "Salary", "Freelance Income", "Dividends", "Rent", "Healthcare",
        "Education", "Gifts", "Other Income", "Other Expense"
    ].sorted()

    // MARK: - UI Colors
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0") // Standard secondary text color
    let accentColorTeal = Color(hex: "3AD7D5")   // Standard accent

    init(currentFilters: Binding<TransactionFilterCriteria>, isPresented: Binding<Bool>) {
        self._currentFilters = currentFilters
        self._isPresented = isPresented
        self._editableFilters = State(initialValue: currentFilters.wrappedValue)
    }

    var body: some View {
        NavigationView {
            ZStack {
                screenBackgroundColor.ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Search (e.g., merchant, note)", text: $editableFilters.searchTerm)
                            .listRowBackground(cardBackgroundColor)
                            .foregroundColor(mainTextColor)
                            .tint(accentColorTeal) // Cursor color
                    } header: {
                        Text("Search Keyword")
                            .foregroundColor(secondaryTextColor)
                    }

                    // Inside AdvancedFilterView.swift

                    // ... other code ...

                                        Section { // Date Range Section
                                            DatePicker("Start Date",
                                                       selection: Binding(
                                                        get: { editableFilters.startDate ?? Date() },
                                                        set: { editableFilters.startDate = $0 }
                                                       ),
                                                       // Ensure NO SPACE after '...' on the next line
                                                       in: ...(editableFilters.endDate ?? Date()), // Correct: ...value
                                                       displayedComponents: .date
                                            )
                                            .accentColor(accentColorTeal)
                                            .environment(\.colorScheme, .dark)

                                            DatePicker("End Date",
                                                       selection: Binding(
                                                        get: { editableFilters.endDate ?? Date() },
                                                        set: { editableFilters.endDate = $0 }
                                                       ),
                                                       // For ClosedRange, spaces are fine, but no space is also fine.
                                                       in: (editableFilters.startDate ?? .distantPast)...Date(),
                                                       displayedComponents: .date
                                            )
                                            .accentColor(accentColorTeal)
                                            .environment(\.colorScheme, .dark)

                                        } header: {
                                            Text("Date Range")
                                                .foregroundColor(secondaryTextColor)
                                        }
                                        .listRowBackground(cardBackgroundColor)
                                        .foregroundColor(mainTextColor)

                    // ... rest of the code ...

                    Section {
                        Picker("Type", selection: $editableFilters.transactionType) {
                            ForEach(TransactionTypeFilter.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        // For SegmentedPicker, background color needs to be managed differently if desired
                        // For now, relying on system default which adapts to .preferredColorScheme(.dark)
                    } header: {
                        Text("Transaction Type")
                            .foregroundColor(secondaryTextColor)
                    }
                    // .listRowBackground(cardBackgroundColor) // Segmented picker doesn't use this well

                    Section {
                        MultiSelectPickerView( // Custom Multi-select picker
                            title: "Select Categories",
                            allItems: allCategories,
                            selectedItems: $editableFilters.selectedCategories
                        )
                    } header: {
                        Text("Categories")
                           .foregroundColor(secondaryTextColor)
                    }
                    .listRowBackground(cardBackgroundColor)
                    
                    Section {
                        HStack {
                            TextField("Min Amount", text: $editableFilters.minAmount)
                                .keyboardType(.decimalPad)
                                .tint(accentColorTeal)
                            Text("-").foregroundColor(secondaryTextColor)
                            TextField("Max Amount", text: $editableFilters.maxAmount)
                                .keyboardType(.decimalPad)
                                .tint(accentColorTeal)
                        }
                    } header: {
                        Text("Amount Range")
                            .foregroundColor(secondaryTextColor)
                    }
                    .listRowBackground(cardBackgroundColor)
                    .foregroundColor(mainTextColor)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filters & Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        editableFilters = TransactionFilterCriteria()
                    }
                    .foregroundColor(accentColorTeal)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        currentFilters = editableFilters
                        isPresented = false
                    }
                    .foregroundColor(accentColorTeal)
                    .fontWeight(.bold)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct MultiSelectPickerView: View { // Same as before
    let title: String
    let allItems: [String]
    @Binding var selectedItems: Set<String>

    @State private var isExpanded: Bool = false
    
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")
    // Item background can be slightly different from card BG to stand out within the card
    let itemBackgroundColor = Color(red: 0.20, green: 0.21, blue: 0.23)


    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            }) {
                HStack {
                    Text(title)
                        .foregroundColor(mainTextColor)
                    Spacer()
                    Text(selectedItems.isEmpty ? "All" : "\(selectedItems.count) selected")
                        .foregroundColor(secondaryTextColor)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(secondaryTextColor)
                }
            }
            .buttonStyle(.plain) // Use if default button styling interferes

            if isExpanded {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) { // Changed to 2 columns for better fit
                        ForEach(allItems, id: \.self) { item in
                            Button(action: {
                                if selectedItems.contains(item) {
                                    selectedItems.remove(item)
                                } else {
                                    selectedItems.insert(item)
                                }
                            }) {
                                Text(item)
                                    .font(.system(size: 13)) // Slightly smaller font for grid items
                                    .lineLimit(1)
                                    .padding(.vertical, 10) // Increased vertical padding
                                    .padding(.horizontal, 5)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(selectedItems.contains(item) ? accentColorTeal : itemBackgroundColor)
                                    .foregroundColor(selectedItems.contains(item) ? .black : mainTextColor) // Ensure contrast
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain) // Use if default button styling interferes
                        }
                    }
                }
                .frame(maxHeight: 220) // Adjust height as needed
                .padding(.top, 5)
                .transition(.opacity.combined(with: .move(edge: .top))) // Added animation
            }
        }
    }
}

struct AdvancedFilterView_Previews: PreviewProvider { // Same as before
    static var previews: some View {
        AdvancedFilterView(
            currentFilters: .constant(TransactionFilterCriteria()),
            isPresented: .constant(true)
        )
    }
}
