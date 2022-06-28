//
//  SceneCrystalWorld.m
//  GmoLoader
//
//  Created by David Nesbitt on 8/24/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "SceneCrystalWorld.h"
#import "DataResourceManager.h"
#import "ZoomRotationController.h"

@implementation SceneCrystalWorld

+(NSString*)getSceneName {
	return @"CrystalWorld";
}

-(vec3)getInitialEye {
	static vec3 v = {0.0f, 7.0f, 20.50f};
	return v;
}

-(vec3)getInitialTarget {
	static vec3 v = {0.0f, 7.0f, 1.0f};
	return v;
}

-(id)init {
	if (self = [super initWithFPS:THIRTY_FRAMES_PER_SECOND]) {
		spinDeceleration = 0;
		spinAngle = 0;
	}

	return self;
}

- (void) dealloc {
    [super dealloc];
}

-(void)makeController {
	controller = [[ZoomRotationController alloc] initWithScene:self];
}

-(void)setContext:(EAGLContext*)context WithArguments:(id)arguments {
	[super setContext:context WithArguments:arguments];
	[NSThread detachNewThreadSelector:@selector(loadModels:) toTarget:self withObject:context];
}

-(void)updateWithFramesElapsed:(float)framesElapsed {
	if(spinAngle > 0) {
		[camera spin:-spinVector.y :-spinVector.x Radians:spinAngle];
		spinAngle -= spinDeceleration*framesElapsed;
		if (spinAngle < 0) {
			spinAngle = 0;
		}
	}
}

-(void)loadModels:(EAGLContext*)context {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[EAGLContext setCurrentContext:context];
	
	worldModel = [[DataResourceManager instance] loadModel:@"crystallevel" ofType:@"gmo"];
	
	[pool release];
}

-(void)draw {
	glViewport(0, 0, screenWidth, screenHeight);
	if (worldModel) {
		[worldModel drawWithProjectionMatrix:projectionMatrix CameraMatrix:[camera matrix]];
	}
}

@end
