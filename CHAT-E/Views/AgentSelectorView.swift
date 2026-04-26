import UIKit

/// Protocol for handling agent selector events
protocol AgentSelectorViewDelegate: AnyObject {
    func agentSelectorView(_ selectorView: AgentSelectorView, didSelectAgent agent: AgentType)
}

/// Agent selector view with segmented control
final class AgentSelectorView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: AgentSelectorViewDelegate?
    
    /// Currently selected agent
    private(set) var selectedAgent: AgentType = .general
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Agent:"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: AgentType.allCases.map { $0.displayName })
        control.selectedSegmentIndex = 2 // Default to General
        control.selectedSegmentTintColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        return control
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        view.layer.cornerRadius = 8
        return view
    }()
    
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
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(segmentedControl)
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            segmentedControl.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            segmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            segmentedControl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            segmentedControl.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func segmentChanged() {
        let index = segmentedControl.selectedSegmentIndex
        selectedAgent = AgentType(segmentIndex: index)
        delegate?.agentSelectorView(self, didSelectAgent: selectedAgent)
    }
    
    // MARK: - Public Methods
    
    /// Select an agent programmatically
    /// - Parameter agent: The agent to select
    func selectAgent(_ agent: AgentType) {
        selectedAgent = agent
        segmentedControl.selectedSegmentIndex = agent.segmentIndex
    }
    
    /// Select agent by index
    /// - Parameter index: The segment index
    func selectAgent(at index: Int) {
        guard index >= 0 && index < AgentType.allCases.count else { return }
        selectAgent(AgentType(segmentIndex: index))
    }
}