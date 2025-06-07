//
//  OracleResponse.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 07/06/25.
//


//
//  OracleResponseView.swift
//  trial-1235
//
//  Created by Gemini AI on 07/06/25.
//

import SwiftUI

// MARK: - Data Models for the Response View
struct OracleResponse {
    let summary: String
    let actionSteps: [ActionStep]
    let investmentIdeas: [InvestmentIdea]
}

struct ActionStep: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
    let iconColor: Color
}

struct InvestmentIdea: Identifiable {
    let id = UUID()
    let type: String // e.g., "Stocks", "Mutual Funds"
    let description: String
    let ideas: [String] // e.g., ["Index Fund (S&P 500)", "Blue-Chip Tech Stocks"]
}

// MARK: - Main Response View
struct OracleResponseView: View {
    let response: OracleResponse
    let onDismiss: () -> Void

    // UI Colors
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")

    var body: some View {
        ZStack {
            screenBackgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // MARK: - Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Financial Blueprint")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(mainTextColor)
                            Text("A personalized plan to help you achieve your goals.")
                                .foregroundColor(secondaryTextColor)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    // MARK: - Summary Card
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "text.quote")
                                .font(.title2)
                                .foregroundColor(accentColorTeal)
                            Text("Oracle's Summary")
                                .font(.headline)
                                .foregroundColor(mainTextColor)
                        }
                        Text(response.summary)
                            .foregroundColor(secondaryTextColor)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // MARK: - Action Steps
                    VStack(alignment: .leading) {
                        Text("Immediate Action Steps")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(mainTextColor)
                            .padding(.horizontal)

                        ForEach(response.actionSteps) { step in
                            ActionStepCard(step: step)
                                .padding(.horizontal)
                        }
                    }

                    // MARK: - Investment Ideas
                    VStack(alignment: .leading) {
                        Text("Investment Pathways")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(mainTextColor)
                            .padding(.horizontal)
                        
                        ForEach(response.investmentIdeas) { idea in
                            InvestmentIdeaCard(idea: idea)
                                .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - Disclaimer
                    Text("Disclaimer: This is illustrative AI-generated guidance and not professional financial advice. Consult with a certified financial advisor before making any investment decisions.")
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(cardBackgroundColor)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.vertical, 20)

                }
                .padding(.vertical)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}


// MARK: - Subviews for OracleResponseView
struct ActionStepCard: View {
    let step: ActionStep
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: step.iconName)
                .font(.title)
                .foregroundColor(step.iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.headline)
                    .foregroundColor(Color.white)
                Text(step.description)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "A0A0A0"))
            }
        }
        .padding()
        .background(Color(red: 0.15, green: 0.16, blue: 0.18))
        .cornerRadius(12)
        .padding(.vertical, 5)
    }
}

struct InvestmentIdeaCard: View {
    let idea: InvestmentIdea
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(idea.type)
                .font(.headline)
                .foregroundColor(Color(hex: "3AD7D5"))
            
            Text(idea.description)
                .font(.caption)
                .foregroundColor(Color(hex: "A0A0A0"))
                .padding(.bottom, 10)
            
            ForEach(idea.ideas, id: \.self) { text in
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundColor(Color.gray)
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(Color.white)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(red: 0.15, green: 0.16, blue: 0.18))
        .cornerRadius(12)
        .padding(.vertical, 5)
    }
}