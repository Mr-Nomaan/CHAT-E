import Foundation

/// Represents a single chat message in the conversation
struct Message: Codable {
    
    // MARK: - Properties
    
    /// Unique identifier for the message
    let id: String
    
    /// The text content of the message
    let content: String
    
    /// Whether this message was sent by the user or received from the AI
    let isUser: Bool
    
    /// Timestamp when the message was created
    let timestamp: Date
    
    /// The agent that generated this message (nil for user messages)
    let agentType: AgentType?
    
    // MARK: - Initialization
    
    init(id: String = UUID().uuidString,
         content: String,
         isUser: Bool,
         timestamp: Date = Date(),
         agentType: AgentType? = nil) {
        
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.agentType = agentType
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case isUser
        case timestamp
        case agentType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        isUser = try container.decode(Bool.self, forKey: .isUser)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        agentType = try container.decodeIfPresent(AgentType.self, forKey: .agentType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(isUser, forKey: .isUser)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(agentType, forKey: .agentType)
    }
}