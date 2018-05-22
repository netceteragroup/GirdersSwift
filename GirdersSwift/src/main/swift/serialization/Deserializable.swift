import Foundation

/// Protocol that describes methods for deserialization of data.
public protocol Deserializable {
    
    /// Deserialize a given data to a generic type T.
    ///
    /// - Parameter data: The date which has to be deserialized.
    /// - Returns: An Optional generic object T.
    static func deserialize<T>(from data: Data?) -> T?
}
