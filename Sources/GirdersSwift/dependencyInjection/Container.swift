/// Specifies a lifetime of the object that needs to be created by the inversion of control container.
///
/// - Single: The object is a Singleton, i.e. it is created only once and that single instance is used.
/// - PerRequest: Each time an instance is requested, a new instance is created.
enum ObjectLifetime {
    case Single
    case PerRequest
}

import Foundation

/// Inversion of control container that can be used for resolving dependencies.
public class Container {
    /// Dictionary that contains mappings between protocol/class names and factory methods that should be used.
    static var factories = [String: Any]()
    
    /// Dictionary that contains mappings between protocol/class names and lifetimes of objects that are created.
    static var lifetimes = [String: ObjectLifetime]()
    
    /// Dictionary that contains mappings between protocol/class names and singleton instances created.
    static var singletonObjects = [String: Any]()
    
    /// Registers a factory for a specific protocol or class that should be called when a
    /// instance for a Singleton needs to be created.
    ///
    /// - Parameter factory: Factory method that should be used to create the instance.
    public static func addSingleton<T>(factory: @escaping () -> T) {
        let key = register(factory: factory)
        
        lifetimes[key] = .Single
    }
    
    /// Registers a factory for a specific protocol or class that should be called whenever an instance
    /// of the protocol/class is required.
    ///
    /// - Parameter factory: Factory method that should be used to create the instance.
    public static func addPerRequest<T>(factory: @escaping () -> T) {
        let key = register(factory: factory)
        
        lifetimes[key] = .PerRequest
    }
    
    /// Internal method that should be used to register a factory method.
    ///
    /// - Parameter factory: Factory method that should be registered.
    /// - Returns: Key of the registered factory method. Can be used to set a lifetime.
    fileprivate static func register<T>(factory: @escaping () -> T) -> String {
        let parameterType = type(of:T.self)
        let key = String(describing:parameterType)
        
        factories[key] = factory
        return key
    }
    
    /// Resolves a dependency of a specific type. Introduces a fatal error in case the
    /// requested type is not registered.
    ///
    /// - Returns: Resolved intance that either is a instance of the class or conforms to a specific protocol.
    public static func resolve<T>() -> T {
        let parameterType = type(of:T.self)
        let key = String(describing:parameterType)
        
        if let factory = factories[key] as? () -> T,
            let lifetime = lifetimes[key] {
            
            let result: T
            
            if (lifetime == .PerRequest) {
                result = factory()
            } else if let singleton = singletonObjects[key] as? T {
                result = singleton
            } else {
                result = factory()
                singletonObjects[key] = result
            }
            
            return result
        } else {
            fatalError("Registration not found")
        }
    }
    
    /// Resolves a dependency of a specific type. Throws an error if dependency is not found.
    ///
    /// - Returns: Resolved intance that either is a instance of the class or conforms to a specific protocol.
    public static func resolveOrThrow<T>() throws -> T {
        let parameterType = type(of:T.self)
        let key = String(describing:parameterType)
        
        if let factory = factories[key] as? () -> T,
            let lifetime = lifetimes[key] {
            
            let result: T
            
            if (lifetime == .PerRequest) {
                result = factory()
            } else if let singleton = singletonObjects[key] as? T {
                result = singleton
            } else {
                result = factory()
                singletonObjects[key] = result
            }
            
            return result
        } else {
            throw NSError(domain: "com.netcetera.GirdersSwift",
                          code: 02,
                          userInfo: ["Registration not found" : key])
        }
    }
    
    /// Removes all registrations and singleton instances. Very useful for testing.
    public static func cleanup() {
        factories.removeAll()
        lifetimes.removeAll()
        singletonObjects.removeAll()
    }
}
