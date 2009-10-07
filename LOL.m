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

- (void)addLolCommentToolToDocument:(DOMDocument *)document
{	
	if([document getElementById:@"lol-link"])
		return;
	
	// Add the lol-link image anchor.
	DOMHTMLElement *lolAnchor = (DOMHTMLElement *)[document createElement:@"a"];
	[lolAnchor setAttribute:@"style" 
					  value:@"background:#000 url(data:image/gif;base64,R0lGODlhvgAtAPcAAAAAAAsGFhkAABIFGBcUGA4OJxAOJxgXJRocMx0iPDkBAiENJyMaJigcMTAdKzEfMSYiKCcmOC4yNjMpLjQpODYzOikoRCwwSC4yUjQtRTUzSTk4VTw9YztBWFMAAFIcK0MhKkEnNlchL1gqOVgwPn0AAHUUPmUnN3AhNUkuQkg2SkQ8WVA9WEg9YFU8YmQ1SHknRHI4XUpASkhDWkBSXFVETVpEV1hXW0dHZkdLcExRbUtTc1ZKZ1xOclhWalRZeFhhd2lBS2BIXGRRXnpGWWlLaGJPcWpSbGdUcnVEbHNVa3Vad2xub2dke3Brbn9hcnFzc05ZgFZcgkpqlFlihltok2Neh2VniWNskmlzjGd0mnloh3Fvlnd5iHd4mWp8pGZ6tXJ9o3aCmmyBpmyDtnSEqXmJtHWVrXqVv16F0naQxnKY43uy95gAAIMUO7oAAJUaR4wlSYQ3S4s0VZ44TbkdTKwqWKg7VLMrXLY8U7w%2BYYZCWIJJbYRUZ4JceJZMZ5dUaZ9cd4pmeIR3fJFofKpEXL5CXatVbq1qe9UAAP0AAOQ2bMRHYchHcshYaspZdtBBcNRaecxjeNdned1wfOpJe%2BFqf%2BFxfpFvioN8oapyjKN%2Bq8tsmsB1icp1l9xrhdxnlttxh9B0nO5Whu5tmut7iel8k%2FNlj%2FlkmPhzmPh1qZSPk4aIqYGJt4mRq4eVuJmXp5KctoCjuZuhva%2BCl7KOqKysrKGluLOzs4Wayo6jyIai2ZWlzZSp1ZKzwZ6x1Yyw6qucyqOpx66q2qq0yai427ukybC40qq345LM%2FKPL%2FK3W97bH57fQ67Ta%2FqLk%2F8yAi8iFk9WJlNiTncKNqMeUp8qbttaKo9eYp9WYss2kuNekueqGnuGSmfeImeabpfKPov6Nsf2YqPWWu%2ByotsWew9SxysG54%2F%2BWwOS2y%2Bu40fKpyfe0xPG92svLy8PH2MvT2tHGzNvC2dTX18zS8M%2Fp%2FOvAz%2BvG2PnH2PrT3fjU6OLk6e3w%2BPzg6%2F3o9%2F7%2B%2FiwAAAAAvgAtAAAI%2FgABCBxIsKBBgzUwHVzIsKHDhxAjSpxIsaJFi5qoybjIsaPHjyBDfoQwQdu2GiJTqlzJsiVDQu3UQXBJs6bNmw4JUFOIs6fPnykHmasAtKjRow8h3NOGtKlTjgGUqIAa756gp1izPpyAiRaBmRVX5UvHQGKAPqJUgQpUI4DWtzSHaMpGLUVOtwX73bv3r6%2Ffv4D%2F9VN1ClUqVKrQ6QvMuLHjx5AjS55MubJlAE%2FMWZvQsMIWGWAFMvGXzp9ldaIWqUJVCVW4fJZjy55Nu%2FZsAAEIEdJU9qCM3YSM9A6wLF21igGckCBVaVSlU%2BPwwp3use%2FAIbXSrdpIkMARbNdo%2FrmgINAXm2CEkK8bhxjVqFSpCFCfz9H6wBrZ9dWSDsEFJk2a0EKULGyskQt3EVUARRe0jOKcg5UsUsNV9FUokX0DTSAINfcMNRAEmgQSSCcynJHMGmmoEQFEAUABTz3O%2FBLMKHjAAYcdjeSoh3QW9rgQhgMFYAM19uijCw0z2RBDDIgEw0YybKSxwUI3rIKLO7ZAMA%2BMyigDTCubQFIHHG6YYIIbcfio5o%2F%2FLARiNcM8CQwaggSiCTBPJrPLAQRIoEEHG2gQgQ%2F8%2FLUPl8kAA8wurZiBCR9zxOGGGw6k5IEHC5VQggAQCVDCG2%2B0gelCHpSggEOackqQp5q2qupB%2Fp6%2BahGQBTGw2xpsyOkFGooC08srrGSCBRZXWGHFFVdgwQUrwsBDjzPLeKnoLrvkgoYZZZTByiYicQoqALIKpIgipzrkwbjoKpJIuAK9oUgJDo1b7kAKpIsuvAYJUK8C7F7YJkMEGAFGGmwAswmAhPDhggs8HPGHCz34scTESyhxRAsc4CCFFrksSu3Hu%2FSSSy671LNKSCUkAmoi%2BBIkr0P1quuBAimre5C7LS%2F0MkExt5rIuKMOJIAibRCtSL8Q0XpQBwMXjEwxxmwixQ89IOFJElvUovUmtPiBRAsbWCD2BjtwDHLIY7TCDDP03CCBfB3RPG4b8w60M0M%2Fv8Hz%2Ft0D4eyQu%2BHGTJC7iRTkKeGbXqT0QQeQgWsykD8DeTLFXEONJvJkrrk5XIQttgUX5GDGyCTnQoYuxfzyCz3vsC6BR28kovJBfOdbu98F4c5QqQYJTu%2B4gSfSRiJ1U7T4QTMgA8zkzzSfjDLljGPMP%2F70o08%2F%2FvgjjBcdgI4BDjtUocsvIveCBi%2BtfDEGsA3wCEQWREkkwBsKKPAGu7UX5DtBJSiid%2B7vssj%2BxEWugnigDQAQVX3%2B9ZBA7OMc9KAHjJyXDH1wYhim6Ys%2FqFGLTLjiChjAAAdyEAXx8YIXutBFtr6ghWFd4QAF0cUrvBA%2FkORvb4owSP%2F%2BN7gAVmSA%2FgC44UeOVxACkIN61dNHOnK1qHVgIhjfsEY5NHMNRPAACF74AQ5IWAUwkEENuZChFrRQBi1Q4Yy9GYgGmtAFIIhEiAKJWbiKxsO%2B%2BZAiAxxaAVdCRIKEIB%2FZ6ws%2BTFEFMnjBGJ7IxCzIkY1qUIMa0YAGITbQA1f8YAdUKKQaNmktLajvB2eUQhoHIgEsSOGNe8TbHcH1s5y1a5USGeC5csiSPg5kBPoI5D%2FYEYoeeMEL2TiEFLxQjWhU45jTgAYtWIADVriCClKowhc2qYZe7MIMWmjGFKqABSDAsCBieMUPUFk8gxSNeAKZn7rYpbuJ7E8BP0NgLRnYkBFkD3v%2F%2FgCHJJCwhSNwoxBe0AIXmkALbERyGtPABA5%2BgEUshMEMaKDmyHpBjGNUAVgG8UEuzNABVNqLlqv6mbpiB7SbfTSVDYmZvdbVElsKRAT4uKc%2FQnEIFdhACDSVQhay4AVpTIMc5JiGNKLBAx%2F8QApScGgYxlCGMXiyhVjQgi54UUMJiEENaKjCN214UlgVDV2JCBoAP1rOg6h0XMJDGkhcCoAPoKMf1MPHHkZwgAYI4hGH2IEUqMAFoJIjH%2BToBjYwMQOj%2FuCwiL3kDnSQgx1gwQxg3GguNokGLFgAKfVT65oAwNYTiIMd1GvHAgYQgAEgwhGA2MFRqZCNb0zjG67t%2FoYmWMCDH%2FhABzrAgW5bsIINhDAHGxsZNa9FhQtstkJslYM4xIEPdpBjtANQgCQeAYjEbgEf5PCpNKShCSGogAc8wAFve4uBC2jAAhvAQQmzZQYzfAELOFjRcenD1kJ8YrnLhe4JHEGJ6iJ2B1sQRCew8Q1sYEMQNlDBBhYcKA1oYAMt6AACMtCBxu5gBznoQATgNt%2F5uHQAk4iEN7yxXAoMYAB%2FcMQk%2BqBaxeY2GunQhz46oQlE9CEED4iABi4gNvOuQAUOOAADGoAABByARx2mjktBwI5PmILE4uiDCohgiFJIogg6uPBiF0sIfPTDHuTABiBSkIIRmPkBCEiA%2Fo7Ti6Akq8mlI8DHNbgBZW%2BY4hKMsIQjXJCDLF9YCsgqQjSwsY0i5CAHHEhBEF5A2gAYYAYB0EAD3LxZts5BDi8Q8YhLQQlH5IEOLdAt%2BPYahjBQwQ%2Fa2AIWqnBGKsQCFg0wQAEMgIN9FMo2uM61rncdGYkA4QiPMEUpSjEJFaMAwroFJRWwUAYpMFV9Tf0CPN5hgQgcIM1duMWtec3tbns7NhGRQCyugARASGISjLgDDDQQ6mTvddllaEUZsABNT86iCRGIgAESsAFYwMIHlA74QgIQTiow1AcJXsEK2h3qo%2B61CmWoQhQwzAFQ7iAFGz6ABTRAAQggWeABPwAvjcxgyh344OThHS%2BDF%2BrwS%2BYABxjY%2BA9WoAG3CJnDIM85AIjBDDP%2BIActmEHKe%2BvgC0QAvbjNLQ5oboGy6HiUOo86AGIx7ygAvbwamAHRM5CBfOc7AzMAW6Ai8HGpmx0HZ8ztBngcAQhEgAIZcLAGMkCBCDBAPgTgk9n3bhAJFBYHgar2VvlO%2BMIbPiQBAQA7)"
	 ";display:block;width:190px;height:45px;position:absolute;left:auto;right:0;top:12px;textIndent:-9999px;color:#f00;"];

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
		[self alert:@"You have to be logged in."];
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
