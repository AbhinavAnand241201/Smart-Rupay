// In the file containing your Financial Goals UI

import SwiftUI

struct FinancialGoalsListView: View {
    @StateObject private var viewModel = FinancialGoalsViewModel()
    @State private var showingAddGoalView = false
    @State private var showingContributeSheet = false
    @State private var selectedGoal: FinancialGoal?

    var body: some View {
        NavigationView {
            ZStack {
                Color.App.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Text("Financial Goals")
                        .font(.largeTitle.bold())
                        .foregroundColor(Color.App.textPrimary)
                        .padding(.horizontal)
                        .padding(.top, 5)
                        .padding(.bottom, 10)
                    
                    if viewModel.isLoading {
                        ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let errorMessage = viewModel.errorMessage {
                        errorStateView(message: errorMessage)
                    } else if viewModel.goals.isEmpty {
                        emptyStateView
                    } else {
                        goalsList
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddGoalView) {
                AddFinancialGoalView().environmentObject(viewModel)
            }
            .sheet(isPresented: $showingContributeSheet, content: {
                if let goal = selectedGoal {
                    ContributionPlaceholderView(goal: goal, isPresented: $showingContributeSheet)
                }
            })
            .task {
                await viewModel.fetchGoals()
            }
        }
    }
    
    private var goalsList: some View {
        List {
            ForEach(viewModel.goals) { goal in
                FinancialGoalRowView(goal: goal)
                    .onTapGesture {
                        self.selectedGoal = goal
                        self.showingContributeSheet = true
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 8)
                    .padding(.horizontal)
            }
            .onDelete(perform: viewModel.deleteGoal)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.App.background)
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.fetchGoals()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(Color.App.accent.opacity(0.6))
            Text("Set Your Sights")
                .font(.title2.weight(.bold))
                .foregroundColor(Color.App.textPrimary)
            Text("Create financial goals to track your progress towards your dreams. Tap the '+' button to begin.")
                .font(.subheadline)
                .foregroundColor(Color.App.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Add First Goal") {
                showingAddGoalView = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding()
            Spacer()
            Spacer()
        }
    }
    
    private func errorStateView(message: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle).foregroundColor(.yellow)
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center).padding()
            Spacer()
        }
    }
}

struct FinancialGoalRowView: View {
    let goal: FinancialGoal

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: goal.iconName)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(goal.accentColor)
                .frame(width: 50, height: 50)
                .background(goal.accentColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 8) {
                Text(goal.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.App.textPrimary)

                ProgressView(value: goal.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: goal.accentColor))
                    .scaleEffect(x: 1, y: 2.5, anchor: .center)
                    .clipShape(Capsule())
                
                HStack {
                    Text("₹\(Int(goal.currentAmount)) / ₹\(Int(goal.targetAmount))")
                        .font(.caption.weight(.medium))
                        .foregroundColor(Color.App.textSecondary)
                    Spacer()
                    if goal.isCompleted {
                        Text("Achieved!")
                            .font(.caption.weight(.bold))
                            .foregroundColor(goal.accentColor)
                    } else if let deadline = goal.deadline {
                        // Using the corrected, direct date formatter
                        Text("Due: \(formattedDeadline(date: deadline))")
                            .font(.caption.weight(.medium))
                            .foregroundColor(Color.App.textSecondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.App.card)
        .cornerRadius(20)
    }

    // This helper function formats the date correctly, fixing the error.
    private func formattedDeadline(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy" // e.g., "Jun 2025"
        return formatter.string(from: date)
    }
}

// Reusable Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.App.accent)
            .foregroundColor(.black)
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Placeholder sheet for contributing to a goal
struct ContributionPlaceholderView: View {
    let goal: FinancialGoal
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Contribute to")
                    .font(.title2)
                    .foregroundColor(Color.App.textSecondary)
                Text(goal.name)
                    .font(.largeTitle.bold())
                Button("Done") {
                    isPresented = false
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            }
        }
    }
}

struct FinancialGoalsListView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialGoalsListView()
    }
}
