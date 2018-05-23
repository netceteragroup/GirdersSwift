import Foundation
import PromiseKit

/// Extension of the standard HTTP with Promises.
public extension HTTP {
    
    func executeRequestAsync<T>(request: Request) -> Promise<Response<T>> {
        return Promise { seal in
            executeRequest(request: request,
                           completionHandler: { (result: Result<Response<T>, Error?>) in
                switch result {
                case .Failure(let error):
                    seal.reject(error!)
                case .Success(let data):
                    seal.fulfill(data)
                }
            })
        }
    }
    
}
