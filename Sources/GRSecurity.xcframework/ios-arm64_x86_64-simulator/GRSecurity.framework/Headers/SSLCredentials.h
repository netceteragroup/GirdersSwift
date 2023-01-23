
#import <Foundation/Foundation.h>

/** Class responsible for managing the ssl credentials. */
@interface SSLCredentials : NSObject {
    NSArray *anchors;
    NSArray *keystores;
}

/**
 * Initialize the instance.
 * 
 * @param ancs The anchor certificates used for verifying the server cert.
 * @param keys Array of dictionaries containing the client identity.
 * The structure should be same as the one returned by the @a SecPKCS12Import function.
 * Hint: Check the @a toKeystoreArrayUsingPassword: method from the @a NSData+Security category. 
 */
- (nonnull id)initWithAnchors:(nullable NSArray *)ancs clientKeyStores:(nullable  NSArray *)keys;

/**
 * Initialize the instance.
 *
 * @param ca The anchor certificate (CA) to be used for validating the server cert.
 * @param idn A @a SecIdentityRef instance, representing the client's identity.
 * Check the @a identityRef: method in the @a GRKeychain class.
 */
- (nonnull id)initWithCA:(nullable  SecCertificateRef)ca identity:(nullable  SecIdentityRef)idn;

/** Returns anchor certificate to wich the server certifcate should be verified against*/
+ (nonnull SecCertificateRef)anchorFromData:(nullable  NSData *)data;

/**
 * Extrcat contents of a PKCS#12 formatted blob and add to array.
 * @param pkcs12Data is the PKCS#12 formatted blob
 * @param pass is the password for the PKCS#12 formatted blob
 * @return array containing a dictionary for every item extracted.
 */
+ (nullable NSArray *)keystoresFromData:(nullable  NSData *)pkcs12Data password:(nullable NSString *)pass;

/**
 * Determine whether we are able manually to respond to a provided form of authentication.
 * 
 * @param authMethod The provided form of authentication
 * @return the YES, 
 * or NO depending on the whether is able to respond to a provided form of authentication
 */
- (BOOL)canAuthenticateForAuthenticationMethod:(nonnull NSString *)authMethod;

/**
 * Sent when a connection is able to manually authenticate a challenge in order to download its request.
 * 
 * @param challenge The challenge that connection must authenticate in order to download its request
 * @return YES if authentication was successful, otherwise NO.
 */
- (nullable NSURLCredential *)credentialsForChallenge:(nonnull NSURLAuthenticationChallenge *)challenge;

- (nullable NSArray *)anchors;

@end

