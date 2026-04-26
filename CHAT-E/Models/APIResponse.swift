import Foundation

// MARK: - OpenAI Chat Completions Response Model

/// Response model from OpenAI Chat Completions API
struct ChatCompletionResponse: Codable {
    
    /// Unique identifier for this chat completion
    let id: String
    
    /// The type of object (e.g., "chat.completion")
    let object: String
    
    /// Unix timestamp when the completion was created
    let created: Int
    
    /// The model used for the completion
    let model: String
    
    /// The list of completion choices
    let choices: [Choice]
    
    /// Usage statistics
    let usage: Usage?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case choices
        case usage
    }
}

/// Represents a single completion choice
struct Choice: Codable {
    
    /// Index of this choice
    let index: Int
    
    /// The message that was generated
    let message: ResponseMessage
    
    /// Reason the completion finished (e.g., "stop", "length")
    let finishReason: String?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case index
        case message
        case finishReason = "finish_reason"
    }
}

/// Message in the response
struct ResponseMessage: Codable {
    
    /// Role of the message sender
    let role: String
    
    /// Content of the message
    let content: String
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
    }
}

/// Usage statistics for the API call
struct Usage: Codable {
    
    /// Number of tokens in the prompt
    let promptTokens: Int
    
    /// Number of tokens in the completion
    let completionTokens: Int
    
    /// Total number of tokens used
    let totalTokens: Int
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Stream Response (for future streaming support)

/// Stream chunk for streaming responses
struct StreamChunk: Codable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let choices: [StreamChoice]?
}

/// Stream choice
struct StreamChoice: Codable {
    let index: Int?
    let delta: StreamDelta?
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index
        case delta
        case finishReason = "finish_reason"
    }
}

/// Stream delta (content delta)
struct StreamDelta: Codable {
    let role: String?
    let content: String?
}