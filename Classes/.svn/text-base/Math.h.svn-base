//
//  Math.h
//  NezModels3D
//
//  Created by David Nesbitt on 3/6/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#define SIZE_OF_VEC4F (sizeof(float)*4)
#define SIZE_OF_SEGMENT (sizeof(float)*6)
#define SIZE_OF_MATRIX4F (SIZE_OF_VEC4F*4)

//assuming IEEE-754(GLfloat), which i believe has max precision of 7 bits
#define EPSILON 1.0e-7

#define Nez_PI 3.141592653589793

static const float IDENTITY_QUATERNION[] = {
	0, 0, 0, 1
};

static const float IDENTITY_MATRIX[] = {
	1, 0, 0, 0,
	0, 1, 0, 0,
	0, 0, 1, 0,
	0, 0, 0, 1
};

enum {
	X, Y, Z, W
};

static inline void QuaternionCopy(const float *qIn, float *qOut) {
	memcpy(qOut, qIn, SIZE_OF_VEC4F);
}

static inline void QuaternionGetIdentity(float *qOut) {
	QuaternionCopy(IDENTITY_QUATERNION, qOut);
}

void QuaternionNormalize(float *q);
void Quat_multQuat (float *qa, float *qb, float *qout);
void Quat_multVec(float *q, float *v, float *qout);
void Quat_rotatePoint(float *q, float *vin, float *vout);

void QuaternionGetInverse(float *q, float *inv);

void QuaternionFromEulerAngles(float zAng, float yAng, float xAng, float *quaternion);
void QuaternionToMatrix(float *quat, float *mOut);
void QuaternionFromVectors(const float *v0, const float *v1, float *qOut);
void QuaternionRotationAxis(const float *vAxis, const float fAngle, float *qOut);
void QuaternionMultiply(const float *qA, const float *qB, float *qOut);
void QuaternionSlerp(const float *qA, const float *qB, const float t, float *qOut);

void MatrixToOrientationQuaternion(float *m, float *q);

static inline void MatrixCopy(const float *mIn, float *mOut) {
	memcpy(mOut, mIn, SIZE_OF_MATRIX4F);
}

static inline void MatrixGetIdentity(float *mOut) {
	MatrixCopy(IDENTITY_MATRIX, mOut);
}

void MatrixSet(float *dst, float tx, float ty, float tz, float sx, float sy, float sz );

void MatrixGetTranslation(float *translation, float *mOut);

void MatrixGetScale(float *scale, float *mOut);
void MatrixMultiplyScaleS(float *mIn, float scale, float *mOut);
void MatrixMultiplyScale(float *mIn, float *scale, float *mOut);

void MatrixGetRotation(float *rotation, float *mOut);

void MatrixMultiply(const float *mB, const float *mA, float *mOut);
void MatrixInverse(float *f, float *mOut);

void MatrixMultVec4(float *mIn, float *vIn, float *vOut);

void MouseToWorld(CGPoint point,
				  const float modelMatrix[16], 
				  const float projMatrix[16],
				  const int viewport[4],
				  float *lineSegment);

float PointToSegmentDistance(float *p, float *s);

void ProjectPoint(float objx, float objy, float objz, 
				  float modelMatrix[16], 
				  float projMatrix[16],
				  int viewport[4],
				  float *winx, float *winy, float *winz);

float Vector3fLengthSquared(float *vec);
float Vector3fLength(float *vec);
float VectorDotProduct(const float *vec1, const float *vec2);
void VectorCrossProduct(const float *v1, const float *v2, float *vOut);
void VectorNormalize(float *v);
void GetNormal(float *vertex1, float *vertex2, float *vertex3, float *normal);

