//
//  NezPlaybackBarController.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/5/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezPlaybackBarController.h"


@implementation NezPlaybackBarController

@synthesize delegate;

-(id)initWithPlaybackBar:(NezPlaybackBar*)pbBar {
	if (self = [super init]) {
		playbackBar = [pbBar retain];
		delegate = nil;
	}
	return self;
}

-(BOOL)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	moved = NO;
	return NO;
}

-(BOOL)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	moved = YES;
	return NO;
}

-(BOOL)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if (!moved && delegate) {
		UITouch *touch = [touches anyObject];
		CGPoint nextTouch = [touch locationInView:touch.view];
		vec2 p = {nextTouch.x,touch.view.bounds.size.height-nextTouch.y};
		int buttonIndex = [playbackBar pointInButton:p];
		switch (buttonIndex) {
			case BUTTON_PLAY:
				[delegate play];
				break;
			case BUTTON_BACK:
				[delegate back];
				break;
			case BUTTON_START:
				[delegate start];
				break;
			case BUTTON_FORWARD:
				[delegate foward];
				break;
			case BUTTON_END:
				[delegate end];
				break;
			default:
				return NO;
		}
		return YES;
	}
	return NO;
}

-(void)dealloc {
	[playbackBar release];
	delegate = nil;
	[super dealloc];
}

@end
