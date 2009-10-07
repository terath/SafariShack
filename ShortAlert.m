//
//  ShortAlert.m
//  SafariShack
//
//  Created by Kyle Eli on 10/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ShortAlert.h"


@implementation NSAlert (ShortAlert)

+ (void) alertWithMessageText:(NSString *)messageText
{
	[[NSAlert alertWithMessageText:@"SafariShack" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:messageText] runModal];
}

@end
