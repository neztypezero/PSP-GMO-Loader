//
//  NezSceneController.h
//  GmoLoader
//
//  Created by David Nesbitt on 9/19/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "EAGLView.h"
#import "NezController.h"

@class NezScene;

@interface NezSceneController : NezController {
	EAGLView *parentView;
	NezScene *scene;
	float screenWidth, screenHeight;
	float scaledScreenWidth, scaledScreenHeight;
}

-(id)initWithScene:(NezScene*)aScene;
-(void)setView:(EAGLView*)view;

-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed;
-(void)updateWithFramesElapsed:(float)framesElapsed;

-(void)invalidate;

@end
