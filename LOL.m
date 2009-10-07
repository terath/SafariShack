//
//  LOL.m
//  SafariShack
//
//  Created by Kyle Eli on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Base64.h"
#import "Chatty.h"
#import "LOL.h"
#import "SafariShackPlugIn.h"
#import "ShortAlert.h"


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
	NSString *link = [NSString stringWithFormat:@"<a id='%@%@' style='padding:0pt 0.25em;cursor:pointer;color:rgb(120,120,120);background-color:none;border:1px solid rgb(120,120,120);text-decoration:none;-webkit-border-radius:4px' onmouseover='this.style.backgroundColor=\"rgb(%@)\";this.style.color=\"rgb(34,34,34)\";this.style.borderColor=\"rgb(34,34,34)\" ' onmouseout='this.style.backgroundColor=this.parentNode.style.backgroundColor;this.style.color=\"rgb(120,120,120)\";this.style.borderColor=\"rgb(120,120,120)\";' onclick='lol.lolThreadId_withTag_forUser_withModeration_(\"%@\",\"%@\",\"%@\",\"%@\");'>%@</a> ",
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
		[NSAlert alertWithMessageText:messageString];
	}
}

- (void)addLolCommentToolToDocument:(DOMDocument *)document
{	
	if([document getElementById:@"lol-link"])
		return;
	
	NSData *imageData = [NSData dataWithContentsOfFile:[_chatty.bundle pathForResource:@"lol" ofType:@"gif"]];
	
	// Add the lol-link image anchor.
	DOMHTMLElement *lolAnchor = (DOMHTMLElement *)[document createElement:@"a"];
	[lolAnchor setAttribute:@"style" 
					  value:[NSString stringWithFormat:@"background:#000 url(data:image/gif;base64,%@);"
							 "display:block;width:190px;height:45px;position:absolute;left:auto;right:0;"
							 "top:12px;textIndent:-9999px;color:#f00;", 
							 [[imageData encodeBase64] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

	[lolAnchor setAttribute:@"id" value:@"lol-link"];
	[lolAnchor setAttribute:@"href" value:[@"http://lmnopc.com/greasemonkey/shacklol/?user=" stringByAppendingString:_chatty.username]];
	[lolAnchor setAttribute:@"title" value:@"Check out what got the [lol]s"];

	DOMHTMLElement *commentsToolsElement = (DOMHTMLElement *)[[document getElementsByClassName:@"commentstools"] item:0];
	[commentsToolsElement appendChild:lolAnchor];
}

- (void)lolThreadId:(NSString *)threadId withTag:(NSString *)tagName forUser:(NSString *)username withModeration:(NSString *)moderation
{					
	// User must be logged in to lol.
	if([username isEqualToString:@""])
	{
		[NSAlert alertWithMessageText:@"You must be logged in to lol."];
		return;
	}	
	
	// Send a request to thomw's server to lol a thread.
	NSString *requestString =
		[NSString stringWithFormat:@"http://lmnopc.com/greasemonkey/shacklol/report.php?who=%@&what=%@&tag=%@&version=20090826%@",
		 username, threadId, tagName, moderation];
	
	[[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestString]] delegate:self] start];
}

- (void)addControlsToDocument:(DOMDocument *)document
{
	DOMNodeList *postElements = [document getElementsByClassName:@"postmeta"];
	for(int elementIndex = 0; elementIndex < [postElements length]; elementIndex++)
	{	
		DOMElement *postElement = (DOMElement *)[postElements item:elementIndex];
		if([postElement getElementsByClassName:@"lol_control"].length > 0) continue;
		
		DOMHTMLElement *childElement = (DOMHTMLElement *)[document createElement:@"div"];
		[childElement setAttribute:@"style" value:@"display:inline;float:none;padding-left:10px;font-size:14px;"];
		[childElement setAttribute:@"class" value:@"lol_control"];
		NSString *threadId = [self threadIdForPostElement:(DOMHTMLElement *)postElement];
		
		[self addLinkForThreadId:threadId withTag:@"lol" withColor:@"255,136,0" forUser:_chatty.username toElement:childElement forDocument:document];
		[self addLinkForThreadId:threadId withTag:@"inf" withColor:@"0,153,204" forUser:_chatty.username toElement:childElement forDocument:document];
		[self addLinkForThreadId:threadId withTag:@"unf" withColor:@"255,0,0" forUser:_chatty.username toElement:childElement forDocument:document];
		[self addLinkForThreadId:threadId withTag:@"tag" withColor:@"119,187,34" forUser:_chatty.username toElement:childElement forDocument:document];
		[self addLinkForThreadId:threadId withTag:@"wtf" withColor:@"192,0,192" forUser:_chatty.username toElement:childElement forDocument:document];
		
		[postElement appendChild:childElement];	
	}	
}

- (void)improveTheChatty:(Chatty *)chatty
{	
	_chatty = [chatty retain];
		
	WebView *webView = _chatty.webView;

	// Add the lol-link anchor to the right of the comments tools area.
	[self addLolCommentToolToDocument:[[_chatty.webView mainFrame] DOMDocument]];
	
	// Add this object to the scripting engine so that the page sends messages.
	WebScriptObject *scriptObject = [webView windowScriptObject];		
	if([[scriptObject evaluateWebScript:@"return lol"] isKindOfClass:[WebUndefined class]])
		[scriptObject setValue:self forKey:@"lol"];
	
	// Add lol tags to each post. Get the child frames also, so that the
	// posts loaded into the iframe get controls.
	[self addControlsToDocument:[[webView mainFrame] DOMDocument]];
	for(WebFrame *childFrame in [[webView mainFrame] childFrames])
		[self addControlsToDocument:[childFrame DOMDocument]];
}

/* Don't exclude the script callback from the scripting engine.
 */
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector 
{ 
	return aSelector == @selector(lolThreadId:withTag:forUser:withModeration:) ? NO : YES;
}

@end
