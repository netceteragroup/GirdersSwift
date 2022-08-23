import Foundation

/// Protocol that describes methods for serialization of data.
public protocol Serializable {
    
    /// Converts the serializable object to data and returns it.
    ///
    /// - Returns: The serializable object as an optional Data object.
    func toData() -> Data?
    
    /// Converts the serializable object to dictionary and returns it.
    ///
    /// - Returns: The serializable object as a dictionary.
    func toDictionary() -> [String: Any]
    
    /// Converts the serializable object to a string and returns it.
    ///
    /// - Returns: The serializable object as a optional string.
    func toString() -> String?
}

/// Default implementation of the Serializable protocol.
public extension Serializable {
    
    func toData() -> Data? {
        let dictionary = toDictionary()
        var result: Data? = nil

        do {
            result = try JSONSerialization.data(withJSONObject: dictionary)
        } catch {
            print(error.localizedDescription)
        }

        return result
    }

    func toString() -> String? {
        if let data = toData() {
            let result = String(data: data, encoding: String.Encoding.utf8)

            return result
        }
        return nil
    }
    
}
