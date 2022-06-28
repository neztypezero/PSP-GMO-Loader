//
//  NezBaseSceneView.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <UIKit/UIKit.h>
#import "NezCamera.h"
#import "NezBonedModelStructures.h"
#import "NezBaseSceneController.h"

#define NEZ_FRAMES_PER_SECOND 30

@interface NezBaseSceneView : UIView {
	float projectionMatrix[16];
	float modelViewMatrix[16];
	float modelViewProj[16];
	
	double time;
	double ticksPerFrame;
	
	BOOL firstLayout;
@public
	double framesPerSecond;
	float screenWidth, screenHeight, screenScale;
	NezCamera *camera;
}
@property (nonatomic, readonly, getter=getAnimationFrameInterval) NSInteger animationFrameInterval;

-(vec3)getInitialEye;
-(vec3)getInitialTarget;

-(void)loadSceneWithContext:(EAGLContext*)context andArguments:(id)arguments;
-(void)setContext:(EAGLContext*)context WithArguments:(id)arguments;
-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed;
-(void)drawWithFrameBuffer:(GLuint)frameBuffer;
-(void)draw;

-(double)getRandomNumber;

@end
