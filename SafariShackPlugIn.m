//
//  SafariShackPlugIn.m
//  SafariShack
//
//  Created by Kyle Eli on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SafariShackPlugIn.h"
#import <WebKit/WebKit.h>
#include "Chatty.h"
#include "LOL.h"

@implementation SafariShackPlugIn

- (void) alert:(NSString *)message
{
	[[NSAlert alertWithMessageText:message defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:message] runModal];
}

- (NSString *)usernameForDocument:(DOMDocument *)document
{
	DOMNodeList *usernameElements = [document getElementsByClassName:@"username"];
	
	if(usernameElements.length == 0)
		return @"";
	
	DOMHTMLElement *usernameElement = (DOMHTMLElement *)[usernameElements item:0];	
	return [usernameElement.innerText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

- (BOOL) isShackChattyDocument:(DOMDocument *)document
{
	NSString *url = [document URL];
	return [url rangeOfString:@"laryn.x"].location != NSNotFound;
}

- (void) progressFinished: (NSNotification*) n
{
    WebView* webView = [n object];
	WebFrame* frame = [webView mainFrame];
	if(![frame DOMDocument]) return;
	if(![self isShackChattyDocument:[frame DOMDocument]]) return;
	WebScriptObject *scriptObject = [webView windowScriptObject];	
	
	Chatty *chatty = [[[Chatty alloc] initWithDocument:[frame DOMDocument] forUsername:[self usernameForDocument:[frame DOMDocument]] withWebView:webView] autorelease];	
	LOL *lol = [[[LOL alloc] init] autorelease];
	
	[scriptObject setValue:lol forKey:@"lol"];	
	[lol improveTheChatty:chatty];
}

- (void) observeNotifications {

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];

    [center addObserver: self
               selector: @selector(progressFinished:)
                   name: WebViewProgressFinishedNotification
                 object: nil];

	NSLog(@"Observing WebKit notifications.");
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self observeNotifications];
	}
	return self;
}

+ (void) load
{
	[SafariShackPlugIn createPlugIn];	
	NSLog(@"SafariShack installed.");
}

+ (void) createPlugIn
{
	static SafariShackPlugIn *plugin;
	if(plugin == nil)
		plugin = [[SafariShackPlugIn alloc] init];
}

@end