import UIKit

/// Main chat view controller for the multi-agent chatbot interface
final class ChatViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Messages in the conversation
    private var messages: [Message] = []
    
    /// Selected agent type
    private var selectedAgent: AgentType = .general
    
    /// Whether a request is in progress
    private var isLoading: Bool = false
    
    /// Keyboard height adjustment
    private var keyboardHeight: CGFloat = 0
    
    // MARK: - UI Components
    
    /// Table view for messages
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        return tableView
    }()
    
    /// Input view for typing messages
    private let inputView: ChatInputView = {
        let view = ChatInputView()
        return view
    }()
    
    /// Agent selector view
    private let agentSelectorView: AgentSelectorView = {
        let view = AgentSelectorView()
        return view
    }()
    
    /// Loading indicator
    private let loadingIndicator: UIActivityIndicatorView = {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .medium
        } else {
            style = .gray
        }
        let indicator = UIActivityIndicatorView(style: style)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    /// Empty state label
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Select an agent and type a message to start the conversation"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.isHidden = false
        return label
    }()
    
    // MARK: - Constraints
    
    private var inputViewBottomConstraint: NSLayoutConstraint?
    private var agentSelectorHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom(animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Configure view controller
        title = "Multi-Agent Chat"
        view.backgroundColor = .white
        
        // Configure navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator)
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(agentSelectorView)
        view.addSubview(inputView)
        view.addSubview(emptyStateLabel)
        
        // Set delegates
        inputView.delegate = self
        agentSelectorView.delegate = self
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputView.translatesAutoresizingMaskIntoConstraints = false
        agentSelectorView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        inputViewBottomConstraint = inputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        agentSelectorHeightConstraint = agentSelectorView.heightAnchor.constraint(equalToConstant: 50)
        
        NSLayoutConstraint.activate([
            // Agent selector at top
            agentSelectorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            agentSelectorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            agentSelectorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            agentSelectorHeightConstraint!,
            
            // Table view below agent selector
            tableView.topAnchor.constraint(equalTo: agentSelectorView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputView.topAnchor),
            
            // Input view at bottom (above safe area)
            inputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputViewBottomConstraint!,
            
            // Empty state label centered
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -40)
        ])
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        // Get keyboard height relative to safe area
        let keyboardHeightInView = keyboardFrame.height - view.safeAreaInsets.bottom
        
        // Update constraint
        inputViewBottomConstraint?.constant = -keyboardHeightInView
        
        // Animate changes
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
        // Scroll to bottom
        scrollToBottom(animated: true)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        // Reset constraint
        inputViewBottomConstraint?.constant = 0
        
        // Animate changes
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Public Methods
    
    /// Send a message to the API
    func sendMessage(_ content: String) {
        // Create user message
        let userMessage = Message(content: content, isUser: true)
        messages.append(userMessage)
        
        // Add to table
        tableView.reloadData()
        scrollToBottom(animated: true)
        
        // Update empty state
        emptyStateLabel.isHidden = true
        
        // Show loading
        showLoading(true)
        
        // Send to API
        APIClient.shared.sendMessage(content, agentType: selectedAgent, conversationHistory: messages) { [weak self] result in
            guard let self = self else { return }
            
            self.showLoading(false)
            
            switch result {
            case .success(let response):
                // Create AI response message
                let aiMessage = Message(content: response, isUser: false, agentType: self.selectedAgent)
                self.messages.append(aiMessage)
                self.tableView.reloadData()
                self.scrollToBottom(animated: true)
                
            case .failure(let error):
                self.showError(error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func scrollToBottom(animated: Bool) {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
    
    private func showLoading(_ show: Bool) {
        isLoading = show
        if show {
            loadingIndicator.startAnimating()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator)
        } else {
            loadingIndicator.stopAnimating()
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func showError(_ error: APIError) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.configure(with: message)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - ChatInputViewDelegate

extension ChatViewController: ChatInputViewDelegate {
    
    func chatInputView(_ inputView: ChatInputView, didSendMessage message: String) {
        sendMessage(message)
    }
    
    func chatInputViewDidBeginEditing(_ inputView: ChatInputView) {
        // Additional handling if needed
    }
    
    func chatInputViewDidEndEditing(_ inputView: ChatInputView) {
        // Additional handling if needed
    }
}

// MARK: - AgentSelectorViewDelegate

extension ChatViewController: AgentSelectorViewDelegate {
    
    func agentSelectorView(_ selectorView: AgentSelectorView, didSelectAgent agent: AgentType) {
        selectedAgent = agent
    }
}