//
//  Base64.h
//  SafariShack
//
//  Created by Kyle Eli on 10/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <openssl/bio.h>
#include <openssl/evp.h>


@interface NSString (Base64)

- (NSData *) decodeBase64;
- (NSData *) decodeBase64WithNewlines: (BOOL) encodedWithNewlines;

@end

@interface NSData (Base64)

- (NSString *) encodeBase64;
- (NSString *) encodeBase64WithNewlines: (BOOL) encodeWithNewlines;

@end