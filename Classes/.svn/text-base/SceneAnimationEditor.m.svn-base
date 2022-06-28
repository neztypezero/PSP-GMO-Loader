//
//  SceneAnimationEditor.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/21/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "SceneAnimationEditor.h"
#import "AnimationEditorController.h"
#import "ModelNameAniIndexHolder.h"
#import "DataResourceManager.h"

@interface SceneAnimationEditor (private)

-(void)loadModels:(EAGLContext*)context WithModelName:(NSString*)modelName;

@end

@implementation SceneAnimationEditor

@synthesize playbackBar;

+(NSString*)getSceneName {
	return @"AnimationEditor";
}

-(vec3)getInitialEye {
	static vec3 v = {0.0f, 0.9f, 8.0f};
	return v;
}

-(vec3)getInitialTarget {
	static vec3 v = {0.0f, 0.9f, 0.0f};
	return v;
}

-(id)init {
	if (self = [super initWithFPS:THIRTY_FRAMES_PER_SECOND]) {
		mainModel = nil;
		playbackBar = nil;
	}
	return self;
}

-(void)makeController {
	controller = [[AnimationEditorController alloc] initWithScene:self];
}

-(void)setContext:(EAGLContext*)context WithArguments:(id)arguments {
	[super setContext:context WithArguments:arguments];
	ModelNameAniIndexHolder *modelInfo = arguments;

	NezBonedModel *modelData = [[DataResourceManager instance] loadModel:modelInfo->modelName ofType:@"gmo"];
	for (int i=2; i<modelData->partCount; i++) { //Only display the 1st 2 parts so set the others to invisible
		modelData->partArray[i].state = PART_INVISIBLE;
	}
	
	mainModel = [[NezAnimatedModel alloc] initWithModel:modelData];
	mainModel->loopAnimation = NO;
	
	animationIndex = modelInfo->animationIndex;
	[mainModel setMotion:animationIndex];

	playbackBar = [[NezPlaybackBar alloc] initWithScreenWidth:screenWidth Height:screenHeight];
}

-(void)draw {
	glViewport(0, 0, screenWidth, screenHeight);
	if (mainModel) {
		MatrixMultiply(projectionMatrix, [camera matrix], modelViewProj);
		[mainModel drawWithMatrix:modelViewProj];
	}
	if (playbackBar) {
		[playbackBar draw];
	}
}

-(void)incrementFrame {
	[mainModel updateWithFramesElapsed:1];
}

-(void)decrementFrame {
	[mainModel updateWithFramesElapsed:-1];
}

-(void)dealloc {
	[mainModel release];
	[playbackBar release];
	[super dealloc];
}

@end
