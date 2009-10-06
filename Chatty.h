//
//  Chatty.h
//  SafariShack
//
//  Created by Kyle Eli on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DOMDocument;
@class WebView;

/* Contains information about the chatty that may be useful across different improvements.
 */
@interface Chatty : NSObject {

	NSString *username;
	WebView *webView;
}

@property(readonly) NSString *username;
@property(readonly) WebView *webView;

- (id) initForUsername:(NSString *)user withWebView:(WebView *)view;

@end
