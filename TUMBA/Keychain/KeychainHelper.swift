import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    // MARK: - Основные методы
    func save(_ data: Data, service: String, account: String) -> Bool {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as [CFString: Any] as CFDictionary
        
        var status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account
            ] as [CFString: Any] as CFDictionary
            
            let attributes = [kSecValueData: data] as CFDictionary
            status = SecItemUpdate(query, attributes)
        }
        
        return status == errSecSuccess
    }
    
    func read(service: String, account: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as [CFString: Any] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        return status == errSecSuccess ? (result as? Data) : nil
    }
    
    func delete(service: String, account: String) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as [CFString: Any] as CFDictionary
        
        let status = SecItemDelete(query)
        return status == errSecSuccess
    }
    
    // MARK: - Поддержка Кодирования
    func save<T: Codable>(_ item: T, service: String, account: String) -> Bool {
        guard let data = try? JSONEncoder().encode(item) else {
            return false
        }
        return save(data, service: service, account: account)
    }
    
    func read<T: Codable>(service: String, account: String, type: T.Type) -> T? {
        guard let data = read(service: service, account: account),
              let item = try? JSONDecoder().decode(type, from: data) else {
            return nil
        }
        return item
    }
}
