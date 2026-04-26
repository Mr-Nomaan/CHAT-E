import Foundation

/// Network client for communicating with AI APIs
final class APIClient {
    
    // MARK: - Singleton
    
    static let shared = APIClient()
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Initialization
    
    private init() {
        // Configure session with default timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Configuration.shared.timeoutSeconds
        config.timeoutIntervalForResource = Configuration.shared.timeoutSeconds * 2
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    
    /// Send a message to the AI API and get a response
    /// - Parameters:
    ///   - message: The user's message content
    ///   - agentType: The selected agent type
    ///   - conversationHistory: Previous messages in the conversation
    ///   - completion: Callback with the result
    func sendMessage(_ message: String,
                     agentType: AgentType,
                     conversationHistory: [Message],
                     completion: @escaping (Result<String, APIError>) -> Void) {
        
        // Get API key from Keychain or Configuration
        guard let apiKey = getAPIKey() else {
            completion(.failure(.missingAPIKey))
            return
        }
        
        // Build messages array with system prompt and history
        let messages = buildMessages(for: agentType, currentMessage: message, history: conversationHistory)
        
        // Create request model
        let request = ChatCompletionRequest(
            model: Configuration.shared.defaultModel,
            messages: messages,
            maxTokens: Configuration.shared.maxTokens,
            temperature: Configuration.shared.temperature
        )
        
        // Make the API call
        sendRequest(to: .chatCompletions, apiKey: apiKey, body: request, completion: completion)
    }
    
    /// Send a streaming message (for future implementation)
    /// - Parameters:
    ///   - message: The user's message
    ///   - agentType: The selected agent type
    ///   - conversationHistory: Previous messages
    ///   - onChunk: Callback for each chunk received
    ///   - completion: Callback when complete or on error
    func sendStreamingMessage(_ message: String,
                            agentType: AgentType,
                            conversationHistory: [Message],
                            onChunk: @escaping (String) -> Void,
                            completion: @escaping (Result<String, APIError>) -> Void) {
        
        guard let apiKey = getAPIKey() else {
            completion(.failure(.missingAPIKey))
            return
        }
        
        let messages = buildMessages(for: agentType, currentMessage: message, history: conversationHistory)
        
        let request = ChatCompletionRequest(
            model: Configuration.shared.defaultModel,
            messages: messages,
            maxTokens: Configuration.shared.maxTokens,
            temperature: Configuration.shared.temperature,
            stream: true
        )
        
        sendStreamingRequest(to: .chatCompletions, apiKey: apiKey, body: request, onChunk: onChunk, completion: completion)
    }
    
    // MARK: - Private Methods
    
    /// Get API key from Keychain
    private func getAPIKey() -> String? {
        // First try Keychain
        if let keychainKey = KeychainManager.shared.getAPIKey() {
            return keychainKey
        }
        // Fallback: Check Configuration.plist (not recommended for production)
        return nil
    }
    
    /// Build messages array for API call
    private func buildMessages(for agentType: AgentType, currentMessage: String, history: [Message]) -> [ChatMessage] {
        
        var messages: [ChatMessage] = []
        
        // Add system prompt for the selected agent
        messages.append(.system(agentType.systemPrompt))
        
        // Add conversation history (limit to last N messages to manage token count)
        let maxHistoryCount = 20
        let recentHistory = Array(history.suffix(maxHistoryCount))
        
        for message in recentHistory {
            let role = message.isUser ? "user" : "assistant"
            messages.append(ChatMessage(role: role, content: message.content))
        }
        
        // Add current message
        messages.append(.user(currentMessage))
        
        return messages
    }
    
    /// Send a request to the API
    private func sendRequest<T: Encodable, R: Decodable>(to endpoint: APIEndpoint,
                                                         apiKey: String,
                                                         body: T,
                                                         completion: @escaping (Result<R, APIError>) -> Void) {
        
        // Encode the request body
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(body) else {
            completion(.failure(.encodingError(NSError(domain: "Encoding", code: -1))))
            return
        }
        
        // Build URLRequest
        guard var request = endpoint.buildRequest(with: bodyData, apiKey: apiKey) else {
            completion(.failure(.invalidURL))
            return
        }
        
        request.httpMethod = endpoint.method
        
        // Perform the request
        let task = session.dataTask(with: request) { data, response, error in
            
            // Handle network error
            if let error = error {
                let apiError: APIError
                if (error as NSError).code == NSURLErrorTimedOut {
                    apiError = .timeout
                } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    apiError = .noInternetConnection
                } else {
                    apiError = .networkError(error)
                }
                DispatchQueue.main.async {
                    completion(.failure(apiError))
                }
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(.httpError(statusCode: httpResponse.statusCode, data: data)))
                }
                return
            }
            
            // Check for data
            guard let data = data, !data.isEmpty else {
                DispatchQueue.main.async {
                    completion(.failure(.emptyResponse))
                }
                return
            }
            
            // Decode response
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(R.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
        
        task.resume()
    }
    
    /// Send a streaming request
    private func sendStreamingRequest<T: Encodable>(to endpoint: APIEndpoint,
                                                   apiKey: String,
                                                   body: T,
                                                   onChunk: @escaping (String) -> Void,
                                                   completion: @escaping (Result<String, APIError>) -> Void) {
        
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(body) else {
            completion(.failure(.encodingError(NSError(domain: "Encoding", code: -1))))
            return
        }
        
        guard var request = endpoint.buildRequest(with: bodyData, apiKey: apiKey) else {
            completion(.failure(.invalidURL))
            return
        }
        
        request.httpMethod = endpoint.method
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            guard let data = data, !data.isEmpty else {
                DispatchQueue.main.async {
                    completion(.failure(.emptyResponse))
                }
                return
            }
            
            // For streaming, parse each line as a chunk
            if let text = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    onChunk(text)
                    completion(.success(text))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - Convenience Methods

extension APIClient {
    
    /// Simple method to send a message and get a string response
    /// - Parameters:
    ///   - content: Message content
    ///   - agentType: Agent type
    ///   - completion: Callback with result
    func chat(content: String, agentType: AgentType, completion: @escaping (Result<String, APIError>) -> Void) {
        sendMessage(content, agentType: agentType, conversationHistory: [], completion: completion)
    }
}