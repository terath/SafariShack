//
//  LOL.m
//  SafariShack
//
//  Created by Kyle Eli on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LOL.h"
#import "Chatty.h"
#import "SafariShackPlugIn.h"

@implementation LOL

- (id) init
{
	self = [super init];
	if (self != nil) {
		anchors = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[_chatty release];
	[anchors release];
	[super dealloc];
}


- (void) alert:(NSString *)message
{
	[[NSAlert alertWithMessageText:@"SafariShack" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:message] runModal];
}

- (NSString *)threadIdForPostElement:(DOMHTMLElement *)element
{
	// Get the thread id from the onClick event of the closepost anchor.
	DOMHTMLElement *closePostElement = (DOMHTMLElement *)[[element getElementsByClassName:@"closepost"] item:0];
	NSString *onClick = [closePostElement getAttribute:@"onClick"];
	NSRange functionCallRange = [onClick rangeOfString:@"close_post("];
	NSRange closeParenRange = [onClick rangeOfString:@")"];
	NSRange threadIdRange;
	threadIdRange.location = functionCallRange.location + functionCallRange.length;
	threadIdRange.length = closeParenRange.location - threadIdRange.location;
	return [onClick substringWithRange:threadIdRange];
}

- (NSString *)moderationForThreadId:(NSString *)threadId inDocument:(DOMDocument *)document
{
	// Read the moderation from the class of the first div (child node) in the thread item.
	DOMHTMLElement *itemElement = (DOMHTMLElement *)
	[[[document getElementById:[@"item_" stringByAppendingString:threadId]] getElementsByClassName:@"div"] item:0];
	NSString *classes = [itemElement getAttribute:@"class"];

	if([classes rangeOfString:@"fpmod_offtopic"].location != NSNotFound)
		return @"&moderation=fpmod_offtopic";
	else if([classes rangeOfString:@"fpmod_nws"].location != NSNotFound)
		return @"&moderation=fpmod_nws";
	else if([classes rangeOfString:@"fpmod_stupid"].location != NSNotFound)
		return @"&moderation=fpmod_stupid";
	else if([classes rangeOfString:@"fpmod_informative"].location != NSNotFound)
		return @"&moderation=fpmod_informative";
	else if([classes rangeOfString:@"fpmod_political"].location != NSNotFound)
		return @"&moderation=fpmod_political";
	else
		return @"";
}

- (void)addLinkForThreadId:(NSString *)threadId withTag:(NSString *)tagName withColor:(NSString *)color forUser:(NSString *)username toElement:(DOMHTMLElement *)element forDocument:(DOMDocument *)document
{
	// Format a lol link. Formatting swiped from thomw's shacklol script.
	NSString *link = [NSString stringWithFormat:@" [ <a id='%@%@' style='padding:0pt 0.25em;cursor:pointer;color:rgb(%@);text-decoration:underline;' onclick='lol.lolThreadId_withTag_forUser_withModeration_(\"%@\",\"%@\",\"%@\",\"%@\");'>%@</a> ] ",
					  tagName, threadId, color, threadId, tagName, username, [self moderationForThreadId:threadId inDocument:document], tagName];	
	
	element.innerHTML = [element.innerHTML stringByAppendingString:link];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
	// Get the reply from thomw's server.	
	NSString *messageString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	// Check the first three characters of the reply for a message indicating that the lol worked.	
	if([messageString rangeOfString:@"ok "].location == 0)
	{				
		// Grab the current document and make sure we're still looking at a chatty.		 
		DOMDocument *document = [[_chatty.webView mainFrame] DOMDocument];
		if(![SafariShackPlugIn isShackChattyDocument:document]) return;
		
		// Find the anchor tag used to lol.
		NSString *anchorId = [[messageString componentsSeparatedByString:@" "] objectAtIndex:1];				
		DOMHTMLElement *anchorElement = (DOMHTMLElement *)[document getElementById:anchorId];
		if(!anchorElement)
			return;

		// Modify the anchor text and change the url to point to the user's shacklol info page.
		NSRange threadIdRange = [anchorId rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
		NSString *tag = [anchorId substringToIndex:threadIdRange.location];
		anchorElement.innerText = [[tag uppercaseString] stringByAppendingString:@"'D"];
		[anchorElement setAttribute:@"onclick" value:@""];
		[anchorElement setAttribute:@"style" value:@"color:#f00;"];
		[anchorElement setAttribute:@"href"
							  value:[NSString stringWithFormat:@"http://lmnopc.com/greasemonkey/shacklol/?user=%@", _chatty.username]];
		
	} 
	else
	{
		// The lol failed. Display the reply as an alert box.
		[self alert:messageString];	
	}
}

- (void)lolThreadId:(NSString *)threadId withTag:(NSString *)tagName forUser:(NSString *)username withModeration:(NSString *)moderation
{					
	// User must be logged in to lol.
	if([username isEqualToString:@""])
	{
		[self alert:@"You have to be logged in."];
	}	
	
	// Send a request to thomw's server to lol a thread.
	NSString *requestString =
		[NSString stringWithFormat:@"http://lmnopc.com/greasemonkey/shacklol/report.php?who=%@&what=%@&tag=%@&version=20090826%@",
		 username, threadId, tagName, moderation];
	
	[[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestString]] delegate:self] start];
}

- (void)improveTheChatty:(Chatty *)chatty
{	
	_chatty = [chatty retain];
	
	WebView *webView = _chatty.webView;
	
	// Add this object to the scripting engine so that the page send messages.
	WebScriptObject *scriptObject = [webView windowScriptObject];		
	[scriptObject setValue:self forKey:@"lol"]; 	  

	// Add lol tags to each post.
	DOMDocument *document = [[webView mainFrame] DOMDocument];		
	DOMNodeList *postElements = [document getElementsByClassName:@"postmeta"];
	for(int elementIndex = 0; elementIndex < [postElements length]; elementIndex++)
	{	
		DOMHTMLElement *childElement = (DOMHTMLElement *)[document createElement:@"div"];
		[childElement setAttribute:@"style" value:@"display:inline;float:none;padding-left:10px;font-size:14px;"];
		DOMElement *postElement = (DOMElement *)[postElements item:elementIndex];
		NSString *threadId = [self threadIdForPostElement:(DOMHTMLElement *)postElement];
		
		[self addLinkForThreadId:threadId withTag:@"lol" withColor:@"255,136,0" forUser:chatty.username toElement:childElement forDocument:document];
		[self addLinkForThreadId:threadId withTag:@"inf" withColor:@"0,153,204" forUser:chatty.username toElement:childElement forDocument:document];
		[self addLinkForThreadId:threadId withTag:@"unf" withColor:@"255,0,0" forUser:chatty.username toElement:childElement forDocument:document];
		[self addLinkForThreadId:threadId withTag:@"tag" withColor:@"119,187,34" forUser:chatty.username toElement:childElement forDocument:document];
		[self addLinkForThreadId:threadId withTag:@"wtf" withColor:@"192,0,192" forUser:chatty.username toElement:childElement forDocument:document];

		[postElement appendChild:childElement];	
	}	
}

/* Don't exclude the script callback from the scripting engine.
 */
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector { if(aSelector == @selector(lolThreadId:withTag:forUser:withModeration:)) return NO; }

@end
