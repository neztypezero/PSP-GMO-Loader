//
//  NezZoomRotationView.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezZoomRotationView.h"
#import "Math.h"


@interface NezZoomRotationView (private)

-(void)mapToSphere:(CGPoint)touchpoint :(float*)vOut;
-(void)rotateCamera;

@end

@implementation NezZoomRotationView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		QuaternionGetIdentity(orientation);
		QuaternionGetIdentity(prevOrientation);

    	pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
		[self addGestureRecognizer:pinch];
		
		touchesDown = 0;
		animating = NO;
	}
    return self;
}

-(void)mapToSphere:(CGPoint)touchpoint :(float*)vOut {
    float p[] = {touchpoint.x-firstTouch.x, touchpoint.y-firstTouch.y};
    
    // Flip the Y axis because pixel coords increase towards the bottom.
    p[1] = -p[1];
    
    float radius = screenWidth/2;
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

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	animating = NO;
	
	touchVelocity.x = 0;
	touchVelocity.y = 0;
	
	touchesDown += [touches count];
	if (touchesDown == 1) {
		firstTouch = [[touches anyObject] locationInView:self];
		[self mapToSphere:firstTouch :start];
		[camera getOrientation:prevOrientation];
	}
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	if (touchesDown == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint nextTouch = [touch locationInView:self];
		CGPoint prevTouch = [touch previousLocationInView:self];
		[self mapToSphere:nextTouch :end];
		
		touchVelocity.x = (nextTouch.x-prevTouch.x);
		touchVelocity.y = (nextTouch.y-prevTouch.y);
		
		QuaternionFromVectors(start, end, deltaQuat);
		QuaternionMultiply(deltaQuat, prevOrientation, orientation);
		[camera rotateCameraAroundLookAt:orientation];
	}
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
	if (touchesDown == 1) {
		firstTouch = CGPointMake(0.0f, 0.0f);
		[self mapToSphere:firstTouch :start];
		animating = YES;
		
		cameraVecX = camera->eye.x-camera->target.x;
	}
	touchesDown -= [touches count];
}

-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent *)event {
	touchesDown -= [touches count];
}

-(void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
	CGFloat pinchVelocity = [recognizer velocity];
	[camera zoom:pinchVelocity*50];
}

-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed {
	if (animating) {
		float lenSquared = touchVelocity.x*touchVelocity.x+touchVelocity.y*touchVelocity.y;
		if (lenSquared > 0.0001f) {
			[camera getOrientation:prevOrientation];
			[self mapToSphere:touchVelocity :end];
			QuaternionFromVectors(start, end, deltaQuat);
			QuaternionMultiply(deltaQuat, prevOrientation, orientation);
			[camera rotateCameraAroundLookAt:orientation];
			float camVecX = camera->eye.x-camera->target.x;
			if (cameraVecX > 0 && camVecX < 0) {
				touchVelocity.y = -touchVelocity.y;
				cameraVecX = camVecX;
			} else if (cameraVecX < 0 && camVecX > 0) {
				touchVelocity.y = -touchVelocity.y;
				cameraVecX = camVecX;
			}
		} else {
			animating = NO;
		}
		float a = pow(0.8f, timeElapsed*framesPerSecond);
		touchVelocity.x *= a;
		touchVelocity.y *= a;
	}
}

-(void)dealloc {
    [super dealloc];
}


@end
