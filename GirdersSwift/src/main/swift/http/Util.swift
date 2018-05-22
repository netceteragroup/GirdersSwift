import Foundation

precedencegroup ForwardPipe {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator |> : ForwardPipe

/// Swift implementation of the forward pipe operator from F#.
///
/// Used for better readibility when piping results of one function to the next ones.
/// More details here: https://goo.gl/nHzeS6.
public func |> <T, U>(value: T, function: ((T) -> U)) -> U {
    return function(value)
}

/// Used for merging dictionaries.
public func += <KeyType, ValueType> ( left: inout Dictionary<KeyType, ValueType>,
         right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

extension URL {
    
    /// Appends a given query string to an existing URL.
    public func appendQueryString(queryString: String) -> URL? {
        guard !queryString.utf16.isEmpty else {
            return self
        }
        
        let URLString: String
        var queryURLString = queryString
        var absoluteURLString = self.absoluteString
        
        if absoluteURLString.hasSuffix("?") {
            absoluteURLString = absoluteURLString[0 ..< absoluteURLString.utf16.count-1]
        }
        
        if(queryString.hasPrefix("?")) {
            queryURLString = queryURLString[1 ..< queryURLString.utf16.count]
        }
        
        URLString = absoluteURLString
            + (absoluteURLString.range(of: "?") != nil ? "&" : "?")
            + queryURLString
        
        return URL(string: URLString)
    }
    
}

extension String {
    
    /// Creates an url encoded representation of the string.
    public func urlEncodedStringWithEncoding() -> String {
        var allowedCharacterSet = NSMutableCharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        allowedCharacterSet.insert(charactersIn: "[]")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
        
    }
    
    internal func indexOf(sub: String) -> Int? {
        guard let range = self.range(of: sub), !range.isEmpty else {
            return nil
        }
        return distance(from: self.startIndex, to: range.lowerBound)
    }
    
    internal subscript (r: Range<Int>) -> String {
        get {
            let startIndex = index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return String(self[startIndex..<endIndex])
        }
    }
    
}

extension Dictionary {
    
    /// Used to create an url encoded string from a dictionary
    ///
    /// - Parameter encoding: The specific encoding type of th
    public func urlEncodedQueryStringWithEncoding(encoding: String.Encoding) -> String {
        var queryItems = [URLQueryItem]()
        var urlComponents = URLComponents()
        
        for (key, value) in self.nilValuesRemoved {
            let keyString: String = "\(key)".urlEncodedStringWithEncoding()
            let valueString: String = "\(value)".urlEncodedStringWithEncoding()
            queryItems.append(URLQueryItem(name: keyString, value: valueString))
        }
        urlComponents.queryItems = queryItems
        
        return urlComponents.query!
    }
    
    /// Unwraps the value type of the dictionary and removes the nil entries.
    var nilValuesRemoved: [Key: Any] {
        return (self as [Key: Any?]).reduce([Key : Any]()) { (dict, e) in
            guard let value = e.1 else { return dict }
            var dict = dict
            dict[e.0] = value
            return dict
        }
    }
    
}
