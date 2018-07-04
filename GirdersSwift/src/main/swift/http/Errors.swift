
import Foundation

// Response errors for some common status codes. Extend the enumeration in case an unsupported
// code is needed.
//
// In case error message from the server needs to be supported, use enum with associated values.
public enum ResponseError<T>: Error {
    case BadRequest(response: Response<T>)
    case Unauthorized(response: Response<T>)
    case Forbidden(response: Response<T>)
    case NotFound(response: Response<T>)
    case MethodNotAllowed(response: Response<T>)
    case InternalServerError(response: Response<T>)
    case NotImplemented(response: Response<T>)
    case BadGateway(response: Response<T>)
    case Unknown(response: Response<T>)
}

extension ResponseError {
    public static func error(fromResponse response: Response<T>) -> ResponseError {
        switch response.statusCode {
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
        default:
            return .Unknown(response: response)
        }
    }
}
