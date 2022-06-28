//
//  NezAnimatedModel.h
//  GmoLoader
//
//  Created by David Nesbitt on 9/8/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezBonedModel.h"


@interface NezAnimatedModel : NSObject {
@public
	NezBonedModel *model;

	Bone *boneArray;
	int boneCount;

	int currentMotion;
	float currentFrame;
	BOOL loopAnimation;
	
	id callbackObject;
	SEL animationFinishedCallback;
}

-(id)initWithModel:(NezBonedModel*)modelObject;
-(void)setMotion:(int)motionIndex;
-(void)setAnimationFinishedCallback:(id)obj Selector:(SEL)callback;
-(void)setCurrentFrame:(float)frame;
-(void)updateWithFramesElapsed:(float)framesElapsed;
-(void)drawWithMatrix:(float*)matrix;
-(void)drawWithMatrix:(float*)matrix andProgram:(GLSLProgram*)program;

-(void)getCameraLookatPosition:(vec4*)outPos;

@end
