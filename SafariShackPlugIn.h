//
//  SafariShackPlugIn.h
//  SafariShack
//
//  Created by Kyle Eli on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DOMDocument;

/* The SIMBL plugin principal class.
 */
@interface SafariShackPlugIn : NSObject {

}

/* Called when SIMBL loads the bundle.
 */
+ (void) load;

/* Creates a static instance of the plugin.
 */
+ (void) createPlugIn;

/* Returns true if the document is a chatty.
 */
+ (BOOL) isShackChattyDocument:(DOMDocument *)document;

@end
