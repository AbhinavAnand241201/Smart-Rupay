//
//  NetworkService.swift
//  trial-1235
//
//  Created by AI Assistant on 07/06/25.
//
//  FINAL CORRECTED VERSION
//

import Foundation
import SwiftUI // Required for Color

// MARK: - Network Error Enum
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(String)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The server URL was invalid."
        case .noData:
            return "Did not receive any data from the server."
        case .decodingError(let error):
            // Provide more specific decoding errors for debugging
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    return "Failed to decode: Missing key '\(key.stringValue)' in response. \(context.debugDescription)"
                case .typeMismatch(_, let context):
                    return "Failed to decode: Type mismatch. \(context.debugDescription)"
                case .valueNotFound(_, let context):
                    return "Failed to decode: Value not found. \(context.debugDescription)"
                case .dataCorrupted(let context):
                    return "Failed to decode: Data is corrupted. \(context.debugDescription)"
                @unknown default:
                    return "An unknown decoding error occurred."
                }
            }
            return "Failed to decode the server response."
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}


// MARK: - Network Service Class
class NetworkService {
    static let shared = NetworkService()
    // For local testing, use http://localhost:3000. For production, use your deployed server URL.
    private let baseURL = "http://localhost:3000"
    
    private init() {}
    
    // This struct matches the request body your server expects.
    private struct PlanRequest: Encodable {
        let monthlyIncome: Double
        let monthlyExpenses: Double
        let financialGoals: String
    }
    
    // This function is now clean, simple, and relies on Codable.
    func generateFinancialPlan(monthlyIncome: Double, monthlyExpenses: Double, financialGoals: String) async throws -> FinancialPlan {
        let endpoint = "\(baseURL)/api/generate-plan"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let requestBody = PlanRequest(
            monthlyIncome: monthlyIncome,
            monthlyExpenses: monthlyExpenses,
            financialGoals: financialGoals
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Use JSONEncoder with Codable for type-safe encoding.
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NetworkError.serverError("Status code: \((response as? HTTPURLResponse)?.statusCode ?? 500), message: \(errorMessage)")
        }
        
        // Use JSONDecoder with Codable for safe and automatic decoding.
        // No more manual parsing needed.
        do {
            return try JSONDecoder().decode(FinancialPlan.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
