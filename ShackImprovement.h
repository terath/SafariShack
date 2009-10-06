//
//  ShackImprovement.h
//  SafariShack
//
//  Created by Kyle Eli on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Chatty;

/* A protocol adopted by classes that improve the chatty.
 */
@protocol ShackImprovement

/* Called after the chatty finishes loading.
 */
- (void) improveTheChatty:(Chatty *)chatty;

@end
