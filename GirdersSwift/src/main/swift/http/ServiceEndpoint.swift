import Foundation

/// Protocol which can be used to define the rest services in a more type safe manner.
/// The goal is to avoid creating the needed URLs directly, but define everything that's needed by
/// implementing this protocol with any type (enum, struct, class). However, enum is recommended.
public protocol ServiceEndpoint {
    
    /// The base url for the endpoint.
    var baseURL: URL { get }
    
    /// The specific path of the endpoint.
    var path: String { get }
    
    /// The required method.
    var method: HTTPMethod { get }
    
    /// The parameters of the endpoint
    var parameters: Any? { get }
    
    /// The query parameters which are added to the url.
    var queryParameters: Any? { get }
    
    /// An instance of the request generator which prepares the HTTP request.
    var requestGenerator: RequestGenerator { get }
}

/// Default implementation of the ServiceEndpoint protocol. However, the paths have to be defined
/// in the type implementation.
public extension ServiceEndpoint {

    var method: HTTPMethod {
        get {
            return .GET
        }
    }

    var parameters: Any? {
        get {
            return nil
        }
    }
    
    var queryParameters: Any? {
        get {
            return nil
        }
    }

    var requestGenerator: RequestGenerator {
        get {
            return StandardRequestGenerator()
        }
    }

    var baseURL: URL {
        get {
            let urlString = Configuration.sharedInstance[Constants.BaseURL] as? String
            return URL(string: urlString!)!
        }
    }
    
}
