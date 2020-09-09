
import Foundation

// Response errors for some common status codes. Extend the enumeration in case an unsupported
// code is needed.
//
// In case error message from the server needs to be supported, use enum with associated values.
public enum ResponseError<T>: Error {
    case MovedPermanently(response: Response<T>)
    case Found(response: Response<T>)
    case SeeOther(response: Response<T>)
    case NotModified(response: Response<T>)
    case TemporaryRedirect(response: Response<T>)
    case PermanentRedirect(response: Response<T>)
    case BadRequest(response: Response<T>)
    case Unauthorized(response: Response<T>)
    case Forbidden(response: Response<T>)
    case NotFound(response: Response<T>)
    case MethodNotAllowed(response: Response<T>)
    case InternalServerError(response: Response<T>)
    case NotImplemented(response: Response<T>)
    case BadGateway(response: Response<T>)
    case ServiceNotAvailable(response: Response<T>)
    case GatewayTimeout(response: Response<T>)
    case NetworkAuthenticationRequired(response: Response<T>)
    case Unknown(response: Response<T>)
}

extension ResponseError {
    
    public static func error<T>(fromResponse response: Response<T>) -> ResponseError<T> {
        switch response.statusCode {
        case 301:
            return .MovedPermanently(response: response)
        case 302:
            return .Found(response: response)
        case 303:
            return .SeeOther(response: response)
        case 304:
            return .NotModified(response: response)
        case 307:
            return .TemporaryRedirect(response: response)
        case 308:
            return .PermanentRedirect(response: response)
        case 400:
            return .BadRequest(response: response)
        case 401:
            return .Unauthorized(response: response)
        case 403:
            return .Forbidden(response: response)
        case 404:
            return .NotFound(response: response)
        case 405:
            return .MethodNotAllowed(response: response)
        case 500:
            return .InternalServerError(response: response)
        case 501:
            return .NotImplemented(response: response)
        case 502:
            return .BadGateway(response: response)
        case 503:
            return .ServiceNotAvailable(response: response)
        case 504:
            return .GatewayTimeout(response: response)
        case 511:
            return .NetworkAuthenticationRequired(response: response)
        default:
            return .Unknown(response: response)
        }
    }
    
    public static func error(from urlError: URLError) -> ResponseError<URLError> {
        let response = Response<URLError>(statusCode: urlError.code.rawValue,
                                          body: nil,
                                          bodyObject: nil,
                                          responseHeaders: urlError.errorUserInfo,
                                          url: urlError.failingURL)
        return error(fromResponse: response)
    }
    
}
