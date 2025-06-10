
import SwiftUI

struct FinancialGoalRowView: View {
    let goal: FinancialGoal

    // UI Colors
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")

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


struct FinancialGoalsListView: View {
    @StateObject private var viewModel = FinancialGoalsViewModel()
    @State private var showingAddGoalView = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()

                VStack {
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    } else if let errorMessage = viewModel.errorMessage {
                        // Display an error message if something went wrong
                        VStack {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.yellow)
                            Text(errorMessage)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        }
                    } else if viewModel.goals.isEmpty {
                        // The empty state view when there are no goals
                        emptyStateView
                    } else {
                        // The list of goals
                        List {
                            ForEach(viewModel.goals) { goal in
                                FinancialGoalRowView(goal: goal)
                                    .listRowInsets(EdgeInsets())
                                    .padding(.vertical, 8)
                            }
                            // FIXED: This now correctly calls the async delete function in the ViewModel.
                            .onDelete(perform: viewModel.deleteGoal)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(red: 0.08, green: 0.09, blue: 0.10))
                        }
                        .listStyle(.plain)
                        .refreshable {
                            // Allows pull-to-refresh
                            await viewModel.fetchGoals()
                        }
                    }
                }
            }
            .navigationTitle("Financial Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGoalView = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "3AD7D5"))
                    }
                }
            }
            .sheet(isPresented: $showingAddGoalView) {
                AddFinancialGoalView()
                    .environmentObject(viewModel)
            }
            .task {
                await viewModel.fetchGoals()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Spacer()
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "A0A0A0").opacity(0.5))
            Text("No Goals Yet")
                .font(.title2.weight(.semibold))
                .foregroundColor(Color(hex: "A0A0A0"))
            Text("Tap the '+' button to create your first financial goal and start tracking your progress!")
                .font(.subheadline)
                .foregroundColor(Color(hex: "A0A0A0").opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            Spacer()
        }
    }
}
struct FinancialGoalsListView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialGoalsListView()
            .environmentObject(FinancialGoalsViewModel()) // For previews if ViewModel is complex
    }
}

