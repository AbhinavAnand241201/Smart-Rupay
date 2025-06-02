//
//  InvestmentItem.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 02/06/25.
//


import SwiftUI


// MARK: - Data Models for Investments Screen
struct InvestmentItem: Identifiable {
    let id = UUID()
    let iconName: String // SF Symbol name for the placeholder logo
    let iconBackgroundColor: Color
    let companyName: String
    let sharesDetail: String // e.g., "10 Shares"
    let amountChange: Double
    var isPositive: Bool { amountChange >= 0 }
}

enum InvestmentSegment: String, CaseIterable {
    case stocks = "Stocks"
    case sips = "SIPs"
}

// MARK: - Main Investments Screen View
struct InvestmentsScreenView: View {
    @State private var selectedSegment: InvestmentSegment = .stocks

    // Sample Data for Stocks
    let stockItems: [InvestmentItem] = [
        InvestmentItem(iconName: "chart.bar.fill", iconBackgroundColor: Color(hex: "2A4D4E"), companyName: "TechCorp", sharesDetail: "10 Shares", amountChange: 250.00),
        InvestmentItem(iconName: "leaf.fill", iconBackgroundColor: Color(hex: "385E4F"), companyName: "GlobalEnergy", sharesDetail: "5 Shares", amountChange: -100.00),
        InvestmentItem(iconName: "heart.fill", iconBackgroundColor: Color(hex: "3C6B6B"), companyName: "HealthSolutions", sharesDetail: "20 Shares", amountChange: 50.00),
        InvestmentItem(iconName: "cart.fill", iconBackgroundColor: Color(hex: "2F5656"), companyName: "RetailGiant", sharesDetail: "15 Shares", amountChange: 150.00)
    ]
    
    // Placeholder for SIPs data
    let sipItems: [InvestmentItem] = [] // Populate this if SIPs data is available

    // Colors
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let portfolioValueTextColor = Color(hex: "A0A0A0")
    let positiveChangeColor = Color(hex: "4CAF50") // A distinct green
    let negativeChangeColor = Color.white // As per image, could be red too
    let segmentIndicatorColor = Color.white
    let segmentTextColor = Color.gray
    let selectedSegmentTextColor = Color.white

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: {
                    // Action for back button
                    print("Back button tapped")
                    // Add your navigation logic here
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Investments")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.left").opacity(0) // Placeholder for balance
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(screenBackgroundColor) // Keep nav bar part of the screen bg

            ScrollView {
                VStack(spacing: 20) {
                    // Profile Section
                    VStack(spacing: 8) {
                        Image("ab1") // Assuming "ab1" is in your assets, placeholder from your files
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            .padding(.top, 10)

                        Text("Ethan Carter")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        VStack(spacing: 2) {
                            Text("Portfolio Value")
                                .font(.system(size: 14))
                                .foregroundColor(portfolioValueTextColor)
                            Text("$12,345.67")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 15)

                    // Segmented Control (Stocks/SIPs)
                    HStack(spacing: 0) {
                        ForEach(InvestmentSegment.allCases, id: \.self) { segment in
                            Button(action: {
                                selectedSegment = segment
                            }) {
                                VStack(spacing: 8) {
                                    Text(segment.rawValue)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(selectedSegment == segment ? selectedSegmentTextColor : segmentTextColor)
                                        .frame(maxWidth: .infinity)
                                    
                                    if selectedSegment == segment {
                                        Rectangle()
                                            .frame(height: 2.5)
                                            .foregroundColor(segmentIndicatorColor)
                                    } else {
                                        Rectangle()
                                            .frame(height: 2.5)
                                            .foregroundColor(.clear) // Keep space consistent
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20) // Give some horizontal padding to the control
                    .padding(.bottom, 15)


                    // Content based on selected segment
                    if selectedSegment == .stocks {
                        if stockItems.isEmpty {
                             Text("No stocks to display.")
                                .foregroundColor(portfolioValueTextColor)
                                .padding(.top, 50)
                        } else {
                            LazyVStack(spacing: 15) {
                                ForEach(stockItems) { item in
                                    InvestmentRowView(item: item, 
                                                      positiveColor: positiveChangeColor,
                                                      negativeColor: negativeChangeColor)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else { // SIPs
                        if sipItems.isEmpty {
                            Text("No SIPs to display.")
                                .foregroundColor(portfolioValueTextColor)
                                .padding(.top, 50)
                        } else {
                            LazyVStack(spacing: 15) {
                                ForEach(sipItems) { item in
                                     InvestmentRowView(item: item,
                                                       positiveColor: positiveChangeColor,
                                                       negativeColor: negativeChangeColor)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    Spacer(minLength: 20) // Space at the bottom of scroll content
                }
            }
        }
        .background(screenBackgroundColor.ignoresSafeArea())
    }
}

// MARK: - Investment Row View
struct InvestmentRowView: View {
    let item: InvestmentItem
    let positiveColor: Color
    let negativeColor: Color
    let sharesTextColor = Color(hex: "A0A0A0")


    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: item.iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(item.iconBackgroundColor)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.companyName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Text(item.sharesDetail)
                    .font(.system(size: 13))
                    .foregroundColor(sharesTextColor)
            }

            Spacer()

            Text(String(format: "%@$%.2f", item.isPositive ? "+" : "", item.amountChange))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(item.isPositive ? positiveColor : negativeColor)
        }
        .padding(12) // Add some padding around the row content
        .background(Color(red: 0.12, green: 0.13, blue: 0.15)) // Card-like background for rows
        .cornerRadius(12)
    }
}


// MARK: - Tab Bar Definitions (Adapted from AppCustomTabBar)

// Define the tabs including "Investments"
enum MainAppScreenTab: String, CaseIterable {
    case home = "house.fill"
    case aiAdvisor = "brain.head.profile" // Or "bubble.left.and.bubble.right.fill"
    case transactions = "list.bullet"
    case investments = "chart.bar.xaxis" // Or "chart.pie.fill" / "creditcard.fill"
    case profile = "person.fill"

    var title: String {
        switch self {
        case .home: return "Home"
        case .aiAdvisor: return "AI Advisor"
        case .transactions: return "Transactions"
        case .investments: return "Investments"
        case .profile: return "Profile"
        }
    }
}

// Reusable Custom Tab Bar
struct AppMainTabBarView: View {
    @Binding var selectedTab: MainAppScreenTab
    private let tabBarHeight: CGFloat = 65
    private let tabIconSize: CGFloat = 22
    private let tabTextColor = Color(hex: "8E8E93") // Standard iOS unselected gray
    private let selectedTabColor = Color.white
    private let tabBarBackgroundColor = Color(red: 0.12, green: 0.13, blue: 0.15)


    var body: some View {
        HStack {
            ForEach(MainAppScreenTab.allCases, id: \.rawValue) { tab in
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: tab.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: tabIconSize, height: tabIconSize)
                        .foregroundColor(selectedTab == tab ? selectedTabColor : tabTextColor)

                    Text(tab.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(selectedTab == tab ? selectedTabColor : tabTextColor)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTab = tab
                }
                Spacer()
            }
        }
        .frame(height: tabBarHeight)
        .padding(.bottom, UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0 > 0 ? 10 : 5) // Adjust padding for home indicator
        .background(tabBarBackgroundColor)
        // .cornerRadius(16, corners: [.topLeft, .topRight]) // Optional: if you want rounded top corners for the tab bar
    }
}

// MARK: - Main Application View with TabBar
struct MainAppInvestmentView: View {
    @State private var selectedTab: MainAppScreenTab = .investments // Default to investments

    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)

    init() {
        UITabBar.appearance().isHidden = true // Hide default tab bar
    }

    var body: some View {
        ZStack {
            screenBackgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Content based on selected tab
                switch selectedTab {
                case .home:
                    Text("Home Screen") // Replace with your actual Home Screen View
                        .foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
                case .aiAdvisor:
                    Text("AI Advisor Screen") // Replace with your AI Advisor Screen
                        .foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
                case .transactions:
                    Text("Transactions Screen") // Replace with Transactions Screen
                        .foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
                case .investments:
                    InvestmentsScreenView() // Our new screen
                case .profile:
                    Text("Profile Screen") // Replace with Profile Screen
                        .foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Custom Tab Bar at the bottom
                AppMainTabBarView(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
        .preferredColorScheme(.dark)
    }
}


// MARK: - Preview
struct InvestmentsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview the full tabbed interface with Investments selected
        MainAppInvestmentView()

        // Preview just the InvestmentsScreenView in isolation (optional)
        // InvestmentsScreenView()
        //    .preferredColorScheme(.dark)
        //    .background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea())
    }
}

// Helper for specific corner radius (if needed for tab bar)
/*
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
*/
