import Foundation

// MARK: - OpenAI Chat Completions Request Model

/// Request model for OpenAI Chat Completions API
struct ChatCompletionRequest: Codable {
    
    /// The model to use (e.g., "gpt-4", "gpt-3.5-turbo")
    let model: String
    
    /// The messages to send to the API
    let messages: [ChatMessage]
    
    /// Maximum tokens to generate
    let maxTokens: Int?
    
    /// Temperature for sampling (0.0 to 2.0)
    let temperature: Double?
    
    /// Whether to stream the response
    let stream: Bool?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
        case temperature
        case stream
    }
    
    // MARK: - Initialization
    
    init(model: String,
         messages: [ChatMessage],
         maxTokens: Int? = 1000,
         temperature: Double? = 0.7,
         stream: Bool? = false) {
        
        self.model = model
        self.messages = messages
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.stream = stream
    }
}

/// Represents a single message in the chat conversation
struct ChatMessage: Codable {
    
    /// Role of the message sender ("system", "user", "assistant")
    let role: String
    
    /// Content of the message
    let content: String
    
    // MARK: - Initialization
    
    init(role: String, content: String) {
        self.role = role
        self.content = content
    }
    
    // MARK: - Factory Methods
    
    /// Create a system message
    static func system(_ content: String) -> ChatMessage {
        return ChatMessage(role: "system", content: content)
    }
    
    /// Create a user message
    static func user(_ content: String) -> ChatMessage {
        return ChatMessage(role: "user", content: content)
    }
    
    /// Create an assistant message
    static func assistant(_ content: String) -> ChatMessage {
        return ChatMessage(role: "assistant", content: content)
    }
}