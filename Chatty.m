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

- (NSBundle *)getBundle
{
	NSString* pathToBundle = [[NSBundle mainBundle] pathForResource:@"SafariShack"
                                                             ofType:@"bundle"];
    return [NSBundle bundleWithPath:pathToBundle];
}

- (id) initForUsername:(NSString *)user withWebView:(WebView *)view;
{
	self = [super init];
	if (self != nil) {
		username = [user retain];
		webView = [view retain];
		bundle = [self getBundle];
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
