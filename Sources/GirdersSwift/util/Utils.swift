import Foundation

/// Function that tries to translate a key from the trema file.
///
/// If a key doesn't exist, it returns the key wrapped in question marks.
public func translate(_ key: String,
               _ args: CVarArg...,
    bundle: Bundle = Bundle.main) -> String {
    let defaultText = "?\(key)?"
    
    let stringFromFile = bundle.localizedString(forKey: key,
                                                value: defaultText,
                                                table: "messages")
    
    if (stringFromFile == "") {
        print("Could not load messages.strings! Have you included it in the bundle?")
        return defaultText
    }
    
    return String(format: stringFromFile, arguments: args)
}
