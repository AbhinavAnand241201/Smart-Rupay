import Foundation

// MARK: - Network Error Enum
enum NetworkError: Error {
    case invalidURL
    case serverError(String)
    case decodingError(Error)
    case encodingError(Error)
    case noToken
}

// MARK: - Network Service Class
class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:3000/api"

    // This token must be set after the user logs in and saved securely.
    var authToken: String?

    // Private helper to create and configure requests
    private func createRequest(with endpoint: String, method: String, body: (any Encodable)? = nil) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        return request
    }
    
    // Private helper to execute the network request
    private func executeRequest<T: Decodable>(for request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NetworkError.serverError("Server responded with status code \((response as? HTTPURLResponse)?.statusCode ?? 500). Message: \(errorMessage)")
        }
        
        do {
            // The JSONDecoder will now correctly decode the expected type T
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    // MARK: - Authentication API
    
    private struct AuthRequest: Encodable {
        let email: String
        let password: String
    }
    
    private struct AuthResponse: Decodable {
        let token: String
    }

    func login(email: String, password: String) async throws {
        let authRequest = AuthRequest(email: email, password: password)
        let request = try createRequest(with: "/auth/login", method: "POST", body: authRequest)
        let response: AuthResponse = try await executeRequest(for: request)
        
        // Save the token upon successful login
        self.authToken = response.token
    }

    // MARK: - Financial Goals API
    
    func fetchGoals() async throws -> [FinancialGoal] {
        let request = try createRequest(with: "/goals", method: "GET")
        // FIXED: The generic executeRequest function handles decoding an array correctly.
        return try await executeRequest(for: request)
    }

    // A Codable struct for the request body is the correct, type-safe approach.
    private struct GoalRequestBody: Encodable {
        let name: String
        let targetAmount: Double
        let currentAmount: Double
        let deadline: String?
    }

    func addGoal(name: String, targetAmount: Double, currentAmount: Double, deadline: Date?) async throws -> FinancialGoal {
        let body = GoalRequestBody(
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline?.ISO8601Format()
        )
        let request = try createRequest(with: "/goals", method: "POST", body: body)
        // FIXED: The generic executeRequest function handles decoding a single object correctly.
        return try await executeRequest(for: request)
    }

    func deleteGoal(id: String) async throws {
        let request = try createRequest(with: "/goals/\(id)", method: "DELETE")
        // For delete, we don't need to decode a response body, just ensure it doesn't throw an error.
        _ = try await URLSession.shared.data(for: request)
    }
    
    private struct ContributionRequestBody: Encodable {
        let amount: Double
    }

    func contributeToGoal(id: String, amount: Double) async throws -> FinancialGoal {
        let body = ContributionRequestBody(amount: amount)
        let request = try createRequest(with: "/goals/\(id)/contribute", method: "PATCH", body: body)
        return try await executeRequest(for: request)
    }

    // MARK: - AI Planner API
    private struct PlanRequestBody: Encodable {
        let monthlyIncome: Double
        let monthlyExpenses: Double
        let financialGoals: String
    }
    
    func generateFinancialPlan(monthlyIncome: Double, monthlyExpenses: Double, financialGoals: String) async throws -> FinancialPlan {
        let body = PlanRequestBody(monthlyIncome: monthlyIncome, monthlyExpenses: monthlyExpenses, financialGoals: financialGoals)
        // FIXED: The endpoint should be added to the base URL, not a full URL itself.
        let request = try createRequest(with: "/generate-plan", method: "POST", body: body)
        return try await executeRequest(for: request)
    }
}
