import UIKit

/// Custom table view cell for displaying chat messages
final class MessageCell: UITableViewCell {
    
    // MARK: - Reuse Identifier
    
    static let reuseIdentifier = "MessageCell"
    
    // MARK: - UI Components
    
    /// The bubble view container
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    /// The message label
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    /// The timestamp label
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .lightGray
        return label
    }()
    
    /// Agent icon (shown for AI messages)
    private let agentIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        return imageView
    }()
    
    // MARK: - Constraints
    
    private var bubbleLeadingConstraint: NSLayoutConstraint?
    private var bubbleTrailingConstraint: NSLayoutConstraint?
    private var timestampLeadingConstraint: NSLayoutConstraint?
    private var timestampTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - Properties
    
    private var isUserMessage: Bool = false
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Configure cell
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Add subviews
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(agentIconView)
        
        // Set up constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Disable autoresizing masks
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        agentIconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Bubble view constraints
        bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        
        // Message label constraints
        let messageLeading = messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12)
        let messageTrailing = messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12)
        let messageTop = messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10)
        let messageBottom = messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10)
        
        // Timestamp constraints
        timestampLeadingConstraint = timestampLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor)
        timestampTrailingConstraint = timestampLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor)
        
        // Agent icon constraints
        let agentIconLeading = agentIconView.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 4)
        let agentIconTrailing = agentIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        let agentIconBottom = agentIconView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor)
        let agentIconWidth = agentIconView.widthAnchor.constraint(equalToConstant: 16)
        let agentIconHeight = agentIconView.heightAnchor.constraint(equalToConstant: 16)
        
        // Bubble width constraint (max 75% of screen width)
        let bubbleWidth = bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75)
        
        // Bubble top constraint
        let bubbleTop = bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4)
        
        // Timestamp top constraint
        let timestampTop = timestampLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2)
        
        // Activate constraints
        NSLayoutConstraint.activate([
            bubbleLeadingConstraint!,
            bubbleTrailingConstraint!,
            bubbleWidth,
            bubbleTop,
            messageLeading,
            messageTrailing,
            messageTop,
            messageBottom,
            timestampLeadingConstraint!,
            timestampTrailingConstraint!,
            timestampTop,
            agentIconLeading,
            agentIconBottom,
            agentIconWidth,
            agentIconHeight
        ])
        
        // Deactivate trailing anchor for icon initially
        agentIconTrailing.isActive = false
    }
    
    // MARK: - Configuration
    
    /// Configure the cell with a message
    /// - Parameter message: The message to display
    func configure(with message: Message) {
        isUserMessage = message.isUser
        messageLabel.text = message.content
        
        // Format timestamp
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timestampLabel.text = formatter.string(from: message.timestamp)
        
        // Configure appearance based on sender
        if message.isUser {
            // User message (right-aligned, blue bubble)
            bubbleView.backgroundColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
            messageLabel.textColor = .white
            
            bubbleLeadingConstraint?.isActive = false
            bubbleTrailingConstraint?.isActive = true
            
            timestampLeadingConstraint?.isActive = false
            timestampTrailingConstraint?.isActive = true
            
            // Hide agent icon for user messages
            agentIconView.isHidden = true
        } else {
            // AI message (left-aligned, gray bubble)
            bubbleView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            messageLabel.textColor = .black
            
            bubbleLeadingConstraint?.isActive = true
            bubbleTrailingConstraint?.isActive = false
            
            timestampLeadingConstraint?.isActive = true
            timestampTrailingConstraint?.isActive = false
            
            // Show agent icon for AI messages
            agentIconView.isHidden = false
            if let agentType = message.agentType {
                agentIconView.image = UIImage(systemName: agentType.iconName)
            } else {
                agentIconView.image = UIImage(systemName: "robot")
            }
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
        timestampLabel.text = nil
        agentIconView.image = nil
    }
}