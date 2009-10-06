//
//  LOL.m
//  SafariShack
//
//  Created by Kyle Eli on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LOL.h"
#import "Chatty.h"

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
	DOMHTMLElement *itemElement = (DOMHTMLElement *)
	[[[document getElementById:[@"item_" stringByAppendingString:threadId]] getElementsByClassName:@"div"] item:0];
	NSString *classes = [itemElement getAttribute:@"class"];
	/* fpmod_offtopic', 'fpmod_nws', 'fpmod_stupid', 'fpmod_informative', 'fpmod_political */
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
	NSString *link = [NSString stringWithFormat:@" [ <a id='%@%@' style='padding:0pt 0.25em;cursor:pointer;color:rgb(%@);text-decoration:underline;' onclick='lol.lolThreadId_withTag_forUser_withModeration_(\"%@\",\"%@\",\"%@\",\"%@\");'>%@</a> ] ",
					  tagName, threadId, color, threadId, tagName, username, [self moderationForThreadId:threadId inDocument:document], tagName];	
	
	element.innerHTML = [element.innerHTML stringByAppendingString:link];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
	NSString *messageString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if([messageString rangeOfString:@"ok "].location != NSNotFound)
	{		
		NSString *anchorId = [[messageString componentsSeparatedByString:@" "] objectAtIndex:1];
		
		WebFrame* frame = [_chatty.webView mainFrame];	
		if(![frame DOMDocument]) return;
		DOMDocument *document = [frame DOMDocument];		
		DOMHTMLElement *anchorElement = (DOMHTMLElement *)[document getElementById:anchorId];
		if(!anchorElement)
			return;

		NSRange threadIdRange = [anchorId rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
		NSString *tag = [anchorId substringToIndex:threadIdRange.location];
		anchorElement.innerText = [[tag uppercaseString] stringByAppendingString:@"'D"];
		[anchorElement setAttribute:@"onclick" value:@""];
		[anchorElement setAttribute:@"style" value:@"color:#f00;"];
		[anchorElement setAttribute:@"href"
							  value:[NSString stringWithFormat:@"http://lmnopc.com/greasemonkey/shacklol/?user=%@", _chatty.username]];
		
	} 
	else
		[self alert:messageString];	
}

- (void)lolThreadId:(NSString *)threadId withTag:(NSString *)tagName forUser:(NSString *)username withModeration:(NSString *)moderation
{					
	if([username isEqualToString:@""])
	{
		[self alert:@"You have to be logged in."];
	}
	
	_lastTag = tagName;
	
	NSString *requestString =
		[NSString stringWithFormat:@"http://lmnopc.com/greasemonkey/shacklol/report.php?who=%@&what=%@&tag=%@&version=20090826%@",
		 username, threadId, tagName, moderation];
	
	[[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestString]] delegate:self] start];
}

- (void)improveTheChatty:(Chatty *)chatty
{	
	_chatty = [chatty retain];
	
	DOMNodeList *postElements = [chatty.document getElementsByClassName:@"postmeta"];
	for(int elementIndex = 0; elementIndex < [postElements length]; elementIndex++)
	{	
		DOMHTMLElement *childElement = (DOMHTMLElement *)[chatty.document createElement:@"div"];
		[childElement setAttribute:@"style" value:@"display:inline;float:none;padding-left:10px;font-size:14px;"];
		DOMElement *postElement = (DOMElement *)[postElements item:elementIndex];
		NSString *threadId = [self threadIdForPostElement:(DOMHTMLElement *)postElement];
		
		[self addLinkForThreadId:threadId withTag:@"lol" withColor:@"255,136,0" forUser:chatty.username toElement:childElement forDocument:chatty.document];
		[self addLinkForThreadId:threadId withTag:@"inf" withColor:@"0,153,204" forUser:chatty.username toElement:childElement forDocument:chatty.document];
		[self addLinkForThreadId:threadId withTag:@"unf" withColor:@"255,0,0" forUser:chatty.username toElement:childElement forDocument:chatty.document];
		[self addLinkForThreadId:threadId withTag:@"tag" withColor:@"119,187,34" forUser:chatty.username toElement:childElement forDocument:chatty.document];
		[self addLinkForThreadId:threadId withTag:@"wtf" withColor:@"192,0,192" forUser:chatty.username toElement:childElement forDocument:chatty.document];

		[postElement appendChild:childElement];	
	}	
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector { return NO; }

@end
