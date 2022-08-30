import Foundation
import GRSecurity

private let ClientP12Key = "clientP12"
private let ClientP12PasswordKey = "clientP12Password"
private let CaServerKey = "caServer"

/// Loads the required certificate data from the configuration.
///
/// - Returns: An instance of a X.509 certificate containing the loaded data.
/// Nil if the data is invalid or the according data could not be found in the configuration.
func anchorsFromConfiguration() -> [SecCertificate]? {
    guard let caServerName = Configuration.sharedInstance[CaServerKey] as? String else {
        return nil
    }
    
    guard let caPath = Bundle.main.path(forResource: caServerName, ofType: nil) else {
        return nil
    }
    do {
        let caData: NSData = try NSData(contentsOfFile: caPath)
        let cert = caData.toCertificateRef() as Unmanaged<SecCertificate>
        return [cert.takeUnretainedValue()]
    } catch {
        return nil
    }
}

/// Loads the PKCS#12 data and the accoring password from the configuration.
///
/// - Returns: An array containing a dictionary of the extracted data.
/// Nil if the data is invalid or the according data could not be found in the configuration.
func clientKeyStoresFromConfiguration() -> [Any]? {
    guard let password = Configuration.sharedInstance[ClientP12PasswordKey] as? String,
        let clientP12 = Configuration.sharedInstance[ClientP12Key] as? String else {
            return nil
    }
    
    guard let p12Path = Bundle.main.path(forResource: clientP12, ofType: nil) else {
        return nil
    }
    
    do {
        let p12Data = try NSData(contentsOfFile: p12Path) as Data
        return SSLCredentials.keystores(from: p12Data, password: password)
    } catch {
        return nil
    }
}
