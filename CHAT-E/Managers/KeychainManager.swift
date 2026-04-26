import Foundation
import Security

/// Manages secure storage and retrieval of API keys using iOS Keychain Services
final class KeychainManager {
    
    // MARK: - Singleton
    
    static let shared = KeychainManager()
    
    // MARK: - Constants
    
    private let serviceName = "com.multichat.agentapp"
    private let apiKeyAccount = "api_key"
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - API Key Management
    
    /// Save the API key to the Keychain
    /// - Parameter apiKey: The API key to save
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func saveAPIKey(_ apiKey: String) -> Bool {
        
        // Encode the API key
        guard let data = apiKey.data(using: .utf8) else {
            return false
        }
        
        // First, try to delete any existing key
        deleteAPIKey()
        
        // Create the query for adding
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: apiKeyAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Add the key to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    /// Retrieve the API key from the Keychain
    /// - Returns: The stored API key, or nil if not found
    func getAPIKey() -> String? {
        
        // Create the query for retrieval
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: apiKeyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Execute the query
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        // Check if successful
        guard status == errSecSuccess,
              let data = result as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return apiKey
    }
    
    /// Delete the API key from the Keychain
    /// - Returns: True if successful or key didn't exist, false otherwise
    @discardableResult
    func deleteAPIKey() -> Bool {
        
        // Create the query for deletion
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: apiKeyAccount
        ]
        
        // Delete the item
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// Check if an API key is stored
    /// - Returns: True if an API key exists
    func hasAPIKey() -> Bool {
        return getAPIKey() != nil
    }
    
    // MARK: - Generic Keychain Operations
    
    /// Save a string value to the Keychain
    /// - Parameters:
    ///   - value: The value to save
    ///   - key: The key identifier
    /// - Returns: True if successful
    @discardableResult
    func saveValue(_ value: String, forKey key: String) -> Bool {
        
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve a string value from the Keychain
    /// - Parameter key: The key identifier
    /// - Returns: The stored value, or nil if not found
    func getValue(forKey key: String) -> String? {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
}