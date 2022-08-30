import Foundation

/// Defines the functionality for handling http responses.
public protocol ResponseHandler {
    
    /// Determines if a response of a given type can be handled.
    ///
    /// - Parameter responseType: The meta type of the response.
    /// - Returns: True if the given response type can be handled, false otherwise.
    func canHandle<T>(responseType: T.Type) -> Bool
    
    /// Processes the response data of a HTTP response.
    ///
    /// - Parameter responseData: The raw data of the HTTP response.
    /// - Returns: An instance of the supported type.
    func process<T>(responseData: Data) -> T?
}
