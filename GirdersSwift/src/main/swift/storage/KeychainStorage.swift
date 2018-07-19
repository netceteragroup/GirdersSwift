
import Foundation
import KeychainAccess

public class KeychainStorage: SecureStorage {
    
    public static let shared = KeychainStorage()
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    public func save(string: String?, forKey key: String) {
        keychain[key] = string
    }
    
    public func removeString(forKey key: String) {
        keychain[key] = nil
    }
    
    public func string(forKey key: String) -> String? {
        return keychain[key]
    }
    
    public func save(value: Data?, key: String) {
        guard let value = value else {
            return
        }
        do {
            try keychain.set(value, key: key)
        } catch {
            Log.debug("Error saving to keychain")
        }
    }
    
    public func removeData(forKey key: String) {
        do {
            try keychain.remove(key)
        } catch {
            Log.debug("Error removing from keychain")
        }
    }
    
    public func data(forKey key: String) -> Data? {
        do {
            let data = try keychain.getData(key)
            return data
        } catch {
            Log.debug("Error retrieving data from keychain.")
            return nil
        }
    }
    
    public func clearSecureStorage() {
        do {
            try keychain.removeAll()
        } catch {
            Log.error("Error removing keychain items")
        }
    }
    
}
