import Foundation
import Security

// Generic keychain item that can represent any credential
@objc public class KeychainItem: NSObject {
    @objc public let service: String
    @objc public let account: String
    @objc public let label: String
    @objc public let createdAt: Date?
    @objc public let modifiedAt: Date?
    @objc public let accessGroup: String?
    @objc public let comment: String?
    
    public init(service: String, account: String, label: String, createdAt: Date?, modifiedAt: Date?, accessGroup: String?, comment: String?) {
        self.service = service
        self.account = account
        self.label = label
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.accessGroup = accessGroup
        self.comment = comment
        super.init()
    }
}

// Helper class to iterate through results from Kotlin Native
@objc public class KeychainItemsResult: NSObject {
    private let items: [KeychainItem]
    
    @objc public var count: Int {
        return items.count
    }
    
    init(items: [KeychainItem]) {
        self.items = items
        super.init()
    }
    
    @objc public func getItem(at index: Int) -> KeychainItem? {
        guard index >= 0 && index < items.count else {
            return nil
        }
        return items[index]
    }
    
    @objc public func getAllItems() -> [KeychainItem] {
        return items
    }
    
    @objc public func forEach(_ block: @escaping (KeychainItem) -> Void) {
        items.forEach(block)
    }
}

@objc public class KeychainService: NSObject {
    
    // MARK: - List All Items
    
    /// List all keychain items - returns helper object for easier Kotlin Native usage
    @objc public func listAllItemsAsResult() -> KeychainItemsResult {
        let items = listAllItemsArray()
        return KeychainItemsResult(items: items)
    }
    
    /// List all keychain items as array
    private func listAllItemsArray() -> [KeychainItem] {
        var items: [KeychainItem] = []
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: false
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let keychainItems = result as? [[String: Any]] {
            for item in keychainItems {
                if let service = item[kSecAttrService as String] as? String,
                   let account = item[kSecAttrAccount as String] as? String {
                    
                    let keychainItem = KeychainItem(
                        service: service,
                        account: account,
                        label: item[kSecAttrLabel as String] as? String ?? account,
                        createdAt: item[kSecAttrCreationDate as String] as? Date,
                        modifiedAt: item[kSecAttrModificationDate as String] as? Date,
                        accessGroup: item[kSecAttrAccessGroup as String] as? String,
                        comment: item[kSecAttrComment as String] as? String
                    )
                    items.append(keychainItem)
                }
            }
        }
        
        return items
    }
    
    /// List all keychain items (legacy NSArray version)
    @objc public func listAllItems() -> NSArray {
        return NSArray(array: listAllItemsArray())
    }
    
    /// Get count of all items
    @objc public func getAllItemsCount() -> Int {
        return listAllItemsArray().count
    }
    
    /// Get item at specific index from all items
    @objc public func getItem(atIndex index: Int) -> KeychainItem? {
        let items = listAllItemsArray()
        guard index >= 0 && index < items.count else {
            return nil
        }
        return items[index]
    }
    
    // MARK: - Find by Service Name
    
    /// Find keychain items by service name (exact match) - returns helper object
    @objc public func findItemsAsResult(byService service: String) -> KeychainItemsResult {
        let items = listAllItemsArray().filter { $0.service == service }
        return KeychainItemsResult(items: items)
    }
    
    /// Find keychain items by service name (exact match)
    @objc public func findItems(byService service: String) -> NSArray {
        let items = listAllItemsArray().filter { $0.service == service }
        return NSArray(array: items)
    }
    
    /// Find first keychain item by service name
    @objc public func findFirstItem(byService service: String) -> KeychainItem? {
        return listAllItemsArray().first { $0.service == service }
    }
    
    /// Get count of items by service
    @objc public func getItemsCount(byService service: String) -> Int {
        return listAllItemsArray().filter { $0.service == service }.count
    }
    
    /// Get item at index for specific service
    @objc public func getItem(atIndex index: Int, byService service: String) -> KeychainItem? {
        let items = listAllItemsArray().filter { $0.service == service }
        guard index >= 0 && index < items.count else {
            return nil
        }
        return items[index]
    }
    
    // MARK: - Find by Service Name (Contains)
    
    /// Find keychain items where service name contains the search string - returns helper object
    @objc public func findItemsAsResult(serviceContains searchString: String) -> KeychainItemsResult {
        let items = listAllItemsArray()
            .filter { $0.service.lowercased().contains(searchString.lowercased()) }
        return KeychainItemsResult(items: items)
    }
    
    /// Find keychain items where service name contains the search string
    @objc public func findItems(serviceContains searchString: String) -> NSArray {
        let items = listAllItemsArray()
            .filter { $0.service.lowercased().contains(searchString.lowercased()) }
        return NSArray(array: items)
    }
    
    /// Get count of items where service contains string
    @objc public func getItemsCount(serviceContains searchString: String) -> Int {
        return listAllItemsArray()
            .filter { $0.service.lowercased().contains(searchString.lowercased()) }
            .count
    }
    
    // MARK: - Find by Account Name
    
    /// Find keychain items by account name (exact match)
    @objc public func findItems(byAccount account: String) -> NSArray {
        let items = listAllItemsArray().filter { $0.account == account }
        return NSArray(array: items)
    }
    
    /// Find keychain items where account contains the search string
    @objc public func findItems(accountContains searchString: String) -> NSArray {
        let items = listAllItemsArray()
            .filter { $0.account.lowercased().contains(searchString.lowercased()) }
        return NSArray(array: items)
    }
    
    // MARK: - Find by Label
    
    /// Find keychain items by label (exact match)
    @objc public func findItems(byLabel label: String) -> NSArray {
        let items = listAllItemsArray().filter { $0.label == label }
        return NSArray(array: items)
    }
    
    /// Find keychain items where label contains the search string
    @objc public func findItems(labelContains searchString: String) -> NSArray {
        let items = listAllItemsArray()
            .filter { $0.label.lowercased().contains(searchString.lowercased()) }
        return NSArray(array: items)
    }
    
    // MARK: - Find by Service and Account
    
    /// Find a specific keychain item by service and account
    @objc public func findItem(service: String, account: String) -> KeychainItem? {
        return listAllItemsArray()
            .first { $0.service == service && $0.account == account }
    }
    
    // MARK: - Token/Password Operations
    
    /// Get token/password for a keychain item
    @objc public func getToken(for item: KeychainItem) -> String? {
        retrieveToken(service: item.service, account: item.account)
    }
    
    /// Get token/password by service and account
    @objc public func retrieveToken(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    /// Save token/password for a keychain item
    @objc public func saveToken(for item: KeychainItem, token: String) -> Bool {
        saveToken(service: item.service, account: item.account, token: token)
    }
    
    /// Save token/password by service and account
    @objc public func saveToken(service: String, account: String, token: String) -> Bool {
        guard let passwordData = token.data(using: .utf8) else {
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Delete token/password for a keychain item
    @objc public func deleteToken(for item: KeychainItem) -> Bool {
        deleteToken(service: item.service, account: item.account)
    }
    
    /// Delete token/password by service and account
    @objc public func deleteToken(service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Convenience Search
    
    /// Search keychain items by any field containing the search string - returns helper object
    @objc public func searchItemsAsResult(containing searchString: String) -> KeychainItemsResult {
        let search = searchString.lowercased()
        let items = listAllItemsArray().filter { item in
            item.service.lowercased().contains(search) ||
            item.account.lowercased().contains(search) ||
            item.label.lowercased().contains(search) ||
            (item.comment?.lowercased().contains(search) ?? false)
        }
        return KeychainItemsResult(items: items)
    }
    
    /// Search keychain items by any field containing the search string
    @objc public func searchItems(containing searchString: String) -> NSArray {
        let search = searchString.lowercased()
        let items = listAllItemsArray().filter { item in
            item.service.lowercased().contains(search) ||
            item.account.lowercased().contains(search) ||
            item.label.lowercased().contains(search) ||
            (item.comment?.lowercased().contains(search) ?? false)
        }
        return NSArray(array: items)
    }
    
    /// Get count of search results
    @objc public func getSearchResultsCount(containing searchString: String) -> Int {
        return searchItemsAsResult(containing: searchString).count
    }
    
    /// Get item at index from search results
    @objc public func getSearchResultItem(atIndex index: Int, containing searchString: String) -> KeychainItem? {
        return searchItemsAsResult(containing: searchString).getItem(at: index)
    }
}
