
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
    
    //MARK: - biometric protection
    public func saveWithBiometricProtection(string: String?,
                                            forKey key: String,
                                            accessibility: Accessibility,
                                            authenticationPolicy: AuthenticationPolicy) {
        guard let string = string else {
            do {
                try keychain.remove(key)
            } catch {
                Log.error("Error removing keychain items")
            }
            return
        }
        DispatchQueue.global().async { [unowned self] in
            do {
                try self.keychain
                    .accessibility(accessibility, authenticationPolicy: authenticationPolicy)
                    .set(string, key: key)
            } catch {
                Log.error("Error saving value")
            }
        }
    }
    
    public func saveWithBiometricProtection(data: Data?,
                                            forKey key: String,
                                            accessibility: Accessibility,
                                            authenticationPolicy: AuthenticationPolicy) {
        guard let data = data else {
            do {
                try keychain.remove(key)
            } catch {
                Log.error("Error removing keychain items")
            }
            return
        }
        DispatchQueue.global().async { [unowned self] in
            do {
                try self.keychain
                    .accessibility(accessibility, authenticationPolicy: authenticationPolicy)
                    .set(data, key: key)
            } catch {
                Log.error("Error saving value")
            }
        }
    }
    
    public func saveWithBiometricProtection(string: String?, forKey key: String) {
        self.saveWithBiometricProtection(string: string,
                                         forKey: key,
                                         accessibility: .whenPasscodeSetThisDeviceOnly,
                                         authenticationPolicy: .userPresence)
    }
    
    public func saveWithBiometricProtection(data: Data?,
                                            forKey key: String) {
        self.saveWithBiometricProtection(data: data,
                                         forKey: key,
                                         accessibility: .whenPasscodeSetThisDeviceOnly,
                                         authenticationPolicy: .userPresence)
    }
    
    public func biometricProtectedString(forKey key: String,
                                         withPrompt prompt: String,
                                         result: @escaping (String?) -> Void) {
        DispatchQueue.global().async { [unowned self] in
            do {
                let value = try self.keychain.authenticationPrompt(prompt).get(key)
                DispatchQueue.main.async {
                    result(value)
                }
            } catch {
                Log.error("Error retrieving the protected value")
                DispatchQueue.main.async {
                    result(nil)
                }
            }
        }
    }
    
    public func biometricProtectedData(forKey key: String,
                                       withPrompt prompt: String,
                                       result: @escaping (Data?) -> Void) {
        DispatchQueue.global().async { [unowned self] in
            do {
                let value = try self.keychain.authenticationPrompt(prompt).getData(key)
                DispatchQueue.main.async {
                    result(value)
                }
            } catch {
                Log.error("Error retrieving the protected value")
                DispatchQueue.main.async {
                    result(nil)
                }
            }
        }
    }
    
}
