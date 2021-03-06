//
//  NezCrystalWorldView.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezCrystalWorldView.h"
#import "GmoLoaderAppDelegate.h"
#import "EAGLView.h"
#import "DataResourceManager.h"


@implementation NezCrystalWorldView

-(vec3)getInitialEye {
	static vec3 v = {0.0f, 7.0f, 20.50f};
	return v;
}

-(vec3)getInitialTarget {
	static vec3 v = {0.0f, 7.0f, 1.0f};
	return v;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		worldModel = nil;
    }
    return self;
}

-(void)loadModels:(EAGLContext*)context {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    [EAGLContext setCurrentContext:context];
	worldModel = [[DataResourceManager instance] loadModel:@"crystallevel" ofType:@"gmo"];

    [pool release];
}

-(void)loadSceneWithContext:(EAGLContext*)context andArguments:(id)arguments {
	[NSThread detachNewThreadSelector:@selector(loadModels:) toTarget:self withObject:context];
}

-(void)draw {
	glViewport(0, 0, screenWidth, screenHeight);
	if (worldModel) {
		[worldModel drawWithProjectionMatrix:projectionMatrix CameraMatrix:[camera matrix]];
	}
}

- (void)dealloc {
    [super dealloc];
}

@end
