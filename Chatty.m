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

@synthesize username, webView, bundle;

- (id) initForUsername:(NSString *)user withWebView:(WebView *)view;
{
	self = [super init];
	if (self != nil) {
		username = [user retain];
		webView = [view retain];
		bundle = [NSBundle bundleForClass:[self class]];
	}
	return self;
}

- (void) dealloc
{
	[username release];
	[webView release];
	[super dealloc];
}


@end
