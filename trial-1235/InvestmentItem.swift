
// In the file containing InvestmentsScreenView

import SwiftUI
import Charts

// MARK: - Data Models (with added data for charts)
struct InvestmentItem: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let detail: String // e.g., "10 Shares" or "Monthly SIP: ₹5,000"
    let currentValue: Double
    let changeAmount: Double
    var changePercentage: Double { (changeAmount / (currentValue - changeAmount)) * 100 }
    var isPositive: Bool { changeAmount >= 0 }
    
    // Data for the mini sparkline chart
    let priceHistory: [Double]
}

enum InvestmentSegment: String, CaseIterable, Identifiable {
    case stocks = "Stocks"
    case sips = "SIPs"
    var id: String { self.rawValue }
}

// MARK: - Main Investments View
struct InvestmentsScreenView: View {
    @State private var selectedSegment: InvestmentSegment = .stocks
    
    // MARK: - Mock Data
    // Richer mock data for a more impressive demo
    let stockItems: [InvestmentItem] = [
        .init(symbol: "RELIANCE", name: "Reliance Industries", detail: "15 Shares", currentValue: 43500, changeAmount: 750.55, priceHistory: [20, 22, 21, 25, 28, 27, 30]),
        .init(symbol: "TCS", name: "Tata Consultancy", detail: "25 Shares", currentValue: 95000, changeAmount: -1200.00, priceHistory: [35, 33, 34, 32, 30, 31, 29]),
        .init(symbol: "PAYTM", name: "Paytm (One97)", detail: "50 Shares", currentValue: 20000, changeAmount: 250.75, priceHistory: [15, 12, 14, 16, 18, 15, 17]),
        .init(symbol: "ZOMATO", name: "Zomato Ltd.", detail: "100 Shares", currentValue: 18500, changeAmount: 950.20, priceHistory: [8, 9, 11, 10, 13, 15, 17])
    ]
    
    let sipItems: [InvestmentItem] = [
        .init(symbol: "PARAG", name: "Parag Parikh Flexi Cap", detail: "SIP: ₹10,000", currentValue: 125000, changeAmount: 1800.00, priceHistory: [22, 24, 23, 25, 26, 28, 29]),
        .init(symbol: "NIF50", name: "UTI Nifty 50 Index", detail: "SIP: ₹5,000", currentValue: 85000, changeAmount: 950.00, priceHistory: [18, 19, 18, 20, 22, 21, 23])
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.App.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // A new "hero" card for the portfolio overview
                        PortfolioHeaderCard(
                            totalValue: 263500.00,
                            totalChange: 1751.50
                        )
                        
                        // A modern, custom "pill-style" segmented control
                        PillSegmentedControl(selection: $selectedSegment)
                        
                        // The list of investment cards
                        VStack(spacing: 16) {
                            ForEach(selectedSegment == .stocks ? stockItems : sipItems) { item in
                                InvestmentRowView(item: item)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("My Investments")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Portfolio Header Card
struct PortfolioHeaderCard: View {
    let totalValue: Double
    let totalChange: Double
    var isPositive: Bool { totalChange >= 0 }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Total Portfolio Value")
                .font(.headline)
                .foregroundColor(Color.App.textSecondary)
            
            Text("₹\(totalValue, specifier: "%.2f")")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(Color.App.textPrimary)
            
            Text("\(isPositive ? "+" : "-") ₹\(abs(totalChange), specifier: "%.2f") Today")
                .font(.title3.weight(.semibold))
                .foregroundColor(isPositive ? Color.App.accentGreen : Color.App.accentPink)
        }
        .padding(25)
        .frame(maxWidth: .infinity)
        .background(Color.App.card)
        .cornerRadius(30)
        .padding(.horizontal)
    }
}

// MARK: - Custom Segmented Control
struct PillSegmentedControl: View {
    @Binding var selection: InvestmentSegment
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(InvestmentSegment.allCases) { segment in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selection = segment
                    }
                }) {
                    Text(segment.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if selection == segment {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.App.card)
                                    .matchedGeometryEffect(id: "selection", in: namespace)
                            }
                        }
                        .foregroundColor(selection == segment ? Color.App.textPrimary : Color.App.textSecondary)
                }
            }
        }
        .padding(6)
        .background(Color.App.background)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.App.card, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}


// MARK: - Redesigned Investment Row with Chart
struct InvestmentRowView: View {
    let item: InvestmentItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon with a consistent color derived from the stock symbol
            Text(String(item.symbol.prefix(1)))
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color(hue: item.symbol.hue, saturation: 0.8, brightness: 0.8))
                .cornerRadius(16)

            VStack(alignment: .leading) {
                Text(item.symbol)
                    .font(.headline.bold())
                    .foregroundColor(Color.App.textPrimary)
                Text(item.detail)
                    .font(.caption)
                    .foregroundColor(Color.App.textSecondary)
            }
            
            Spacer()
            
            // Mini sparkline chart for visual appeal
            LineChartView(data: item.priceHistory, lineColor: item.isPositive ? Color.App.accentGreen : Color.App.accentPink)
                .frame(width: 80, height: 40)
            
            VStack(alignment: .trailing) {
                Text("₹\(item.currentValue, specifier: "%.2f")")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(Color.App.textPrimary)
                Text("\(item.isPositive ? "+" : "-")\(abs(item.changePercentage), specifier: "%.2f")%")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(item.isPositive ? Color.App.accentGreen : Color.App.accentPink)
            }
        }
        .padding()
        .background(Color.App.card)
        .cornerRadius(20)
    }
}

// MARK: - Sparkline Chart View
struct LineChartView: View {
    let data: [Double]
    let lineColor: Color

    private var path: Path {
        if data.count < 2 { return Path() }
        var path = Path()
        let (min, max) = (data.min() ?? 0, data.max() ?? 0)
        
        let points = data.enumerated().map { (index, value) -> CGPoint in
            let x = Double(index) / Double(data.count - 1)
            let y = (value - min) / (max - min)
            return CGPoint(x: x, y: 1 - y)
        }
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        return path
    }
    
    var body: some View {
        path.strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .foregroundColor(lineColor)
            .shadow(color: lineColor, radius: 3) // Add a subtle glow to the line
    }
}

// MARK: - String Extension for Color Hashing
// A simple helper to generate a deterministic color from a string
extension String {
    var hue: Double {
        var hash = 0
        for char in self.unicodeScalars {
            hash = Int(char.value) &+ (hash << 5) &- hash
        }
        return Double(abs(hash % 360)) / 360.0
    }
}

// MARK: - Preview
struct InvestmentsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        InvestmentsScreenView()
            .preferredColorScheme(.dark)
    }
}
