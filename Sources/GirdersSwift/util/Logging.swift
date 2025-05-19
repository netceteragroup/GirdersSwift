import OSLog

public var Log = Logging()


/// Logger class implementing the LogProtocol.
public class Logging {
    
    let logger = Logger(subsystem: "com.github.GirdersSwift", category: "GirdersSwift")
    let thresholdLevel: LogLevel = {
        guard let rawLogLevel = Configuration.sharedInstance[Constants.LogLevel] as? Int,
              let level = LogLevel(rawValue: rawLogLevel) else {
            return .debug
        }
        return level
    }()
    
    public func debug(_ message: String) {
        log(.debug, message)
    }
    
    public func info(_ message: String) {
        log(.info, message)
    }
    
    public func error(_ message: String) {
        log(.error, message)
    }
    
    public func fault(_ message: String) {
        log(.fault, message)
    }
    
}

private extension Logging {
    
    func log(_ level: LogLevel, _ message: String) {
        guard level >= thresholdLevel else {
            return
        }
        logger.log(level: level.osLogType, "\(message)")
    }
    
}

private extension LogLevel {
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .error: return .error
        case .fault: return .fault
        }
    }
    
}
