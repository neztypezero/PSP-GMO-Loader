//
//  ZoomRotationController.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/18/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "ZoomRotationController.h"
#import "NezScene.h"
#import "Math.h"

@implementation ZoomRotationController

-(id)initWithScene:(NezScene*)aScene {
	if (self = [super initWithScene:aScene]) {
		QuaternionGetIdentity(orientation);
		QuaternionGetIdentity(prevOrientation);
	}
	return self;
}

-(void)setView:(EAGLView*)view {
	[super setView:view];
	
	pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[view addGestureRecognizer:pinch];
}

-(void)invalidate {
	[parentView removeGestureRecognizer:pinch];
	[pinch release];
	pinch = nil;
	
	[super invalidate];
}

-(void)mapToSphere:(CGPoint)touchpoint :(float*)vOut {
    float p[] = {touchpoint.x-firstTouch.x, touchpoint.y-firstTouch.y};
    
    // Flip the Y axis because pixel coords increase towards the bottom.
    p[1] = -p[1];
    
    float radius = scene->screenWidth/2;
    float safeRadius = radius - 1;
    float lenSquared = p[0]*p[0]+p[1]*p[1];
    float len = sqrt(lenSquared);
    if (len > safeRadius) {
        float theta = atan2(p[1], p[0]);
        p[0] = safeRadius * cos(theta);
        p[1] = safeRadius * sin(theta);
		lenSquared = p[0]*p[0]+p[1]*p[1];
    }
    
    float z = sqrt(radius * radius - lenSquared);
	
	vOut[0] = p[0]/radius;
	vOut[1] = p[1]/radius;
	vOut[2] = z/radius;
}

-(BOOL)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	firstTouch = [[touches anyObject] locationInView:parentView];
	[scene->camera getOrientation:prevOrientation];
	return YES;
}

-(BOOL)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	CGPoint nextTouch = [[touches anyObject] locationInView:parentView];
	float start[3];
	float end[3];
	[self mapToSphere:firstTouch :start];
	[self mapToSphere:nextTouch :end];
	float deltaQuat[4];
	QuaternionFromVectors(start, end, deltaQuat);
	QuaternionMultiply(deltaQuat, prevOrientation, orientation);

	[scene->camera rotateCameraAroundLookAt:orientation];
	return YES;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
	CGFloat pinchVelocity = [recognizer velocity];
	[scene->camera zoom:pinchVelocity*50];
}

@end
