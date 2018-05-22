/*
 * @(#) $$CVSHeader: $$
 *
 * Copyright (C) 2012 by Netcetera AG.
 * All rights reserved.
 *
 * The copyright to the computer program(s) herein is the property of
 * Netcetera AG, Switzerland.  The program(s) may be used and/or copied
 * only with the written permission of Netcetera AG or in accordance
 * with the terms and conditions stipulated in the agreement/contract
 * under which the program(s) have been supplied.
 *
 * @(#) $$Id: NSData+Security.h 718 2012-12-24 13:48:11Z zkuvendz $$
 */

#import <Foundation/Foundation.h>

@interface NSData (Security)

/** Creates a certificate object from a DER representation of a certificate. 
 * @return The certificate, or nil if the conversion failed.
 */
- (SecCertificateRef)toCertificateRef;

/** Returns the identities and certificates from a PKCS #12-formatted blob. 
 * @param pass The password for unlocking the keystore represented by this data. 
 * @return NSArray containing NSDictionaries, each representing one identity,
 * or nil if the import failed.
 */
- (NSArray *)toKeystoreArrayUsingPassword:(NSString *)pass;

/** Returns the issuer part of the data for this DER formated certificate. */
- (NSData *)issuerForDERCertificate;

/** Converts the data into hex string. */
- (NSString *)toHexString;

- (NSData *)md2;
- (NSData *)md4;
- (NSData *)md5;
- (NSData *)sha1;
- (NSData *)sha224;
- (NSData *)sha256;
- (NSData *)sha384;
- (NSData *)sha512;

@end
