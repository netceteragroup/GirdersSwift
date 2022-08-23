import SwiftyBeaver

import Foundation

/// Logger class implementing the LogProtocol.
public class Log : LogProtocol {
    
    private static var loggerLoaded = false
    
    private static func setupLogger() {
        let console = self.consoleDestination()
        if let logLevel = Configuration.sharedInstance[Constants.LogLevel] as? Int {
            let minLevel = SwiftyBeaver.Level.init(rawValue: logLevel)
            console.minLevel = minLevel ?? .debug
        } else {
            console.minLevel = .warning
        }
        SwiftyBeaver.addDestination(console)
        loggerLoaded = true
    }
    
    private static func consoleDestination() -> ConsoleDestination {
        let console = ConsoleDestination()
        console.levelColor.verbose = ""
        console.levelColor.debug = ""
        console.levelColor.info = ""
        console.levelColor.warning = ""
        console.levelColor.error = ""
        return console
    }
    
    private static func checkIfLoggerIsLoaded() {
        if !loggerLoaded {
            self.setupLogger()
        }
    }
    
    public static func verbose(_ string: String) {
        checkIfLoggerIsLoaded()
        SwiftyBeaver.verbose(string)
    }
    
    public static func debug(_ string: String) {
        checkIfLoggerIsLoaded()
        SwiftyBeaver.debug(string)
    }
    
    public static func info(_ string: String) {
        checkIfLoggerIsLoaded()
        SwiftyBeaver.info(string)
    }
    
    public static func warning(_ string: String) {
        checkIfLoggerIsLoaded()
        SwiftyBeaver.warning(string)
    }
    
    public static func error(_ string: String) {
        checkIfLoggerIsLoaded()
        SwiftyBeaver.error(string)
    }
    
    public static func fatal(_ string: String) {
        checkIfLoggerIsLoaded()
        SwiftyBeaver.error(string)
    }
}
