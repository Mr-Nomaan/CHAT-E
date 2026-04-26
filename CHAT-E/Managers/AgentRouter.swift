import Foundation

/// Router logic for multi-agent system
/// Routes user queries to different AI agents based on selection
final class AgentRouter {
    
    // MARK: - Singleton
    
    static let shared = AgentRouter()
    
    // MARK: - Properties
    
    /// Currently selected agent type
    private(set) var currentAgent: AgentType = .general
    
    /// All available agents
    let availableAgents: [AgentType] = AgentType.allCases
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Agent Selection
    
    /// Set the current agent
    /// - Parameter agent: The agent type to set
    func selectAgent(_ agent: AgentType) {
        self.currentAgent = agent
    }
    
    /// Set agent by segment index (for segmented control)
    /// - Parameter index: The segment index (0-based)
    func selectAgent(at index: Int) {
        guard index >= 0 && index < availableAgents.count else { return }
        self.currentAgent = availableAgents[index]
    }
    
    // MARK: - Message Routing
    
    /// Route a user message to the appropriate agent
    /// - Parameter message: The user's message
    /// - Returns: The configured message with system prompt for the selected agent
    func routeMessage(_ message: String) -> RoutedMessage {
        let systemPrompt = currentAgent.systemPrompt
        return RoutedMessage(content: message, agentType: currentAgent, systemPrompt: systemPrompt)
    }
    
    /// Get the system prompt for the current agent
    /// - Returns: The system prompt string
    func getSystemPrompt() -> String {
        return currentAgent.systemPrompt
    }
    
    /// Get system prompt for a specific agent
    /// - Parameter agent: The agent type
    /// - Returns: The system prompt
    func getSystemPrompt(for agent: AgentType) -> String {
        return agent.systemPrompt
    }
    
    // MARK: - Agent Discovery
    
    /// Get all available agents
    /// - Returns: Array of agent types
    func getAvailableAgents() -> [AgentType] {
        return availableAgents
    }
    
    /// Check if an agent is available
    /// - Parameter agent: The agent type
    /// - Returns: True if available
    func isAgentAvailable(_ agent: AgentType) -> Bool {
        return availableAgents.contains(agent)
    }
    
    /// Get agent display name
    /// - Parameter agent: The agent type
    /// - Returns: Display name
    func getDisplayName(for agent: AgentType) -> String {
        return agent.displayName
    }
}

// MARK: - Routed Message

/// Represents a message with routing information
struct RoutedMessage {
    let content: String
    let agentType: AgentType
    let systemPrompt: String
    
    init(content: String, agentType: AgentType, systemPrompt: String) {
        self.content = content
        self.agentType = agentType
        self.systemPrompt = systemPrompt
    }
}