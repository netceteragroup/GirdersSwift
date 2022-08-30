
import Foundation

/// Util class for accessing the settings in the Configuration.plist file, depending on the current
/// configuration.
public class Configuration {
    
    public static let sharedInstance = Configuration()
    
    public let defaultConfiguration: [String : Any]?
    public let modeConfiguration: [String : Any]?
    public let serialQueue = DispatchQueue(label: "SerialQueue")
    

    public init(bundle: Bundle = Bundle.main) {
        let configFileName = plistPath(forResource: "Configuration", bundle: bundle)
        let envConfigName = plistPath(forResource: "Configuration-env", bundle: bundle)
        
        var modeConfig: [String : Any]?
        
        guard let configName = configFileName else {
            self.defaultConfiguration = nil
            self.modeConfiguration = nil
            return
        }
        
        if (envConfigName != nil && !isReleaseConfig()) {
            modeConfig = loadConfig(fromResource: envConfigName!, bundle: bundle)
        }
        
        self.defaultConfiguration = loadConfig(fromResource: configName, bundle: bundle)
        self.modeConfiguration = modeConfig
    }
    
    /// Returns an object for a given key.
    ///
    /// - Parameter key: The key used to find the object.
    /// - Returns: The object or nil if no object can be found for the given key.
    public func get(key: String?) -> Any? {
        guard let keyPath = key else {
            return nil
        }
        
        var result: Any?
        serialQueue.sync {
            result = modeConfiguration?[keyPath]
            if result == nil {
                result = defaultConfiguration?[keyPath]
            }
            
            if let string = result as? String {
                if string.hasSuffix("URL") || string.hasSuffix("URI") {
                    result = URL(string: string)
                }
            }
        }
        
        return result
    }
    
    /// Convenience subscript to return a configuration value for a given key.
    ///
    /// - Parameter key: The key for the value to be returned.
    /// - Returns: An object for a given key, or nil if object could not be found.
    public subscript(key: String) -> Any? {
        get {
            return get(key: key)
        }
    }
}
