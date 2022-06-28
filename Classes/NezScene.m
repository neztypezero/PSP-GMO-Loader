//
//  NezScene.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/7/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <mach/mach_time.h>

#import "NezScene.h"
#import "matrix.h"

@implementation NezScene

+(NSString*)getSceneName {
	return nil;
}

-(vec3)getInitialEye {
	static vec3 v = {0,0,0};
	return v;
}

-(vec3)getInitialTarget {
	static vec3 v = {0,0,0};
	return v;
}

-(id)initWithFPS:(double)fps {
	if (self = [super init]) {
		mat4f_LoadPerspective(FOV_60_DEGREES, 0.75f, 0.1f, 1000.0f, projectionMatrix);
		
		mat4f_LoadIdentity(modelViewMatrix);
		mat4f_MultiplyMat4f(projectionMatrix, modelViewMatrix, modelViewProj);

		camera = [[NezCamera alloc] initWithEye:[self getInitialEye] Target:[self getInitialTarget]];

		[self makeController];
		
		framesPerSecond = fps;

		mach_timebase_info_data_t sTimebaseInfo;
		mach_timebase_info(&sTimebaseInfo);
		
		ticksPerFrame = ((1000000000.0/fps)/((double)sTimebaseInfo.numer/(double)sTimebaseInfo.denom));
		
		time = 0;
	}
	return self;
}

-(void)setScreenWidth:(float)w Height:(float)h {
	NSLog(@"%f, %f", w, h);
	screenWidth = w;
	screenHeight = h;
	
	mat4f_LoadPerspective(FOV_60_DEGREES, w/h, 0.1f, 40000.0f, projectionMatrix);
	
	mat4f_LoadIdentity(modelViewMatrix);
	mat4f_MultiplyMat4f(projectionMatrix, modelViewMatrix, modelViewProj);
}
-(void)makeController {
	controller = [[NezSceneController alloc] initWithScene:self];
}

-(id)getNextSceneArguments:(NSString*)sceneName { return nil; }

-(void)setContext:(EAGLContext*)context WithArguments:(id)arguments {

}

-(void)update {
	uint64_t currentTime = mach_absolute_time();
	if (time > 0) {
		double dt = currentTime-time; // ticks that have gone by since last time upadte
		[self updateWithFramesElapsed:(float)(dt/ticksPerFrame)];
	}
	time = currentTime;
}

-(void)updateWithFramesElapsed:(float)framesElapsed {}

-(void)drawWithFrameBuffer:(GLuint)frameBuffer {
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);

	[self draw];
}

-(void)draw {}
-(void)setAutoCameraDelay:(CFTimeInterval)delay {}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {}
-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {}
-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {}
-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {}

-(void) dealloc {
	[camera release];
	if (controller) {
		[controller invalidate];
		[controller release];
	}
    [super dealloc];
}

@end
