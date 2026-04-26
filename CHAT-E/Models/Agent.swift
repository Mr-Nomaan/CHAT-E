import Foundation

/// Enum representing the different AI agent types available in the multi-agent system
enum AgentType: String, Codable, CaseIterable {
    
    case coder = "coder"
    case writer = "writer"
    case general = "general"
    
    // MARK: - Display Properties
    
    /// Human-readable display name for the agent
    var displayName: String {
        switch self {
        case .coder:
            return "Coder"
        case .writer:
            return "Writer"
        case .general:
            return "General"
        }
    }
    
    /// System prompt that defines the agent's behavior and expertise
    var systemPrompt: String {
        switch self {
        case .coder:
            return "You are an expert coding assistant. You help users with programming tasks, debugging code, explaining algorithms, and software development concepts. You provide clear, well-commented code examples when appropriate. You specialize in Swift, Python, JavaScript, and other programming languages."
        case .writer:
            return "You are an expert writing assistant. You help users with creative writing, editing, proofreading, and content creation. You provide suggestions for improving clarity, tone, grammar, and style. You can help with essays, stories, emails, and professional documents."
        case .general:
            return "You are a helpful general assistant. You answer questions on a wide range of topics, provide explanations, and assist with various tasks. You aim to be informative, accurate, and helpful in your responses."
        }
    }
    
    /// Icon name for the agent (SF Symbols)
    var iconName: String {
        switch self {
        case .coder:
            return "chevron.left.forwardslash.chevron.right"
        case .writer:
            return "pencil"
        case .general:
            return "questionmark.circle"
        }
    }
    
    // MARK: - Index for Segmented Control
    
    /// Index position in a segmented control (0-based)
    var segmentIndex: Int {
        switch self {
        case .coder:
            return 0
        case .writer:
            return 1
        case .general:
            return 2
        }
    }
    
    /// Initialize from segment index
    init(segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            self = .coder
        case 1:
            self = .writer
        case 2:
            self = .general
        default:
            self = .general
        }
    }
}

/// Represents an AI agent configuration
struct Agent: Codable {
    let type: AgentType
    let isEnabled: Bool
    
    init(type: AgentType, isEnabled: Bool = true) {
        self.type = type
        self.isEnabled = isEnabled
    }
}