import Foundation

/// Loads a configuration dictionary for a given resource and bundle.
///
/// - Parameter resource: The resource where the configuration is located.
/// - Parameter bundle: The bundle where the resource is located. Default bundle is the main bundle.
/// - Returns: A configuration as dictionary or nil when no configuration could be found.
public func loadConfig(fromResource resource: String, bundle: Bundle = Bundle.main) -> [String : Any] {
    let resource = resource as NSString
    let filename = resource.lastPathComponent as NSString
    let url = bundle.url(forResource: filename.deletingPathExtension,
                              withExtension: resource.pathExtension)
    
    guard let pathUrl = url else {
        return [:]
    }
    
    do {
        let data = try Data.init(contentsOf: pathUrl)
        let dict = try PropertyListSerialization.propertyList(from: data,
                                                              options: [],
                                                              format: nil) as? [String : Any]
        return dict ?? [:]
    } catch {
        Log.error("error loading configuration")
        return [:]
    }
}

/// Returns the plist path as a string for a given resource and bundle.
///
/// - Parameter resource: The resource where the configuration is located.
/// - Parameter bundle: The bundle where the resource is located. Default bundle is the main bundle.
/// - Returns: A configuration as dictionary or nil when no configuration could be found.
public func plistPath(forResource resource: String, bundle: Bundle = Bundle.main) -> String? {
    let plistPath = bundle.path(forResource: resource, ofType: "plist")
    return plistPath
}

/// Checks if configuration is for release.
///
/// - Returns: True if not in debug mode, flase otherwise.
public func isReleaseConfig() -> Bool {
    #if DEBUG
        return false
    #else
        return true
    #endif
}

public func envConfigFileName() -> String? {
    
    if let path = plistPath(forResource: "Info") {
        if let resourceFileDictionary = NSDictionary(contentsOfFile: path) {
            if let envConfigName = resourceFileDictionary.object(
                forKey: "ConfigurationFileName") as? String {
                return envConfigName
            }
        }
    }
    
    return nil
}
