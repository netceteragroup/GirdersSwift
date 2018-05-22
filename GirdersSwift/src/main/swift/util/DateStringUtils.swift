
import Foundation

extension Date {
    
    /// Converts the date to a String conforming to the RCF822 Standard and returns it.
    ///
    /// - Returns: The converted date as String.
    public func toRFC822String() -> String {
        return stringValue(withDateFormat: "EEE, dd MMM yyyy HH:mm:ss zzz")
    }
    
    /// Converts the date to a String conforming to the RCF3339 Standard and returns it.
    ///
    /// - Returns: The converted date as String.
    public func toRFC3339String() -> String {
        return stringValue(withDateFormat: "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'")
    }
    
    private func stringValue(withDateFormat dateFormat:String) -> String {
        let dateFormatter = Date.dateFormatter(withFormat: dateFormat)
        return dateFormatter.string(from: self)
    }
    
    /// Returns a date formatter with a given format.
    ///
    /// - Parameter format: The format used by the date formatter.
    /// - Returns: A DateFormatter object.
    static public func dateFormatter(withFormat format:String) -> DateFormatter {
        let currentThread = Thread.current
        let threadDictionary = currentThread.threadDictionary
        
        var formatter: DateFormatter? = threadDictionary.object(forKey: format) as? DateFormatter
        if formatter == nil {
            // "en_US_POSIX" is a locale that's specifically designed to yield US English results,
            // regardless of both user and system preferences
            let enUsPosix = Locale(identifier: "en_US_POSIX")
            formatter = DateFormatter()
            formatter!.locale = enUsPosix
            formatter!.timeZone = TimeZone(secondsFromGMT: 0)
            formatter!.dateFormat = format
            threadDictionary.setObject(formatter!, forKey: format as NSCopying)
        }
        
        return formatter!
    }
}

extension String {
    
    // Parses the string with the RFC 822 timestamp format.
    // See http://www.ietf.org/rfc/rfc0822.txt
    //
    // @return date if it is in the correct format
    //
    public func parseRFC822Timestamp() -> Date? {
        var date: Date?
        let rfc822String = self.uppercased()
        
        if rfc822String.contains(",") {
            if date == nil { // e.g. Sun, 19 May 2002 15:21:36 GMT
                date = self.dateValue(withDateFormat:"EEE, d MMM yyyy HH:mm:ss zzz")
            }
            
            if date == nil { // e.g. Sun, 19 May 2002 15:21 GMT
                date = self.dateValue(withDateFormat:"EEE, d MMM yyyy HH:mm zzz")
            }
            
            if date == nil { // e.g. Sun, 19 May 2002 15:21:36
                date = self.dateValue(withDateFormat:"EEE, d MMM yyyy HH:mm:ss")
            }
            
            if date == nil { // e.g. Sun, 19 May 2002 15:21
                date = self.dateValue(withDateFormat:"EEE, d MMM yyyy HH:mm")
            }
        } else {
            if date == nil { // e.g. 19 May 2002 15:21:36 GMT
                date = self.dateValue(withDateFormat: "d MMM yyyy HH:mm:ss zzz")
            }
            
            if date == nil { // e.g. 19 May 2002 15:21 GMT
                date = self.dateValue(withDateFormat: "d MMM yyyy HH:mm zzz")
            }
            
            if date == nil { // e.g. 19 May 2002 15:21:36
                date = self.dateValue(withDateFormat: "d MMM yyyy HH:mm:ss")
            }
            
            if date == nil { // e.g. 19 May 2002 15:21
                date = self.dateValue(withDateFormat: "d MMM yyyy HH:mm")
            }
            
            if date == nil {
                print("Could not parse RFC822 date: \(self). Possible invalid format.")
            }
        }
        
        return date
    }
    
    // Parses the string with the RFC 3339 timestamp format.
    // See http://www.ietf.org/rfc/rfc3339.txt
    //
    // @return date if it is in the correct format
    //
    public func parseRFC3339Timestamp() -> Date? {
        var date: Date?
        var rfc3339String = self.uppercased()
        rfc3339String = rfc3339String.replacingOccurrences(of: "Z", with: "-0000")
        
        if date == nil { // e.g. 1996-12-19T16:39:57-0800
            date = self.dateValue(withDateFormat: "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ",
                                  fromString: rfc3339String)
        }
        
        if date == nil { // e.g. // 1937-01-01T12:00:27.87+0020
            date = self.dateValue(withDateFormat: "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ",
                                  fromString: rfc3339String)
        }
        
        if date == nil { // e.g. 1937-01-01T12:00:27
            date = self.dateValue(withDateFormat: "yyyy'-'MM'-'dd'T'HH':'mm':'ss",
                                  fromString: rfc3339String)
        }
        
        if date == nil {
            print("Could not parse RFC3339 date: \(self). Possible invalid format.")
        }
        
        return date
    }
    
    private func dateValue(withDateFormat dateFormat:String, fromString string:String) -> Date? {
        let dateFormatter = Date.dateFormatter(withFormat: dateFormat)
        return dateFormatter.date(from: string)
    }
    
    private func dateValue(withDateFormat dateFormat:String) -> Date? {
        return self.dateValue(withDateFormat: dateFormat, fromString: self)
    }
}
