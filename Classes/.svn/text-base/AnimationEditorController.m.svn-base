//
//  AnimationEditorController.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/21/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "AnimationEditorController.h"
#import "SceneAnimationEditor.h"


@implementation AnimationEditorController

-(void)initializeControllers {
	SceneAnimationEditor *s = (SceneAnimationEditor*)scene;
	playbackBarController = [[NezPlaybackBarController alloc] initWithPlaybackBar:s.playbackBar];
	playbackBarController.delegate = self;
	
	controllerArray = [[NSMutableArray arrayWithCapacity:10] retain];
	[controllerArray addObject:playbackBarController];
}

-(BOOL)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	for (NezController *controller in controllerArray) {
		if ([controller touchesBegan:touches withEvent:event]) {
			return YES;
		}
	}
	return [super touchesBegan:touches withEvent:event];
}

-(BOOL)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	for (NezController *controller in controllerArray) {
		if ([controller touchesMoved:touches withEvent:event]) {
			return YES;
		}
	}
	return [super touchesMoved:touches withEvent:event];
}

-(BOOL)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	for (NezController *controller in controllerArray) {
		if ([controller touchesEnded:touches withEvent:event]) {
			return YES;
		}
	}
	return [super touchesEnded:touches withEvent:event];
}

-(BOOL)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	for (NezController *controller in controllerArray) {
		if ([controller touchesCancelled:touches withEvent:event]) {
			return YES;
		}
	}
	return [super touchesEnded:touches withEvent:event];
}

-(void)play {
	NSLog(@"play");
}

-(void)back {
	SceneAnimationEditor *s = (SceneAnimationEditor*)scene;
	[s decrementFrame];
}

-(void)foward {
	SceneAnimationEditor *s = (SceneAnimationEditor*)scene;
	[s incrementFrame];
}

-(void)start {
	NSLog(@"start");
}

-(void)end {
	NSLog(@"end");
}

-(void)dealloc {
	[controllerArray release];
	[super dealloc];
}

@end
