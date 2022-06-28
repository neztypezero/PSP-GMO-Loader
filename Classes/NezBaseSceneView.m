//
//  NezBaseSceneView.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <mach/mach_time.h>

#import "NezBaseSceneView.h"
#import "GmoLoaderAppDelegate.h"
#import "matrix.h"


@implementation NezBaseSceneView

-(NSInteger)getAnimationFrameInterval {
	return 2;
}

-(vec3)getInitialEye {
	static vec3 v = {0,0,0};
	return v;
}

-(vec3)getInitialTarget {
	static vec3 v = {0,0,0};
	return v;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		GmoLoaderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		UIScreen *mainScreen = [UIScreen mainScreen];
		screenScale = mainScreen.scale;
		screenWidth = delegate.window.frame.size.width*screenScale;
		screenHeight = delegate.window.frame.size.height*screenScale;

		mat4f_LoadPerspective(FOV_60_DEGREES, screenWidth/screenHeight, 0.1f, 1000.0f, projectionMatrix);
		
		mat4f_LoadIdentity(modelViewMatrix);
		mat4f_MultiplyMat4f(projectionMatrix, modelViewMatrix, modelViewProj);
		
		camera = [[NezCamera alloc] initWithEye:[self getInitialEye] Target:[self getInitialTarget]];
		
		framesPerSecond = NEZ_FRAMES_PER_SECOND;
		
		mach_timebase_info_data_t sTimebaseInfo;
		mach_timebase_info(&sTimebaseInfo);
		
		ticksPerFrame = ((1000000000.0/framesPerSecond)/((double)sTimebaseInfo.numer/(double)sTimebaseInfo.denom));
		
		time = 0;
		
		firstLayout = YES;
    }
    return self;
}

-(void)drawWithFrameBuffer:(GLuint)frameBuffer {
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);
	
	[self draw];
}

-(void)layoutSubviews {
	if (firstLayout) {
		GmoLoaderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate viewDidLayout];
		firstLayout = NO;
	}
	[super layoutSubviews];
}

-(double)getRandomNumber {
	return arc4random()/4294967295.0f;
}

-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed {}
-(void)draw {}
-(void)setContext:(EAGLContext*)context WithArguments:(id)arguments {}
-(void)loadSceneWithContext:(EAGLContext*)context andArguments:(id)arguments {}

- (void)dealloc {
    [super dealloc];
}


@end
