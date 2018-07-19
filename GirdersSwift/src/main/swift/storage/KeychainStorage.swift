
import Foundation
import KeychainAccess

public class KeychainStorage: SecureStorage {
    
    static let shared = KeychainStorage()
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    func save(string: String?, forKey key: String) {
        keychain[key] = string
    }
    
    func removeString(forKey key: String) {
        keychain[key] = nil
    }
    
    func string(forKey key: String) -> String? {
        return keychain[key]
    }
    
    func save(value: Data?, key: String) {
        guard let value = value else {
            return
        }
        do {
            try keychain.set(value, key: key)
        } catch {
            Log.debug("Error saving to keychain")
        }
    }
    
    func removeData(forKey key: String) {
        do {
            try keychain.remove(key)
        } catch {
            Log.debug("Error removing from keychain")
        }
    }
    
    func data(forKey key: String) -> Data? {
        do {
            let data = try keychain.getData(key)
            return data
        } catch {
            Log.debug("Error retrieving data from keychain.")
            return nil
        }
    }
    
    func clearSecureStorage() {
        do {
            try keychain.removeAll()
        } catch {
            Log.error("Error removing keychain items")
        }
    }
    
}
