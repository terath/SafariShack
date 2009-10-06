//
//  Chatty.m
//  SafariShack
//
//  Created by Kyle Eli on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Chatty.h"
#include <WebKit/WebKit.h>

@implementation Chatty

@synthesize document, username, webView;

- (id) initWithDocument:(DOMDocument *)doc forUsername:(NSString *)user withWebView:(WebView *)view;
{
	self = [super init];
	if (self != nil) {
		document = [doc retain];
		username = [user retain];
		webView = [view retain];
	}
	return self;
}

- (void) dealloc
{
	[document release];
	[username release];
	[webView release];
	[super dealloc];
}


@end