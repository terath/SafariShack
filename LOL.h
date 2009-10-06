//
//  LOL.h
//  SafariShack
//
//  Created by Kyle Eli on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "ShackImprovement.h"

@interface LOL : NSObject <ShackImprovement> {

	Chatty *_chatty;
	NSString *_lastTag;
	NSMutableDictionary *anchors;
}

- (void)improveTheChatty:(Chatty *)chatty;
- (void)lolThreadId:(NSString *)threadId withTag:(NSString *)tagName forUser:(NSString *)username withModeration:(NSString *)moderation;

@end
