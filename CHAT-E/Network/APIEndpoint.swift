import Foundation

/// Defines the API endpoints for the multi-agent system
enum APIEndpoint {
    
    // MARK: - OpenAI Endpoints
    
    /// Chat completions endpoint
    case chatCompletions
    
    /// Base URL for the API
    var baseURL: String {
        switch self {
        case .chatCompletions:
            return Configuration.shared.apiBaseURL
        }
    }
    
    /// Full URL path
    var path: String {
        switch self {
        case .chatCompletions:
            return "/v1/chat/completions"
        }
    }
    
    /// HTTP method
    var method: String {
        switch self {
        case .chatCompletions:
            return "POST"
        }
    }
    
    /// Content type for headers
    var contentType: String {
        switch self {
        case .chatCompletions:
            return "application/json"
        }
    }
    
    /// Build the complete URL
    var url: URL? {
        return URL(string: baseURL + path)
    }
    
    // MARK: - Request Builder
    
    /// Build URLRequest with common configuration
    func buildRequest(with body: Data?, apiKey: String) -> URLRequest? {
        guard let url = self.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.timeoutInterval = 60.0
        
        // Set headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}