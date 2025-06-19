import SwiftUI

struct AdvancedFilterView: View {
    // MARK: - Properties
    @Binding var currentFilters: TransactionFilterCriteria
    @Binding var isPresented: Bool
    
    @State private var editableFilters: TransactionFilterCriteria
    
    let allCategories: [String] = [
        "Groceries", "Dining Out", "Transportation", "Entertainment", "Shopping",
        "Utilities", "Salary", "Freelance Income", "Dividends", "Rent", "Healthcare",
        "Education", "Gifts", "Other Income", "Other Expense"
    ].sorted()

    init(currentFilters: Binding<TransactionFilterCriteria>, isPresented: Binding<Bool>) {
        self._currentFilters = currentFilters
        self._isPresented = isPresented
        self._editableFilters = State(initialValue: currentFilters.wrappedValue)
    }

    // These helpers convert our optional Dates (Date?) into non-optional Dates (Date)
        // that the DatePicker can use.
        private var startDateBinding: Binding<Date> {
            Binding(
                get: { self.editableFilters.startDate ?? Date() },
                set: { self.editableFilters.startDate = $0 }
            )
        }

        private var endDateBinding: Binding<Date> {
            Binding(
                get: { self.editableFilters.endDate ?? Date() },
                set: { self.editableFilters.endDate = $0 }
            )
        }
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.App.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Each section is now a custom "card" with better styling and visibility
                        FilterSectionCard(title: "Search Keyword") {
                            TextField("Search (e.g., Starbucks, Amazon)", text: $editableFilters.searchTerm)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(Color.App.background.opacity(0.5)) // Darker background for contrast
                                .cornerRadius(10)
                                .tint(Color.App.accent)
                                .foregroundColor(Color.App.textPrimary) // Ensure text is visible
                        }
                        
                        FilterSectionCard(title: "Date Range") {
                            DatePicker("Start Date", selection: startDateBinding, in: ...Date(), displayedComponents: .date)
                                .foregroundColor(Color.App.textPrimary)
                                .tint(Color.App.accent)
                            
                            Divider().background(Color.App.background)
                            
                            DatePicker("End Date", selection: endDateBinding, in: ...Date(), displayedComponents: .date)
                                .foregroundColor(Color.App.textPrimary)
                                .tint(Color.App.accent)
                        }
                        FilterSectionCard(title: "Transaction Type") {
                            Picker("Type", selection: $editableFilters.transactionType) {
                                ForEach(TransactionTypeFilter.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        FilterSectionCard(title: "Categories") {
                            MultiSelectPickerView(
                                allItems: allCategories,
                                selectedItems: $editableFilters.selectedCategories
                            )
                        }
                        
                        // Add padding at the bottom to ensure content scrolls above the action buttons
                        Color.clear.frame(height: 120)
                    }
                    .padding(.top, 20)
                }
                
                // MARK: - Floating Action Buttons
                actionButtons
            }
            .navigationTitle("Filters & Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") { editableFilters = TransactionFilterCriteria() }
                        .tint(Color.App.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { isPresented = false }
                        .tint(Color.App.accent)
                }
            }
        }
    }
    
    // MARK: - Action Buttons View
    private var actionButtons: some View {
        HStack(spacing: 15) {
            Button(action: {
                // This now resets the editable filters back to their original state
                editableFilters = currentFilters
            }) {
                Text("Reset")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.App.card) // Use card color for secondary action
                    .foregroundColor(Color.App.textPrimary)
                    .cornerRadius(16)
            }
            
            Button(action: {
                currentFilters = editableFilters
                isPresented = false
            }) {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    Text("Apply Filters")
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.App.accent) // Bright, clear primary action
                .foregroundColor(.black)
                .cornerRadius(16)
                .shadow(color: Color.App.accent.opacity(0.4), radius: 8, y: 4)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .padding(.top)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Custom Filter Section Card
private struct FilterSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.App.textSecondary) // Use secondary text color for headers
            
            content
        }
        .padding()
        .background(Color.App.card) // Use our standard card color
        .cornerRadius(20)
        .padding(.horizontal)
    }
}


// MARK: - Enhanced Multi-Select Picker
private struct MultiSelectPickerView: View {
    let allItems: [String]
    @Binding var selectedItems: Set<String>
    
    private let columns = [GridItem(.adaptive(minimum: 100, maximum: 120))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(allItems, id: \.self) { item in
                let isSelected = selectedItems.contains(item)
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if isSelected {
                            selectedItems.remove(item)
                        } else {
                            selectedItems.insert(item)
                        }
                    }
                }) {
                    Text(item)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .foregroundColor(isSelected ? .black : Color.App.textPrimary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(isSelected ? Color.App.accent : Color.App.background.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.clear : Color.App.textSecondary.opacity(0.4), lineWidth: 1)
                        )
                }
            }
        }
    }
}



// MARK: - Preview
struct AdvancedFilterView_Previews: PreviewProvider {
    static var previews: some View {
        // Example of how the filter view is presented
        Text("Parent View")
            .sheet(isPresented: .constant(true)) {
                AdvancedFilterView(
                    currentFilters: .constant(TransactionFilterCriteria()),
                    isPresented: .constant(true)
                )
            }
    }
}


//i'll come to this at last 
