//
//  ModMarker.h
//  SafariShack
//
//  Created by Kyle Eli on 10/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ShackImprovement.h"

@interface ModMarker : NSObject <ShackImprovement> {

	NSArray *_mods;
}

- (void) improveTheChatty:(Chatty *)chatty;

@end
