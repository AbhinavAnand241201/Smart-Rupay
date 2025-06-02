//
//  AccountSummaryItemData.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 02/06/25.
//


import SwiftUI

// Assuming Color(hex: String) extension is globally available from a previous file.

// MARK: - Data Models
struct AccountSummaryItemData: Identifiable {
    let id = UUID()
    let accountType: String
    let balance: Double
    let bankName: String
    let logoText: String // For simplicity, using text for the logo
    let logoAbbreviation: String // e.g. BUA for BUAIBANK
    let logoBackgroundColor: Color
}

struct TransactionSummaryItemData: Identifiable {
    let id = UUID()
    let merchantName: String
    let category: String
    let amount: Double
}

enum FinanceScreenSegment: String, CaseIterable {
    case overview = "Overview"
    case transactions = "Transactions"
    case budgets = "Budgets"
    case investments = "Investments"
    // Add other segments if needed
}

// MARK: - Finance Tracker Screen View
struct FinanceTrackerScreenView: View {
    @State private var selectedSegment: FinanceScreenSegment = .overview

    // Colors
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let textColor = Color.white
    let subtitleColor = Color(hex: "A0A0A0") // A common gray from previous files
    let segmentIndicatorColor = Color.white
    let unselectedSegmentColor = Color(hex: "8E8E93") // A common gray for unselected items

    // Sample Data
    let accountItems: [AccountSummaryItemData] = [
        AccountSummaryItemData(accountType: "Checking", balance: 1234.56, bankName: "Bank of America", logoText: "BUAIBANK", logoAbbreviation: "BUA", logoBackgroundColor: Color(hex: "2C3A4F")),
        AccountSummaryItemData(accountType: "Savings", balance: 5678.90, bankName: "Chase Bank", logoText: "BRUMAL", logoAbbreviation: "BRU", logoBackgroundColor: Color(hex: "2C3A4F")),
        AccountSummaryItemData(accountType: "Credit Card", balance: 123.45, bankName: "Capital One", logoText: "CREDIT CARD", logoAbbreviation: "CC", logoBackgroundColor: Color(hex: "1F2A3C"))
    ]

    let transactionItems: [TransactionSummaryItemData] = [
        TransactionSummaryItemData(merchantName: "Trader Joe's", category: "Grocery", amount: -56.78),
        TransactionSummaryItemData(merchantName: "Pizza Palace", category: "Dining", amount: -23.45),
        TransactionSummaryItemData(merchantName: "Amazon", category: "Shopping", amount: -99.50) // Added one more
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Spacer() // To help center the title
                Text("Finance Tracker")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(textColor)
                Spacer()
                Button(action: {
                    print("Settings tapped")
                    // Action for settings
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22))
                        .foregroundColor(textColor)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(screenBackgroundColor) // Match screen background

            // Segmented Control
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(FinanceScreenSegment.allCases, id: \.self) { segment in
                        Button(action: {
                            selectedSegment = segment
                        }) {
                            VStack(spacing: 8) {
                                Text(segment.rawValue)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedSegment == segment ? textColor : unselectedSegmentColor)
                                
                                if selectedSegment == segment {
                                    Rectangle()
                                        .frame(height: 2.5)
                                        .foregroundColor(segmentIndicatorColor)
                                        .padding(.horizontal, -4) // Extend indicator slightly if text padding is tight
                                } else {
                                    Rectangle()
                                        .frame(height: 2.5)
                                        .foregroundColor(.clear)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal) // Horizontal padding for the scrollable content
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(screenBackgroundColor)


            // Content based on selected segment
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    if selectedSegment == .overview {
                        OverviewContentView(accountItems: accountItems, transactionItems: transactionItems, textColor: textColor, subtitleColor: subtitleColor)
                    } else if selectedSegment == .transactions {
                        Text("Transactions Content Placeholder")
                            .foregroundColor(textColor).padding()
                    } else if selectedSegment == .budgets {
                        Text("Budgets Content Placeholder")
                            .foregroundColor(textColor).padding()
                    } else if selectedSegment == .investments {
                        Text("Investments Content Placeholder")
                            .foregroundColor(textColor).padding()
                    }
                }
                .padding(.top, 10)
            }
        }
        .background(screenBackgroundColor.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

// MARK: - Overview Content View
struct OverviewContentView: View {
    let accountItems: [AccountSummaryItemData]
    let transactionItems: [TransactionSummaryItemData]
    let textColor: Color
    let subtitleColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            // Account Summary Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Account Summary")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.horizontal)

                ForEach(accountItems) { item in
                    AccountSummaryRowView(item: item, textColor: textColor, subtitleColor: subtitleColor)
                }
            }

            // Recent Transactions Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Recent Transactions")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.horizontal)

                ForEach(transactionItems) { item in
                    TransactionSummaryRowView(item: item, textColor: textColor, subtitleColor: subtitleColor)
                        .padding(.horizontal) // Apply horizontal padding to individual rows
                }
            }
        }
    }
}


// MARK: - Reusable Row Views
struct AccountSummaryRowView: View {
    let item: AccountSummaryItemData
    let textColor: Color
    let subtitleColor: Color

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.accountType)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                Text(String(format: "$%.2f", item.balance))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(textColor)
                Text(item.bankName)
                    .font(.system(size: 14))
                    .foregroundColor(subtitleColor)
            }
            Spacer()
            BankLogoView(text: item.logoText, abbreviation: item.logoAbbreviation, backgroundColor: item.logoBackgroundColor)
        }
        .padding(.horizontal) // Padding for the entire row
    }
}

struct BankLogoView: View {
    let text: String
    let abbreviation: String // For a more compact display if needed
    let backgroundColor: Color
    
    // Determine if text is too long for nice single line display
    private var useAbbreviation: Bool {
        text.count > 9 // Heuristic, e.g. "CREDIT CARD" vs "BUAIBANK"
    }

    var body: some View {
        ZStack {
            backgroundColor
            // Attempt to make text fit, could be more sophisticated
            Text(useAbbreviation ? abbreviation : text.uppercased())
                .font(.system(size: useAbbreviation || text == "CREDIT CARD" ? 9 : 10, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .padding(4) // Padding inside the logo box
        }
        .frame(width: 80, height: 50)
        .cornerRadius(8)
    }
}


struct TransactionSummaryRowView: View {
    let item: TransactionSummaryItemData
    let textColor: Color
    let subtitleColor: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.merchantName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                Text(item.category)
                    .font(.system(size: 13))
                    .foregroundColor(subtitleColor)
            }
            Spacer()
            Text(String(format: "$%.2f", item.amount))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textColor)
        }
        // .padding(.vertical, 8) // Optional vertical padding for rows if not covered by section spacing
    }
}


// MARK: - Preview
struct FinanceTrackerScreenView_Previews: PreviewProvider {
    static var previews: some View {
        FinanceTrackerScreenView()
    }
}