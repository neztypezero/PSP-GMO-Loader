//
//  NezCamera.m
//  NezModels3D
//
//  Created by David Nesbitt on 3/7/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezCamera.h"

#define SIGN(x) (x>=0?'+':'-') 

float VectorDistanceBetween(vec3 *v1, vec3 *v2) {
	float dx = v1->x-v2->x;
	float dy = v1->y-v2->y;
	float dz = v1->z-v2->z;
	
	return sqrt(dx*dx+dy*dy+dz*dz);
}

void VectorSubtractAndNormalize(vec3 *v1, vec3 *v2, vec3 *vOut) {
	vOut->x = v1->x-v2->x;
	vOut->y = v1->y-v2->y;
	vOut->z = v1->z-v2->z;
	
	float length = sqrt(vOut->x*vOut->x+vOut->y*vOut->y+vOut->z*vOut->z);
	vOut->x /= length;
	vOut->y /= length;
	vOut->z /= length;
}

void VectorCrossProductAndNormalize(vec3 *v1, vec3 *v2, vec3 *vOut) {
	vOut->x = v1->y*v2->z - v1->z*v2->y;
	vOut->y = v1->z*v2->x - v1->x*v2->z;
	vOut->z = v1->x*v2->y - v1->y*v2->x;
	
	float length = sqrt(vOut->x*vOut->x+vOut->y*vOut->y+vOut->z*vOut->z);
	vOut->x /= length;
	vOut->y /= length;
	vOut->z /= length;
}

void LookAt(vec3 *eye, vec3 *target, vec3 *up, float *mOut) {
	float m[16];
	vec3 *x = (vec3*)&m[0];
	vec3 *y = (vec3*)&m[4];
	vec3 *z = (vec3*)&m[8];
	
	VectorSubtractAndNormalize(eye, target, z);
	VectorCrossProductAndNormalize(up, z, x);
	VectorCrossProductAndNormalize(z, x, y);
	
	mOut[ 0] = x->x; mOut[ 4] = x->y; mOut[ 8] = x->z; 
	mOut[ 1] = y->x; mOut[ 5] = y->y; mOut[ 9] = y->z; 
	mOut[ 2] = z->x; mOut[ 6] = z->y; mOut[10] = z->z; 
	mOut[ 3] = 0;    mOut[ 7] = 0;    mOut[11] = 0; 
	
	vec3 negEye = {-eye->x, -eye->y, -eye->z};
	mOut[12] = x->x * negEye.x + x->y * negEye.y + x->z * negEye.z;
	mOut[13] = y->x * negEye.x + y->y * negEye.y + y->z * negEye.z;
	mOut[14] = z->x * negEye.x + z->y * negEye.y + z->z * negEye.z;
	mOut[15] = 1;
}

@implementation NezCamera

-(id)initWithEye:(vec3)eyePos Target:(vec3)lookAtTarget {
	if (self = [super init]) {
		eye = eyePos;
		target = lookAtTarget;
		up.x = 0; up.y = 1; up.z = 0;

		[self setMinEyeTargetDistance:1.0f];
		[self setupMatrix];
	}
	return self;
}

-(void)setMinEyeTargetDistance:(float)d {
	minEyeTargetDistance = fabs(d);
}

-(void)getOrientation:(float*)q {
	MatrixToOrientationQuaternion(matrix, q);
}

-(float)getEyeTargetDistance {
	float v[] = {eye.x-target.x, eye.y-target.y, eye.z-target.z};
	return Vector3fLength(v);
}

-(float*)matrix {
	return matrix;
}

-(float*)inverseMatrix {
	return inverseMatrix;
}

-(void)movePartialWithTarget:(float*)targetPos Increment:(float)ratio {
	target.x += (targetPos[0]-target.x)*ratio;
	target.y += (targetPos[1]-target.y)*ratio;
	target.z += (targetPos[2]-target.z)*ratio;
	[self setupMatrix];
}

-(void)movePartialWithEyePos:(float*)eyePos Target:(float*)targetPos Increment:(float)ratio {
	target.x += (targetPos[0]-target.x)*ratio;
	target.y += (targetPos[1]-target.y)*ratio;
	target.z += (targetPos[2]-target.z)*ratio;
	eye.x += (eyePos[0]-eye.x)*ratio;
	eye.y += (eyePos[1]-eye.y)*ratio;
	eye.z += (eyePos[2]-eye.z)*ratio;
	[self setupMatrix];
}

-(void)setTarget:(vec3)t {
	target = t;
	[self setupMatrix];
}

-(void)setEye:(vec3)e andTarget:(vec3)t {
	eye = e;
	target = t;
	[self setupMatrix];
}

-(void)setupMatrix {
	LookAt(&eye, &target, &up, matrix);
}

-(void)zoom:(float)scale {
	vec3 directionVector;
	VectorSubtractAndNormalize(&eye, &target, &directionVector);
	
	scale = -scale/100;
	
	vec3 newEyePos = {
		eye.x+directionVector.x*scale,
		eye.y+directionVector.y*scale,
		eye.z+directionVector.z*scale,
	};
	vec3 newDV = {
		newEyePos.x-target.x,
		newEyePos.y-target.y,
		newEyePos.z-target.z,
	};
	if (
		(newDV.x > 0 && directionVector.x < 0) || 
		(newDV.x < 0 && directionVector.x > 0) || 
		(newDV.y > 0 && directionVector.y < 0) || 
		(newDV.y < 0 && directionVector.y > 0) || 
		(newDV.z > 0 && directionVector.z < 0) || 
		(newDV.z < 0 && directionVector.z > 0) || 
		(Vector3fLength((float*)&newDV) < minEyeTargetDistance)
	) {
		newEyePos.x = target.x+(directionVector.x*minEyeTargetDistance);
		newEyePos.y = target.y+(directionVector.y*minEyeTargetDistance);
		newEyePos.z = target.z+(directionVector.z*minEyeTargetDistance);
	}
	eye = newEyePos;
	[self setupMatrix];
}

-(void)roll:(float)angle {
//	float qA[4];
//	float qB[4];
//	float zAxis[] = {0,0,1};
	
//	QuaternionCopy(quaternion, qA);
//	QuaternionRotationAxis(zAxis, angle, qB);
//	QuaternionMultiply(qA, qB, quaternion);
	[self setupMatrix];
}

-(void)rotateCameraAroundLookAt:(float*)q {
	float v[] = {0,0,1,1};
	float v2[4];
	float m[16];
	QuaternionToMatrix(q, m);
	MatrixMultVec4(m, v, v2);

	float distance = [self getEyeTargetDistance];
	eye.x = target.x+(v2[0]*distance);
	eye.y = target.y+(v2[1]*distance);
	eye.z = target.z+(v2[2]*distance);

	[self setupMatrix];
}

-(void)spin:(float)dx :(float)dy Radians:(float)angle {
//	float qA[4];
//	float qB[4];
//	float axis[] = {dx,dy,0};
	
//	QuaternionCopy(quaternion, qA);
//	QuaternionRotationAxis(axis, 0.05, qB);
//	QuaternionMultiply(qA, qB, quaternion);
	[self setupMatrix];
}


@end
