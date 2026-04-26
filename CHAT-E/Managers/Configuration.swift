import Foundation

/// Manages application configuration settings
final class Configuration {
    
    // MARK: - Singleton
    
    static let shared = Configuration()
    
    // MARK: - Properties
    
    /// The API base URL (e.g., "https://api.openai.com")
    let apiBaseURL: String
    
    /// The default model to use (e.g., "gpt-4", "gpt-3.5-turbo")
    let defaultModel: String
    
    /// Maximum tokens allowed per request
    let maxTokens: Int
    
    /// Default temperature for API calls
    let temperature: Double
    
    /// Whether streaming is enabled
    let streamEnabled: Bool
    
    /// API timeout in seconds
    let timeoutSeconds: TimeInterval
    
    // MARK: - Initialization
    
    private init() {
        
        // Try to load from Configuration.plist first
        let configPath = Bundle.main.path(forResource: "Configuration", ofType: "plist")
        
        if let path = configPath,
           let config = NSDictionary(contentsOfFile: path) as? [String: Any] {
            
            // Load from Configuration.plist
            self.apiBaseURL = config["APIBaseURL"] as? String ?? "https://api.openai.com"
            self.defaultModel = config["DefaultModel"] as? String ?? "gpt-3.5-turbo"
            self.maxTokens = config["MaxTokens"] as? Int ?? 1000
            self.temperature = config["Temperature"] as? Double ?? 0.7
            self.streamEnabled = config["StreamEnabled"] as? Bool ?? false
            self.timeoutSeconds = config["TimeoutSeconds"] as? TimeInterval ?? 60.0
            
        } else {
            
            // Default values
            self.apiBaseURL = "https://api.openai.com"
            self.defaultModel = "gpt-3.5-turbo"
            self.maxTokens = 1000
            self.temperature = 0.7
            self.streamEnabled = false
            self.timeoutSeconds = 60.0
        }
    }
    
    // MARK: - Configuration Validation
    
    /// Validate that the configuration is complete
    func validate() -> Bool {
        return !apiBaseURL.isEmpty && !defaultModel.isEmpty
    }
}