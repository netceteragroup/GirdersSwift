import Foundation
import GRSecurity
#if canImport(Combine)
import Combine
#endif

/// NSURLSession implementation of the HTTP protocol.
///
/// The requests are done synchronously. The logic behind the sync requests is that we can easily 
/// plug in RX extensions or promises to this implementation.
/// If you want to use it directly (without RX extensions or promises), you should do it in a 
/// background thread.
///
/// You can also use async requests with completion handler.
public class HTTPClient {
    
    fileprivate var cancelables = [Any]()
    fileprivate var responseHandlers: [ResponseHandler]
    fileprivate let sessionDelegate: DefaultSessionDelegate = DefaultSessionDelegate()
    fileprivate let urlSession: URLSession
    fileprivate var requestsPool: [Request] = [Request]() {
        willSet {
            lock.wait()
        }
        didSet {
            lock.signal()
        }
    }
    
    private let lock = DispatchSemaphore(value: 1)
    
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
        cancelables.removeAll()
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

#if canImport(Combine)
/// Combine extensions.
extension HTTPClient {
    
    @available(iOS 13, *)
    public func executeRequest<T>(request: Request) -> AnyPublisher<T, Error> where T: Decodable {
        let urlRequest: URLRequest = URLRequest(request: request)
        requestsPool.append(request)
        let publisher: AnyPublisher<T, Error> = urlSession.dataTaskPublisher(for: urlRequest)
            .mapError({ (error) -> Error in
                ResponseError<URLError>.error(from: error)
            })
            .flatMap(maxPublishers: .max(1)) { [unowned self] pair -> AnyPublisher<T, Error> in
                guard let httpResponse = pair.response as? HTTPURLResponse else {
                    return Future { promise in
                        promise(.failure(NSError.unknown))
                    }
                    .eraseToAnyPublisher()
                }
                
                if httpResponse.statusCode / 100 == 2 {
                   return self.decode(pair.data)
                }
                
                let response = Response<T>(statusCode: httpResponse.statusCode,
                                           body: pair.data,
                                           bodyObject: nil,
                                           responseHeaders: httpResponse.allHeaderFields,
                                           url: httpResponse.url)
                
                let responseError = ResponseError<T>.error(fromResponse: response)
                return Future { promise in
                    promise(.failure(responseError))
                }
                .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let cancelable = publisher.sink(receiveCompletion: { [weak self] (completion) in
            self?.removeFromPool(request: request)
        }) { (value) in
            Log.debug("Received value for request with url: \(request.url.absoluteString)")
        }
        
        cancelables.append(cancelable)
                
        return publisher
    }
    
    @available(iOS 13, *)
    public func executeDataRequest(request: Request) -> AnyPublisher<Data, Error> {
        let urlRequest: URLRequest = URLRequest(request: request)
        requestsPool.append(request)
        let publisher: AnyPublisher<Data, Error> = urlSession.dataTaskPublisher(for: urlRequest)
            .mapError({ (error) -> Error in
                ResponseError<URLError>.error(from: error)
            })
            .flatMap(maxPublishers: .max(1), { pair  in
                return self.dataPublisher(pair.data)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let cancelable = publisher.sink(receiveCompletion: { [weak self] (completion) in
            self?.removeFromPool(request: request)
        }) { (value) in
            Log.debug("Received value for request with url: \(request.url.absoluteString)")
        }
        
        cancelables.append(cancelable)
                
        return publisher
    }
    
    @available (iOS 13, *)
    public func executeDataRequest(request: Request) -> Future<Data, Error> {
        return Future<Data, Error> { [unowned self] promise in
            let urlRequest: URLRequest = URLRequest(request: request)
            self.requestsPool.append(request)
            self.urlSession.dataTask(with: urlRequest) { [weak self] (data, urlResponse, error) in
                self?.removeFromPool(request: request)
                
                if let error = error {
                    promise(.failure(error))
                    return
                }
                if let data = data {
                    promise(.success(data))
                }
                
                if let httpResponse = urlResponse as? HTTPURLResponse {
                    let response: Response<Data> = Response(statusCode: httpResponse.statusCode,
                                                         body: data as Data?,
                                                         bodyObject: nil,
                                                         responseHeaders: httpResponse.allHeaderFields,
                                                         url: httpResponse.url)
                    let responseError = ResponseError<Data>.error(fromResponse: response)
                    promise(.failure(responseError))
                    return
                }
                
                promise(.failure(NSError.unknown))
            }
            .resume()
        }
        
    }
    
    @available (iOS 13, *)
    public func executeRequest<T>(request: Request) -> Future<T, Error> where T: Decodable {
        return Future<T, Error> { [unowned self] promise in
            let urlRequest: URLRequest = URLRequest(request: request)
            self.requestsPool.append(request)
            self.urlSession.dataTask(with: urlRequest) { [weak self] (data, urlResponse, error) in
                self?.removeFromPool(request: request)
                
                if let error = error {
                    promise(.failure(error))
                    return
                }
                if let data = data {
                    do {
                        let model = try JSONDecoder().decode(T.self, from: data)
                        promise(.success(model))
                        return
                    } catch {
                        Log.debug("Error parsing the response")
                    }
                }
                
                if let httpResponse = urlResponse as? HTTPURLResponse {
                    let response: Response<T> = Response(statusCode: httpResponse.statusCode,
                                                         body: data as Data?,
                                                         bodyObject: nil,
                                                         responseHeaders: httpResponse.allHeaderFields,
                                                         url: httpResponse.url)
                    let responseError = ResponseError<T>.error(fromResponse: response)
                    promise(.failure(responseError))
                    return
                }
                
                promise(.failure(NSError.unknown))
            }.resume()
        }
    }
    
    @available(iOS 13, *)
    private func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, Error> {
        return Just(data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    @available(iOS 13, *)
    private func dataPublisher(_ data: Data) -> AnyPublisher<Data, Error> {
        return Future { promise in
            return promise(.success(data))
        }
        .eraseToAnyPublisher()
    }
    
}
#endif

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
