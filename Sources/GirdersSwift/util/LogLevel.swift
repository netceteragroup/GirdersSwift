enum LogLevel: Int {
    
    case debug = 0
    case info = 1
    case error = 2
    case fault = 3
    
}

extension LogLevel: Comparable {
    
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
}
