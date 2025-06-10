
import SwiftUI

struct AdvancedFilterView: View {
    @Binding var currentFilters: TransactionFilterCriteria
    @Binding var isPresented: Bool
    
    @State private var editableFilters: TransactionFilterCriteria

    let allCategories: [String] = [
        "Groceries", "Dining Out", "Transportation", "Entertainment", "Shopping",
        "Utilities", "Salary", "Freelance Income", "Dividends", "Rent", "Healthcare",
        "Education", "Gifts", "Other Income", "Other Expense"
    ].sorted()

    
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let headerTextColor = Color(hex: "BEBEBE") // Brighter Gray for headers
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")

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
                        TextField("Search (e.g., merchant, note ,pay)", text: $editableFilters.searchTerm)
                            .listRowBackground(cardBackgroundColor)
                            .foregroundColor(mainTextColor)
                            .tint(accentColorTeal)
                    } header: {
                        Text("Search Keyword")
                            .foregroundColor(headerTextColor) // Use updated header color
                            .textCase(nil) // Prevent automatic uppercasing if it affects color
                    }

                    Section {
                        DatePicker("Start Date",
                                   selection: Binding(
                                    get: { editableFilters.startDate ?? Date() },
                                    set: { editableFilters.startDate = $0 }
                                   ),
                                   in: ...(editableFilters.endDate ?? Date()),
                                   displayedComponents: .date
                        )
                        .accentColor(accentColorTeal)
                        // .environment(\.colorScheme, .dark) // Form should inherit this

                        DatePicker("End Date",
                                   selection: Binding(
                                    get: { editableFilters.endDate ?? Date() },
                                    set: { editableFilters.endDate = $0 }
                                   ),
                                   in: (editableFilters.startDate ?? .distantPast)...Date(),
                                   displayedComponents: .date
                        )
                        .accentColor(accentColorTeal)
                        // .environment(\.colorScheme, .dark)

                    } header: {
                        Text("Date Range")
                            .foregroundColor(headerTextColor) // Use updated header color
                            .textCase(nil)
                    }
                    .listRowBackground(cardBackgroundColor)
                    .foregroundColor(mainTextColor) // Applies to DatePicker labels
                    .environment(\.colorScheme, .dark) // Ensure DatePicker text within row is light


                    Section {
                        Picker("Type", selection: $editableFilters.transactionType) {
                            ForEach(TransactionTypeFilter.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    } header: {
                        Text("Transaction Type")
                            .foregroundColor(headerTextColor) // Use updated header color
                            .textCase(nil)
                    }

                    Section {
                        MultiSelectPickerView(
                            title: "Select Categories",
                            allItems: allCategories,
                            selectedItems: $editableFilters.selectedCategories
                        )
                    } header: {
                        Text("Categories")
                           .foregroundColor(headerTextColor) // Use updated header color
                           .textCase(nil)
                    }
                   .listRowBackground(cardBackgroundColor)
                    
                    Section {
                        HStack {
                            TextField("Min Amount", text: $editableFilters.minAmount)
                                .keyboardType(.decimalPad)
                                .tint(accentColorTeal)
                            Text("-").foregroundColor(secondaryTextColor) // Use secondary for the dash
                            TextField("Max Amount", text: $editableFilters.maxAmount)
                                .keyboardType(.decimalPad)
                                .tint(accentColorTeal)
                        }
                    } header: {
                        Text("Amount Range")
                            .foregroundColor(headerTextColor) // Use updated header color
                            .textCase(nil)
                    }
                    .listRowBackground(cardBackgroundColor)
                    .foregroundColor(mainTextColor)
                }
                .scrollContentBackground(.hidden)
                .environment(\.colorScheme, .dark) // Apply to Form to influence default styles
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
                // Explicitly set title color if still an issue
                ToolbarItem(placement: .principal) {
                     Text("Filters & Search")
                         .font(.headline) // Or .system(size: 20, weight: .bold)
                         .foregroundColor(mainTextColor)
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
        }
        .preferredColorScheme(.dark) // Apply to NavigationView
    }
}

struct MultiSelectPickerView: View {
    let title: String
    let allItems: [String]
    @Binding var selectedItems: Set<String>
    @State private var isExpanded: Bool = false
    
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")
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
            .buttonStyle(.plain)

            if isExpanded {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(allItems, id: \.self) { item in
                            Button(action: {
                                if selectedItems.contains(item) {
                                    selectedItems.remove(item)
                                } else {
                                    selectedItems.insert(item)
                                }
                            }) {
                                Text(item)
                                    .font(.system(size: 13))
                                    .lineLimit(1)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 5)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(selectedItems.contains(item) ? accentColorTeal : itemBackgroundColor)
                                    .foregroundColor(selectedItems.contains(item) ? .black : mainTextColor)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 220)
                .padding(.top, 5)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct AdvancedFilterView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedFilterView(
            currentFilters: .constant(TransactionFilterCriteria()),
            isPresented: .constant(true)
        )
    }
}
