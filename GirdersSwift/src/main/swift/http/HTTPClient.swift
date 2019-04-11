import Foundation
import GRSecurity

/// NSURLSession implementation of the HTTP protocol.
///
/// The requests are done synchronously. The logic behind the sync requests is that we can easily 
/// plug in RX extensions or promises to this implementation.
/// If you want to use it directly (without RX extensions or promises), you should do it in a 
/// background thread.
///
/// You can also use async requests with completion handler.
public class HTTPClient {

    fileprivate var responseHandlers: [ResponseHandler]
    fileprivate let sessionDelegate: DefaultSessionDelegate = DefaultSessionDelegate()
    fileprivate let urlSession: URLSession
    fileprivate var requestsPool: [Request] = [Request]()
    
    /// Init method with possibility to customise the NSURLSession used for the requests.
    public init(urlSession: URLSession, handlers:[ResponseHandler] = [ResponseHandler]()) {
        self.urlSession = urlSession
        self.responseHandlers = handlers
    }
    
    /// Init method that creates default NSURLSession with no response handlers.
    public init(handlers:[ResponseHandler] = [ResponseHandler]()) {
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration,
                                     delegate: sessionDelegate,
                                     delegateQueue: nil)
        self.responseHandlers = handlers
        sessionDelegate.httpClient = self
    }
    
    deinit {
        self.urlSession.finishTasksAndInvalidate()
    }
    
    /// Extracts the credentials for a given url request.
    ///
    /// - Parameter request: The given url request.
    /// - Returns: The ssl credentials for a given request, returns nil if no credentials were found.
    public func credentialsForRequest(request: URLRequest) -> SSLCredentials? {
        for current in requestsPool {
            if request.matches(request: current) {
                return current.sslCredentials
            }
        }
        return nil
    }

}

// MARK: - HTTP protocol
extension HTTPClient: HTTP {
    
    public func executeRequest<T>(request: Request) -> Result<Response<T>, Error?> {
        var result: Result<Response<T>, Error?> = Result.Failure(nil)
        let urlRequest: URLRequest = URLRequest(request: request)
        requestsPool.append(request)
        urlSession.sendSynchronousRequest(request: urlRequest) { [unowned self]
            data, urlResponse, error in
            self.removeFromPool(request: request)
            result = self.handleResponse(withData: data, urlResponse: urlResponse, error: error)
        }
        
        return result
    }
    
    public func get<T>(url: URL) -> Result<Response<T>, Error?> {
        let request = Request(URL: url)
        return self.executeRequest(request: request)
    }
    
    public func executeRequest<T>(request: Request,
                                  completionHandler: @escaping (Result<Response<T>, Error?>) -> Void) {
        let urlRequest: URLRequest = URLRequest(request: request)
        requestsPool.append(request)
        urlSession.dataTask(with: urlRequest) { [unowned self] (data, urlResponse, error) in
            self.removeFromPool(request: request)
            let result: Result<Response<T>, Error?> = self.handleResponse(withData: data,
                                                                          urlResponse: urlResponse,
                                                                          error: error)
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }.resume()
    }
    
    public func get<T>(url: URL,
                       completionHandler: @escaping (Result<Response<T>, Error?>) -> Void) {
        let request = Request(URL: url)
        return self.executeRequest(request: request, completionHandler: completionHandler)
    }
    
    private func removeFromPool(request: Request) {
        if let index = self.requestsPool.firstIndex(of: request)  {
            self.requestsPool.remove(at: index)
        }
    }
    
    private func handleResponse<T>(withData data: Data?, urlResponse: URLResponse?, error: Error?)
        -> Result<Response<T>, Error?> {
        var result: Result<Response<T>, Error?> = Result.Failure(nil)
        if let httpResponse = urlResponse as? HTTPURLResponse {
            let bodyObject: T? = self.parseBody(data: data as Data?)
            let response: Response<T> = Response(statusCode: httpResponse.statusCode,
                                                 body: data as Data?,
                                                 bodyObject: bodyObject,
                                                 responseHeaders: httpResponse.allHeaderFields,
                                                 url: httpResponse.url)
            if (httpResponse.statusCode / 100) == 2 {
                result = Result.Success(response)
            } else {
                let responseError = ResponseError<T>.error(fromResponse: response)
                result = Result.Failure(responseError)
            }
        } else {
            result = Result.Failure(error)
        }
        
        return result
    }
    
    /// Parses the response body data.
    ///
    /// - Parameter data: The data object which should be parsed.
    /// - Returns: The expected generic Object, nil when the data cannot be parsed.
    func parseBody<T>(data: Data?) -> T? {
        guard let dt = data else {
            return nil
        }

        for handler in self.responseHandlers {
            if handler.canHandle(responseType: T.self) {
                let temp: T? = handler.process(responseData: dt)
                if temp != nil {
                    return temp
                }
            }
        }

        return nil
    }
}

/// Extension of the NSURLSession that blocks the data task with semaphore, so we can perform
/// a sync request.
extension URLSession {
    func sendSynchronousRequest(
        request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        let task = self.dataTask(with: request) { data, response, error in
            completionHandler(data, response, error)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
}

/// Adapting our definition of the Request to the one from the iOS SDK.
extension URLRequest {
    
    public init(request: Request) {
        self.init(url: request.url as URL)
        self.httpMethod = request.method.rawValue
        self.allHTTPHeaderFields = request.headerFields
        self.httpBody = request.body as Data?
    }
    
    func matches(request: Request) -> Bool {
        return self.url!.absoluteString == request.url.absoluteString
            && self.httpMethod! == request.method.rawValue
            && self.allHTTPHeaderFields! == request.headerFields
            && self.httpBody == request.body
    }
}
