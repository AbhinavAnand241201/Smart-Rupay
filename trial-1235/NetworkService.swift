import Foundation

enum NetworkError: Error {
    case invalidURL
    case serverError(String)
    case decodingError(Error)
    case encodingError(Error)
}

struct AuthRequest: Encodable { let email, password: String }
struct GoalRequestBody: Encodable { let name: String; let targetAmount, currentAmount: Double; let deadline: Date? }
struct ContributionRequestBody: Encodable { let amount: Double }
struct PlanRequestBody: Encodable { let monthlyIncome, monthlyExpenses: Double; let financialGoals: String }
struct PlanIdRequest: Encodable { let planId: String }

struct AuthResponse: Decodable { let token: String }
struct FulfillmentResponse: Decodable { let message: String; let subscribedUntil: Date }
struct PaymentIntentResponse: Decodable { let clientSecret: String }

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:3000/api"
    var authToken: String?

    private func createRequest(with endpoint: String, method: String, body: (any Encodable)? = nil) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try? encoder.encode(body)
        }
        return request
    }
    
    private func executeRequest<T: Decodable>(for request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Invalid Server Response")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
    
    func login(credentials: AuthRequest) async throws -> AuthResponse {
        let request = try createRequest(with: "/auth/login", method: "POST", body: credentials)
        let response: AuthResponse = try await executeRequest(for: request)
        self.authToken = response.token
        return response
    }
    
    func fetchGoals() async throws -> [FinancialGoal] {
        let request = try createRequest(with: "/goals", method: "GET")
        return try await executeRequest(for: request)
    }

    func addGoal(body: GoalRequestBody) async throws -> FinancialGoal {
        let request = try createRequest(with: "/goals", method: "POST", body: body)
        return try await executeRequest(for: request)
    }
    
    func deleteGoal(id: String) async throws {
        let request = try createRequest(with: "/goals/\(id)", method: "DELETE")
        _ = try await URLSession.shared.data(for: request)
    }

    func contributeToGoal(id: String, body: ContributionRequestBody) async throws -> FinancialGoal {
        let request = try createRequest(with: "/goals/\(id)/contribute", method: "PATCH", body: body)
        return try await executeRequest(for: request)
    }
    
    func generateFinancialPlan(body: PlanRequestBody) async throws -> FinancialPlan {
        let request = try createRequest(with: "/generate-plan", method: "POST", body: body)
        return try await executeRequest(for: request)
    }
    
    func createPaymentIntent(planId: String) async throws -> PaymentIntentResponse {
        let requestBody = PlanIdRequest(planId: planId)
        let request = try createRequest(with: "/subscriptions/create-payment-intent", method: "POST", body: requestBody)
        return try await executeRequest(for: request)
    }

    func fulfillSubscription(planId: String) async throws -> FulfillmentResponse {
        let requestBody = PlanIdRequest(planId: planId)
        let request = try createRequest(with: "/subscriptions/fulfill", method: "POST", body: requestBody)
        return try await executeRequest(for: request)
    }
}
