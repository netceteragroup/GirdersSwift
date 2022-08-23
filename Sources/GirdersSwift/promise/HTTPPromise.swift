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
                                if error!.isCancelled {
                                    seal.reject(self.canceledErrorForRequest(request))
                                } else {
                                    seal.reject(error!)
                                }
                            case .Success(let data):
                                seal.fulfill(data)
                            }
            })
        }
    }
    
    func canceledErrorForRequest(_ request: Request) -> Error {
        return NSError(domain: "com.netcetera.GirdersSwift",
                code: 01,
                userInfo: ["The request was canceled" : request])
    }
    
}
