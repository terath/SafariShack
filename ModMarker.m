//
//  ModMarker.m
//  SafariShack
//
//  Created by Kyle Eli on 10/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "Chatty.h"
#import "ModMarker.h"


@implementation ModMarker

- (id) init
{
	self = [super init];
	if (self != nil) {
		_mods = [NSArray arrayWithObjects:@"4",	 // Steve Gibson
										  @"43653", // Maarten Goldstein
										  @"3259",	// degenerate
										  @"10028", // drucifer
										  @"168479", // ajax
										  @"5334", // dante
										  @"7438", // enigmatic
										  @"169489", // s[genjuro]s
										  @"8105", // hirez
										  @"5278",	// lacker
										  @"6674", // pupismyname
										  @"32016", // thekidd
										  @"1194", // zakk
										  @"171402", // brickmatt
										  @"6585", // carnivac
										  @"168256", // edgewise
										  @"169197", // filtersweep
										  @"9980", // haiku
										  @"44583", // jokemon
										  @"3243", // p[multisync]p
										  @"169049", // rauol duke
										  @"8349", // sexninja!!!!
										  @"6933", // tomservo
										  @"9085", // busdriver3030
										  @"8048", // cygnus x-1
										  @"6380", // dognose
										  @"167953", // edlin
										  @"12398", // geedeck
										  @"171127", // helvetica
										  @"7570", // kaiser
										  @"8316", // paranoid android
										  @"9031", // portax
										  @"9211", // redfive
										  @"7660", // sexpansion pack
										  @"169927", // sgtsanity
										  @"15130", // utilitymaximizer
										  @"172752",nil];  // chris remo
	}
	return self;
}

- (void) improveTheChatty:(Chatty *)chatty
{
	DOMDocument *document = [[chatty.webView mainFrame] DOMDocument];

	// Get existing style tag or create.
	BOOL hadStyleTag = YES;
	DOMHTMLElement *styleTag;	
	DOMNodeList *styleTags = [document getElementsByTagName:@"style"];
	if([styleTags length] == 0)
	{
		styleTag = (DOMHTMLElement *)[document createElement:@"style"];
		[styleTag setAttribute:@"type" value:@"text/css"];
		hadStyleTag = NO;
	}
	else
		styleTag = (DOMHTMLElement *)[styleTags item:0];

	if([styleTag.innerText rangeOfString:@"MOD MARKER"].location != NSNotFound)
		return;
	
	// Build a style for all mods.
	NSString *newStyle = @"#MOD MARKER\n";
	BOOL isFirstMod = YES;
	for(NSString *modId in _mods)
	{
		NSString *modStyle = [NSString stringWithFormat:@"div.olauthor_%@ a.oneline_user, .fpauthor_%@ span.author>a",
							  modId, modId];
		if(!isFirstMod)
			modStyle = [@", " stringByAppendingString:modStyle];
		else
			isFirstMod = NO;
		
		if(!newStyle)
			newStyle = modStyle;
		else
			newStyle = [newStyle stringByAppendingString:modStyle];
	}
	
	newStyle = [newStyle stringByAppendingString:@" { color: #af0 !important; }\n"];
	styleTag.innerText = [styleTag.innerText stringByAppendingString:newStyle];

	if(hadStyleTag) return;
	DOMHTMLElement *headTag = (DOMHTMLElement *)[[document getElementsByTagName:@"head"] item:0];
	[headTag appendChild:styleTag];
}

@end
