import SwiftUI

// This is the main view for the Budgets screen.
struct BudgetsScreenView: View {
    // FIXED: Use @StateObject to create and keep the ViewModel alive.
    @StateObject private var viewModel = BudgetViewModel()
    @State private var isPresentingAddSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // This list now correctly iterates over the @Published array in the ViewModel.
                    // This fixes the "subscript requires wrapper" error.
                    List {
                        ForEach(viewModel.budgets) { budget in
                            BudgetCategoryRow(item: budget)
                                .listRowBackground(Color(red: 0.08, green: 0.09, blue: 0.10))
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(red: 0.08, green: 0.09, blue: 0.10))

                    Spacer()

                    // "Add Budget" Button
                    Button(action: { isPresentingAddSheet.toggle() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("Add Budget")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(hex: "3AD7D5"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                .navigationTitle("Budgets")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $isPresentingAddSheet) {
                    // Present the AddBudgetView and pass the viewModel to it.
                    AddBudgetView()
                        .environmentObject(viewModel)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

// FIXED: This row view now correctly uses the `BudgetItem` model from the ViewModel.
struct BudgetCategoryRow: View {
    let item: BudgetItem

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: item.iconName)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color(red: 0.15, green: 0.16, blue: 0.18))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("₹\(Int(item.spentAmount)) of ₹\(Int(item.amount))")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "A0A0A0"))
            }

            Spacer()

            HStack(spacing: 10) {
                ProgressView(value: item.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: item.accentColor))
                    .frame(width: 70, height: 6)
                    .clipShape(Capsule())

                Text("\(Int(item.progress * 100))%")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding()
        .background(Color(red: 0.15, green: 0.16, blue: 0.18))
        .cornerRadius(12)
    }
}

struct BudgetsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetsScreenView()
    }
}

// Your Color extension remains necessary here.
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
