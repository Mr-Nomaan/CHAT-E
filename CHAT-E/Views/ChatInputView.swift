import UIKit

/// Protocol for handling input accessory view events
protocol ChatInputViewDelegate: AnyObject {
    func chatInputView(_ inputView: ChatInputView, didSendMessage message: String)
    func chatInputViewDidBeginEditing(_ inputView: ChatInputView)
    func chatInputViewDidEndEditing(_ inputView: ChatInputView)
}

/// Custom input accessory view for the chat interface
final class ChatInputView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: ChatInputViewDelegate?
    
    /// Whether the input view is in editing mode
    var isEditing: Bool {
        return textView.isFirstResponder
    }
    
    // MARK: - UI Components
    
    /// Container view
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    /// Top border line
    private let topBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        return view
    }()
    
    /// Text input view
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .black
        textView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        textView.layer.cornerRadius = 18
        textView.layer.masksToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 40)
        textView.isScrollEnabled = false
        return textView
    }()
    
    /// Placeholder label
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Type a message..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    /// Send button
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Create send icon using SF Symbols
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
        
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Constraints
    
    private var textViewHeightConstraint: NSLayoutConstraint?
    private let minTextViewHeight: CGFloat = 36
    private let maxTextViewHeight: CGFloat = 120
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Configure view
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        addSubview(containerView)
        containerView.addSubview(topBorderView)
        containerView.addSubview(textView)
        containerView.addSubview(placeholderLabel)
        containerView.addSubview(sendButton)
        
        // Set delegates
        textView.delegate = self
        
        // Add targets
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: minTextViewHeight)
        
        NSLayoutConstraint.activate([
            // Container view fills the entire view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Top border at top of container
            topBorderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            topBorderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            topBorderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            topBorderView.heightAnchor.constraint(equalToConstant: 1),
            
            // Text view below top border
            textView.topAnchor.constraint(equalTo: topBorderView.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            textViewHeightConstraint!,
            
            // Send button to the right of text view
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Placeholder label inside text view
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func sendTapped() {
        guard let text = textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Notify delegate
        delegate?.chatInputView(self, didSendMessage: text)
        
        // Clear text
        textView.text = ""
        placeholderLabel.isHidden = false
        sendButton.isEnabled = false
        
        // Reset height
        textViewHeightConstraint?.constant = minTextViewHeight
        textView.isScrollEnabled = false
    }
    
    // MARK: - Public Methods
    
    /// Clear the input
    func clearInput() {
        textView.text = ""
        placeholderLabel.isHidden = false
        sendButton.isEnabled = false
        textViewHeightConstraint?.constant = minTextViewHeight
    }
    
    /// Focus the text view
    func focus() {
        textView.becomeFirstResponder()
    }
    
    /// Unfocus the text view
    func unfocus() {
        textView.resignFirstResponder()
    }
}

// MARK: - UITextViewDelegate

extension ChatInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // Update placeholder visibility
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        // Update send button state
        sendButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Calculate new height
        let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude))
        let newHeight = min(max(size.height, minTextViewHeight), maxTextViewHeight)
        
        // Update constraint
        textViewHeightConstraint?.constant = newHeight
        
        // Enable scrolling if text exceeds max height
        textView.isScrollEnabled = newHeight >= maxTextViewHeight
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.chatInputViewDidBeginEditing(self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.chatInputViewDidEndEditing(self)
    }
}