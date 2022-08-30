
import Foundation

/// Protocol that defines methods for secure storing of items.
public protocol SecureStorage {
    /// Saves the provided string under the provided key.
    func save(string: String?, forKey key: String)
    /// Removes the string under the provided key.
    func removeString(forKey key: String)
    /// Saves the provided data under the provided key.
    func save(value: Data?, key: String)
    /// Removes the data under the provided key.
    func removeData(forKey key: String)
    /// Retrieves the string for the provided key.
    func string(forKey key: String) -> String?
    /// Retrieves the data for the provided key.
    func data(forKey key: String) -> Data?
    /// Clears the secure storage.
    func clearSecureStorage()
    /// Saves a string with biometric protection.
    func saveWithBiometricProtection(string: String?, forKey key: String)
    /// Retrieves a string saved with biometric protection.
    func biometricProtectedString(forKey key: String,
                                  withPrompt prompt: String,
                                  result: @escaping (String?) -> Void)
    /// Saves data with biometric protection.
    func saveWithBiometricProtection(data: Data?,
                                     forKey key: String)
    /// Retrieves data saved with biometric protection.
    func biometricProtectedData(forKey key: String,
                                withPrompt prompt: String,
                                result: @escaping (Data?) -> Void)
}
