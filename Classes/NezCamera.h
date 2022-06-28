//
//  NezCamera.h
//  NezModels3D
//
//  Created by David Nesbitt on 3/7/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "Math.h"
#import "NezBonedModelStructures.h"

@interface NezCamera : NSObject {
	
@public
	float matrix[16];
	float inverseMatrix[16];
	
	vec3 eye;
	vec3 target;
	vec3 up;
	
	float minEyeTargetDistance;
}

-(id)initWithEye:(vec3)eyePos Target:(vec3)lookAtTarget;

-(void)setMinEyeTargetDistance:(float)d;
-(float)getEyeTargetDistance;

-(void)setTarget:(vec3)t;
-(void)setEye:(vec3)e andTarget:(vec3)t;

-(void)getOrientation:(float*)q;

-(void)movePartialWithTarget:(float*)targetPos Increment:(float)ratio;
-(void)movePartialWithEyePos:(float*)eyePos Target:(float*)targetPos Increment:(float)ratio;

-(float*)matrix;
-(float*)inverseMatrix;

-(void)zoom:(float)scale;
-(void)rotateCameraAroundLookAt:(float*)quaternion;

-(void)roll:(float)angle;
-(void)spin:(float)dx :(float)dy Radians:(float)angle;

-(void)setupMatrix;

@end
