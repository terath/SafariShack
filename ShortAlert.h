//
//  ShortAlert.h
//  SafariShack
//
//  Created by Kyle Eli on 10/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAlert (ShortAlert) 

+ (void) alertWithMessageText:(NSString *)messageText;

@end
