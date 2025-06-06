//
//  FinancialGoalRowView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 03/06/25.
//


// FinancialGoalsScreen.swift

import SwiftUI

struct FinancialGoalRowView: View {
    let goal: FinancialGoal

    // UI Colors
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    // Goal's accentColor will be used for progress bar and icon

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: goal.iconName)
                .font(.system(size: 22))
                .foregroundColor(goal.accentColor)
                .frame(width: 40, height: 40)
                .background(goal.accentColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(goal.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(mainTextColor)
                    .lineLimit(1)

                ProgressView(value: goal.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: goal.accentColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center) // Make progress bar thicker
                    .clipShape(Capsule())


                HStack {
                    Text(String(format: "$%.0f / $%.0f", goal.currentAmount, goal.targetAmount))
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                    Spacer()
                    if let deadline = goal.deadline, !goal.isCompleted {
                        Text("Due: \(deadline, style: .date)")
                            .font(.caption)
                            .foregroundColor(secondaryTextColor)
                    } else if goal.isCompleted {
                        Text("Completed!")
                            .font(.caption.weight(.bold))
                            .foregroundColor(goal.accentColor)
                    }
                }
            }
            Spacer()
            // Example: Allow contributing to a goal directly from the row
            // This would typically open a sheet or navigate to a contribution screen
            Button {
                // Action to add contribution - placeholder
                print("Add contribution to \(goal.name)")
                // In a real app, this would trigger a UI to input amount
                // viewModel.updateGoalContribution(goalId: goal.id, additionalAmount: 50) // Example
            } label: {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(goal.isCompleted ? goal.accentColor : Color(hex: "3AD7D5")) // Main app accent for add
            }
            .buttonStyle(.plain) // To ensure it doesn't interfere with row tap if row is NavigationLink
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
}
// In FinancialGoalsScreen.swift (or FinancialGoalRowView.swift)

struct FinancialGoalsListView: View {
    @StateObject private var viewModel = FinancialGoalsViewModel()
    @State private var showingAddGoalView = false

    // UI Colors
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let mainTextColor = Color.white // This will be used for the custom title
    let accentColorTeal = Color(hex: "3AD7D5")
    let secondaryTextColor = Color(hex: "A0A0A0")
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                screenBackgroundColor.ignoresSafeArea()

                VStack {
                    // ... (your existing if/else for viewModel.goals.isEmpty) ...
                    if viewModel.goals.isEmpty {
                        // ... Empty state view ...
                         Spacer()
                        VStack(spacing:15) {
                            Image(systemName: "target")
                                .font(.system(size: 60))
                                .foregroundColor(secondaryTextColor.opacity(0.5))
                            Text("No Goals Yet")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(secondaryTextColor)
                            Text("Tap the '+' button to create your first financial goal and start tracking your progress!")
                                .font(.subheadline)
                                .foregroundColor(secondaryTextColor.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            Button {
                                showingAddGoalView = true
                            } label: {
                                Text("Add Your First Goal")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(accentColorTeal)
                                    .foregroundColor(.black) // Or dark gray for contrast
                                    .cornerRadius(10)
                            }
                            .padding(.top)
                        }
                        Spacer()
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.goals) { goal in
                                FinancialGoalRowView(goal: goal)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(screenBackgroundColor)
                            }
                            .onDelete(perform: viewModel.deleteGoal)
                        }
                        .listStyle(.plain)
                        .background(screenBackgroundColor)
                    }
                }
            }
            // REMOVE .navigationTitle("Financial Goals") if using .principal below for inline title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(mainTextColor)
                    }
                    .opacity(0) // Still hidden as per previous, adjust if needed
                }
                
                // --- START: CUSTOM TITLE ---
                ToolbarItem(placement: .principal) {
                    Text("Financial Goals")
                        .font(.system(size: 20, weight: .bold)) // Style to match default inline title
                        .foregroundColor(mainTextColor)       // Explicitly set color
                }
                // --- END: CUSTOM TITLE ---
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGoalView = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(accentColorTeal)
                    }
                }
            }
            // .toolbarColorScheme(.dark, for: .navigationBar) // You can keep or remove this; the custom principal item will take precedence for the title color.
            .sheet(isPresented: $showingAddGoalView) {
                AddFinancialGoalView(viewModel: viewModel)
            }
            .preferredColorScheme(.dark) // Good to maintain overall dark theme context
        }
        // .navigationViewStyle(.stack) // Useful on iPad to avoid split view issues if not desired
    }
}
// MARK: - Preview
struct FinancialGoalsListView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialGoalsListView()
            .environmentObject(FinancialGoalsViewModel()) // For previews if ViewModel is complex
    }
}

