
import Foundation

public class JSONHandler: ResponseHandler {
    
    public init() {}
    
    public func canHandle<T>(responseType type: T) -> Bool {
        guard type is [String: Any].Type else {
            return false
        }
        return true
    }
    
    public func process<T>(responseData: Data) -> T? {
        guard T.self is [String: Any].Type else {
            return nil
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: responseData,
                                                           options: .allowFragments)
                as? [String: Any] {
                return json as? T
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
}
