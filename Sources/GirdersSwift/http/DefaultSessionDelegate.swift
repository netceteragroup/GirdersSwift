
import Foundation

/// Defines a url session with default settings and verifies a session call with the accoring credentials.
public class DefaultSessionDelegate : NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    public weak var httpClient: HTTPClient?
    
    // MARK: - URL session task delegate
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition,
                                                         URLCredential?) -> Swift.Void) {
        guard let request = task.originalRequest else {
            return
        }
        
        guard let sslCredentials = httpClient?.credentialsForRequest(request: request) else {
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
            return
        }
        
        let authMethod = challenge.protectionSpace.authenticationMethod
        if sslCredentials.canAuthenticate(forAuthenticationMethod:authMethod) {
            if let credentials = sslCredentials.credentials(for: challenge) {
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, credentials)
            } else {
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
        }
    }
    
}

