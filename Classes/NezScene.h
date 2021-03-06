//
//  NezScene.h
//  GmoLoader
//
//  Created by David Nesbitt on 9/7/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "NezCamera.h"
#import "NezBonedModelStructures.h"
#import "NezSceneController.h"

@interface NezScene : NSObject {
	float projectionMatrix[16];
	float modelViewMatrix[16];
	float modelViewProj[16];
	
	double time;
	double ticksPerFrame;

@public
	double framesPerSecond;
	float screenWidth, screenHeight;
	NezCamera *camera;
	NezSceneController *controller;
}

+(NSString*)getSceneName;

-(vec3)getInitialEye;
-(vec3)getInitialTarget;

-(id)initWithFPS:(double)fps;

-(void)makeController;

-(id)getNextSceneArguments:(NSString*)sceneName;

-(void)setScreenWidth:(float)w Height:(float)w;
-(void)setContext:(EAGLContext*)context WithArguments:(id)arguments;
-(void)updateWithFramesElapsed:(float)framesElapsed;
-(void)drawWithFrameBuffer:(GLuint)frameBuffer;
-(void)draw;
-(void)setAutoCameraDelay:(CFTimeInterval)delay;

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent *)event;

@end
