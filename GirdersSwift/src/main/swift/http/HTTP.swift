import Foundation

/// Enumeration representing result from http request.
/// The successfull result can be any type (Response, Image, etc).
public enum Result<T, NSError> {
    
    /// When the request was successful.
    case Success(T)
    
    /// When the request failed.
    case Failure(Error?)
}

/// Type representing response from the server.
public struct Response<T> {
    
    /// The status code of the response.
    public let statusCode: Int
    
    /// Optional body of the response.
    public let body: Data?
    
    /// Optional generic body object of the response.
    public let bodyObject: T?
    
    // Contains the headers of the response.
    public let responseHeaders: [AnyHashable : Any]
    
    // The url of the response.
    public let url: URL?

    public init(statusCode: Int,
                body: Data?,
                bodyObject: T?,
                responseHeaders: [AnyHashable : Any],
                url: URL?) {
        self.statusCode = statusCode
        self.body = body
        self.bodyObject = bodyObject
        self.responseHeaders = responseHeaders
        self.url = url
    }
    
}

/// The protocol that declares methods for http communication. 
/// Note that it currently has only the ones needed for this project.
public protocol HTTP {
    
    /// Executes the provided request and returns enumeration of type Result.
    ///
    /// - Parameter request: The request object containing all required data.
    /// - Returns: The http result containing a repsone object and an error object if the request fails.
    func executeRequest<T>(request: Request) -> Result<Response<T>, Error?>
    
    /// Executes the provided request and returns enumeration of type Result.
    ///
    /// - Parameter request: The request object containing all required data.
    /// - Parameter completionHandler: completion handler with the result of the request.
    func executeRequest<T>(request: Request,
                           completionHandler: @escaping (Result<Response<T>, Error?>) -> Void)

    /// Executes get request with the provided url.
    ///
    /// - Parameter url: The url of the endpoint.
    /// - Returns: The http result containing a repsone object and an error object if the request fails.
    func get<T>(url: URL) -> Result<Response<T>, Error?>
    
    /// Executes get request with the provided url.
    ///
    /// - Parameter url: The url of the endpoint.
    /// - Parameter completionHandler: completion handler with the result of the request.
    func get<T>(url: URL,
                completionHandler: @escaping (Result<Response<T>, Error?>) -> Void)
}
