
/// Protocol representing the different type of logging.
public protocol LogProtocol {
    
    /// Logs verbose data
    ///
    /// - Parameter string: The data to be logged as string.
    static func verbose(_ string: String)
    
    /// Logs info data
    ///
    /// - Parameter string: The data to be logged as string.
    static func debug(_ string: String)
    
    /// Logs info data
    ///
    /// - Parameter string: The data to be logged as string.
    static func info(_ string: String)
    
    /// Logs warning data
    ///
    /// - Parameter string: The data to be logged as string.
    static func warning(_ string: String)
    
    /// Logs error
    ///
    /// - Parameter string: The data to be logged as string.
    static func error(_ string: String)
    
    /// Logs fatal error
    ///
    /// - Parameter string: The data to be logged as string.
    static func fatal(_ string: String)
}
