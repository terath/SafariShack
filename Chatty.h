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

@interface Chatty : NSObject {

	DOMDocument *document;
	NSString *username;
	WebView *webView;
}

@property(readonly) DOMDocument *document;
@property(readonly) NSString *username;
@property(readonly) WebView *webView;

- (id) initWithDocument:(DOMDocument *)doc forUsername:(NSString *)user withWebView:(WebView *)view;

@end
