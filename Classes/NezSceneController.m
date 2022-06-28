//
//  NezSceneController.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/19/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezSceneController.h"
#import "NezScene.h"

@implementation NezSceneController

-(id)initWithScene:(NezScene*)aScene {
	if (self = [super init]) {
		scene = aScene;
	}
	return self;
}

-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed {
	[self updateWithFramesElapsed:timeElapsed*scene->framesPerSecond];
}

-(void)updateWithFramesElapsed:(float)framesElapsed {
	[scene updateWithFramesElapsed:framesElapsed];
}	

-(void)setView:(EAGLView*)view {
	screenWidth = view.bounds.size.width;
	screenHeight = view.bounds.size.height;
	parentView = view;

	float viewScale = parentView.window.screen.scale;
	scaledScreenWidth = screenWidth/viewScale;
	scaledScreenHeight = screenHeight/viewScale;
	
	[scene setScreenWidth:scaledScreenWidth Height:scaledScreenHeight];
}

-(void)invalidate {
	for (UIView *view in [parentView subviews]) {
		[view removeFromSuperview];
	}
}

@end
