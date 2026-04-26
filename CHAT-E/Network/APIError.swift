import Foundation

/// Custom API errors for network layer
enum APIError: Error, LocalizedError {
    
    // MARK: - Error Cases
    
    /// Invalid URL
    case invalidURL
    
    /// No API key configured
    case missingAPIKey
    
    /// Network error (underlying error)
    case networkError(Error)
    
    /// Invalid response from server
    case invalidResponse
    
    /// HTTP error with status code
    case httpError(statusCode: Int, data: Data?)
    
    /// Decoding error
    case decodingError(Error)
    
    /// Encoding error
    case encodingError(Error)
    
    /// Server returned empty response
    case emptyResponse
    
    /// Request timeout
    case timeout
    
    /// No internet connection
    case noInternetConnection
    
    // MARK: - Error Description
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .missingAPIKey:
            return "API key is not configured. Please add your API key in Configuration.plist."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, _):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .emptyResponse:
            return "Server returned empty response"
        case .timeout:
            return "Request timed out"
        case .noInternetConnection:
            return "No internet connection"
        }
    }
    
    // MARK: - User Info
    
    var userInfo: [String: Any]? {
        switch self {
        case .httpError(_, let data):
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return ["data": json]
            }
            return nil
        default:
            return nil
        }
    }
}