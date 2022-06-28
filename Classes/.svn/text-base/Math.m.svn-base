//
//  Math.m
//  NezModels3D
//
//  Created by David Nesbitt on 3/6/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "Math.h"

void QuaternionNormalize(float *q) {
	/* compute magnitude of the quaternion */
	float mag = sqrt ((q[X] * q[X]) + (q[Y] * q[Y])
					  + (q[Z] * q[Z]) + (q[W] * q[W]));
	
	/* check for bogus length, to protect against divide by zero */
	if (mag > EPSILON) {
		/* normalize it */
		float oneOverMag = 1.0f / mag;
		
		q[X] *= oneOverMag;
		q[Y] *= oneOverMag;
		q[Z] *= oneOverMag;
		q[W] *= oneOverMag;
    }
}

void Quat_multQuat (float *qa, float *qb, float *qout) {
	qout[W] = (qa[W] * qb[W]) - (qa[X] * qb[X]) - (qa[Y] * qb[Y]) - (qa[Z] * qb[Z]);
	qout[X] = (qa[X] * qb[W]) + (qa[W] * qb[X]) + (qa[Y] * qb[Z]) - (qa[Z] * qb[Y]);
	qout[Y] = (qa[Y] * qb[W]) + (qa[W] * qb[Y]) + (qa[Z] * qb[X]) - (qa[X] * qb[Z]);
	qout[Z] = (qa[Z] * qb[W]) + (qa[W] * qb[Z]) + (qa[X] * qb[Y]) - (qa[Y] * qb[X]);
}

void Quat_multVec(float *q, float *v, float *qout) {
	qout[W] = - (q[X] * v[X]) - (q[Y] * v[Y]) - (q[Z] * v[Z]);
	qout[X] =   (q[W] * v[X]) + (q[Y] * v[Z]) - (q[Z] * v[Y]);
	qout[Y] =   (q[W] * v[Y]) + (q[Z] * v[X]) - (q[X] * v[Z]);
	qout[Z] =   (q[W] * v[Z]) + (q[X] * v[Y]) - (q[Y] * v[X]);
}

void Quat_rotatePoint(float *q, float *vin, float *vout) {
	float tmp[4], inv[4], final[4];
	
	inv[X] = -q[X]; inv[Y] = -q[Y];
	inv[Z] = -q[Z]; inv[W] =  q[W];
	
	QuaternionNormalize(inv);
	
	Quat_multVec(q, vin, tmp);
	Quat_multQuat(tmp, inv, final);
	
	vout[X] = final[X];
	vout[Y] = final[Y];
	vout[Z] = final[Z];
}

void QuaternionGetInverse(float *q, float *inv) {
	inv[X] = -q[X]; inv[Y] = -q[Y];
	inv[Z] = -q[Z]; inv[W] =  q[W];
	QuaternionNormalize(inv);
}

void QuaternionFromEulerAngles(float xAng, float yAng, float zAng, float *quaternion) {
	float vec[3];
	float quat1[4], quat2[4], xQuat[4], yQuat[4], zQuat[4];
	
	vec[0] = 1; vec[1] = 0; vec[2] = 0;
	QuaternionRotationAxis(vec, -xAng, xQuat);
	vec[0] = 0; vec[1] = 1; vec[2] = 0;
	QuaternionRotationAxis(vec, -yAng, yQuat);
	vec[0] = 0; vec[1] = 0; vec[2] = 1;
	QuaternionRotationAxis(vec, -zAng, zQuat);
	
	QuaternionGetIdentity(quat1);
	QuaternionMultiply(quat1, xQuat, quat2);
	QuaternionMultiply(quat2, yQuat, quat1);
	QuaternionMultiply(quat1, zQuat, quaternion);
}

void QuaternionToMatrix(float *quat, float *mOut) {
    /* Fill matrix members */
	float qXsqrd = quat[X]*quat[X];
	float qYsqrd = quat[Y]*quat[Y];
	float qZsqrd = quat[Z]*quat[Z];
	
	mOut[0] = 1.0f - 2.0f*qYsqrd - 2.0f*qZsqrd;
	mOut[1] = 2.0f*quat[X]*quat[Y] - 2.0f*quat[Z]*quat[W];
	mOut[2] = 2.0f*quat[X]*quat[Z] + 2.0f*quat[Y]*quat[W];
	mOut[3] = 0.0f;
	
	mOut[4] = 2.0f*quat[X]*quat[Y] + 2.0f*quat[Z]*quat[W];
	mOut[5] = 1.0f - 2.0f*qXsqrd - 2.0f*qZsqrd;
	mOut[6] = 2.0f*quat[Y]*quat[Z] - 2.0f*quat[X]*quat[W];
	mOut[7] = 0.0f;
	
	mOut[8] = 2.0f*quat[X]*quat[Z] - 2*quat[Y]*quat[W];
	mOut[9] = 2.0f*quat[Y]*quat[Z] + 2.0f*quat[X]*quat[W];
	mOut[10] = 1.0f - 2.0f*qXsqrd - 2*qYsqrd;
	mOut[11] = 0.0f;
	
	mOut[12] = 0.0f;
	mOut[13] = 0.0f;
	mOut[14] = 0.0f;
	mOut[15] = 1.0f;
}

void MatrixToOrientationQuaternion(float *m, float *q) {
	float trace = m[0] + m[5] + m[10] + 1.0f;
	
	if(trace > EPSILON) {
		float s = 0.5f / sqrtf(trace);
		q[W] = 0.25f / s;
		q[X] = (m[6] - m[9]) * s;
		q[Y] = (m[8] - m[2]) * s;
		q[Z] = (m[1] - m[4]) * s;
	} else {
		if(m[0] > m[5] && m[0] > m[10]) {
			float s = 2.0f * sqrtf(1.0f + m[0] - m[5] - m[10]);
			q[W] = 0.25f * s;
			q[X] = (m[4]+ m[0])/s;
			q[Y] = (m[8]+ m[2])/s;
			q[Z] = (m[9]- m[6])/s;
			
		} else if (m[5] > m[10]) {
			float s = 2.0f * sqrtf(1.0f + m[5] - m[0] - m[10]);
			q[W] = (m[4] + m[1]) / s;
			q[X] = 0.25f * s;
			q[Y] = (m[9] + m[6]) / s;
			q[Z] = (m[8] - m[2]) / s;
			
		} else {
			float s = 2.0f * sqrtf(1.0f + m[10] - m[0] - m[5]);
			q[W] = (m[8] + m[2]) / s;
			q[X] = (m[9] + m[6]) / s;
			q[Y] = 0.25f * s;
			q[Z] = (m[4] - m[1]) / s;
		}
	}
	QuaternionNormalize(q);
}

void QuaternionFromVectors(const float *v0, const float *v1, float *qOut) {
	if (v0[X] == -v1[X] && v0[Y] == -v1[Y] && v0[Z] == -v1[Z]) {
		float v[] = {1,0,0};
		QuaternionRotationAxis(v, Nez_PI, qOut);
		return;
	}
	float c[3];
	VectorCrossProduct(v0, v1, c);
	float d = VectorDotProduct(v0, v1);
	float s = sqrt((1+d)*2);
	
	qOut[X] = c[X]/s;
	qOut[Y] = c[Y]/s;
	qOut[Z] = c[Z]/s;
	qOut[W] = s / 2.0f;
}

void QuaternionRotationAxis(const float *vAxis, const float fAngle, float *qOut) {
	float fSin = (float)sin(fAngle * 0.5f);
	float fCos = (float)cos(fAngle * 0.5f);
	
	/* Create quaternion */
	qOut[X] = vAxis[X] * fSin;
	qOut[Y] = vAxis[Y]  * fSin;
	qOut[Z] = vAxis[Z]  * fSin;
	qOut[W] = fCos;
	
	/* Normalise it */
	QuaternionNormalize(qOut);
}

void QuaternionMultiply(const float *qA, const float *qB, float *qOut) 
{
	float crossProduct[3];
	
	/* Compute scalar component */
	qOut[W] = (qA[W]*qB[W]) - (qA[X]*qB[X] + qA[Y]*qB[Y] + qA[Z]*qB[Z]);
	
	/* Compute cross product */
	crossProduct[X] = qA[Y]*qB[Z] - qA[Z]*qB[Y];
	crossProduct[Y] = qA[Z]*qB[X] - qA[X]*qB[Z];
	crossProduct[Z] = qA[X]*qB[Y] - qA[Y]*qB[X];
	
	/* Compute result vector */
	qOut[X] = (qA[W] * qB[X]) + (qB[W] * qA[X]) + crossProduct[X];
	qOut[Y] = (qA[W] * qB[Y]) + (qB[W] * qA[Y]) + crossProduct[Y];
	qOut[Z] = (qA[W] * qB[Z]) + (qB[W] * qA[Z]) + crossProduct[Z];
	
	/* Normalize resulting quaternion */
	QuaternionNormalize(qOut);
}

void QuaternionSlerp(const float *qA, const float *qB, const float t, float *qOut) {
	float fCosine, fAngle, A, B;
	
	/* Find sine of Angle between Quaternion A and B (dot product between quaternion A and B) */
	fCosine = qA[W]*qB[W] + qA[X]*qB[X] + qA[Y]*qB[Y] + qA[Z]*qB[Z];
	
	if (fCosine < 0) {
		/*
		 <http://www.magic-software.com/Documentation/Quaternions.pdf>
		 
		 "It is important to note that the quaternions q and -q represent
		 the same rotation... while either quaternion will do, the
		 interpolation methods require choosing one over the other.
		 
		 "Although q1 and -q1 represent the same rotation, the values of
		 Slerp(t; q0, q1) and Slerp(t; q0,-q1) are not the same. It is
		 customary to choose the sign... on q1 so that... the angle
		 between q0 and q1 is acute. This choice avoids extra
		 spinning caused by the interpolated rotations."
		 */
		float qi[4];
		qi[X] = -qB[X];
		qi[Y] = -qB[Y];
		qi[Z] = -qB[Z];
		qi[W] = -qB[W];
		
		QuaternionSlerp(qA, qi, t, qOut);
		return;
	}
	
	fCosine = MIN(fCosine, 1.0f);
	fAngle = (float)cos(fCosine);
	
	/* Avoid a division by zero */
	if (fAngle<=EPSILON) {
		QuaternionCopy(qA, qOut);
		return;
	}
	
	/* Precompute some values */
	A = (float)(sin((1.0f-t)*fAngle) / sin(fAngle));
	B = (float)(sin(t*fAngle) / sin(fAngle));
	
	/* Compute resulting quaternion */
	qOut[X] = A * qA[X] + B * qB[X];
	qOut[Y] = A * qA[Y] + B * qB[Y];
	qOut[Z] = A * qA[Z] + B * qB[Z];
	qOut[W] = A * qA[W] + B * qB[W];
	
	/* Normalise result */
	QuaternionNormalize(qOut);
}

void MatrixGetTranslation(float *translation, float *mOut) {
	MatrixCopy(IDENTITY_MATRIX, mOut);
	mOut[12] = translation[X];
	mOut[13] = translation[Y];
	mOut[14] = translation[Z];
}

void MatrixGetScale(float *scale, float *mOut) {
	MatrixCopy(IDENTITY_MATRIX, mOut);
	mOut[0] = scale[X];
	mOut[5] = scale[Y];
	mOut[10] = scale[Z];
}

void MatrixMultiplyScaleS(float *mIn, float scale, float *mOut) {
	mOut[0] = mIn[0] * scale;
	mOut[1] = mIn[1] * scale;
	mOut[2] = mIn[2] * scale;
	mOut[4] = mIn[4] * scale;
	mOut[5] = mIn[5] * scale;
	mOut[6] = mIn[6] * scale;
	mOut[8] = mIn[8] * scale;
	mOut[9] = mIn[9] * scale;
	mOut[10]= mIn[10]* scale;
	if (mIn != mOut) {
		mOut[3 ] = mIn[3 ];
		mOut[7 ] = mIn[7 ];
		mOut[11] = mIn[11];
		mOut[12] = mIn[12];
		mOut[13] = mIn[13];
		mOut[14] = mIn[14];
		mOut[15] = mIn[15];
	}
}

void MatrixMultiplyScale(float *mIn, float *scale, float *mOut) {
	float x = scale[X];
	float y = scale[Y];
	float z = scale[Z];
	mOut[0] = mIn[0] * x;
	mOut[1] = mIn[1] * x;
	mOut[2] = mIn[2] * x;
	mOut[4] = mIn[4] * y;
	mOut[5] = mIn[5] * y;
	mOut[6] = mIn[6] * y;
	mOut[8] = mIn[8] * z;
	mOut[9] = mIn[9] * z;
	mOut[10]= mIn[10]* z;
	if (mIn != mOut) {
		mOut[3 ] = mIn[3 ];
		mOut[7 ] = mIn[7 ];
		mOut[11] = mIn[11];
		mOut[12] = mIn[12];
		mOut[13] = mIn[13];
		mOut[14] = mIn[14];
		mOut[15] = mIn[15];
	}
}

void MatrixGetRotation(float *rotation, float *mOut) {
	MatrixCopy(IDENTITY_MATRIX, mOut);
	mOut[0] = rotation[X];
	mOut[5] = rotation[Y];
	mOut[10] = rotation[Z];
}

void MatrixMultiply(const float *mB, const float *mA, float *mOut) {
	mOut[ 0] = mA[ 0]*mB[ 0] + mA[ 1]*mB[ 4] + mA[ 2]*mB[ 8] + mA[ 3]*mB[12];
	mOut[ 1] = mA[ 0]*mB[ 1] + mA[ 1]*mB[ 5] + mA[ 2]*mB[ 9] + mA[ 3]*mB[13];
	mOut[ 2] = mA[ 0]*mB[ 2] + mA[ 1]*mB[ 6] + mA[ 2]*mB[10] + mA[ 3]*mB[14];
	mOut[ 3] = mA[ 0]*mB[ 3] + mA[ 1]*mB[ 7] + mA[ 2]*mB[11] + mA[ 3]*mB[15];
	mOut[ 4] = mA[ 4]*mB[ 0] + mA[ 5]*mB[ 4] + mA[ 6]*mB[ 8] + mA[ 7]*mB[12];
	mOut[ 5] = mA[ 4]*mB[ 1] + mA[ 5]*mB[ 5] + mA[ 6]*mB[ 9] + mA[ 7]*mB[13];
	mOut[ 6] = mA[ 4]*mB[ 2] + mA[ 5]*mB[ 6] + mA[ 6]*mB[10] + mA[ 7]*mB[14];
	mOut[ 7] = mA[ 4]*mB[ 3] + mA[ 5]*mB[ 7] + mA[ 6]*mB[11] + mA[ 7]*mB[15];
	mOut[ 8] = mA[ 8]*mB[ 0] + mA[ 9]*mB[ 4] + mA[10]*mB[ 8] + mA[11]*mB[12];
	mOut[ 9] = mA[ 8]*mB[ 1] + mA[ 9]*mB[ 5] + mA[10]*mB[ 9] + mA[11]*mB[13];
	mOut[10] = mA[ 8]*mB[ 2] + mA[ 9]*mB[ 6] + mA[10]*mB[10] + mA[11]*mB[14];
	mOut[11] = mA[ 8]*mB[ 3] + mA[ 9]*mB[ 7] + mA[10]*mB[11] + mA[11]*mB[15];
	mOut[12] = mA[12]*mB[ 0] + mA[13]*mB[ 4] + mA[14]*mB[ 8] + mA[15]*mB[12];
	mOut[13] = mA[12]*mB[ 1] + mA[13]*mB[ 5] + mA[14]*mB[ 9] + mA[15]*mB[13];
	mOut[14] = mA[12]*mB[ 2] + mA[13]*mB[ 6] + mA[14]*mB[10] + mA[15]*mB[14];
	mOut[15] = mA[12]*mB[ 3] + mA[13]*mB[ 7] + mA[14]*mB[11] + mA[15]*mB[15];
}

void MatrixSet(float *dst, float tx, float ty, float tz, float sx, float sy, float sz ) {
	dst[0] = sx; dst[1] = 0;  dst[2] = 0;  dst[3] = 0;
	dst[4] = 0;	 dst[5] = sy; dst[6] = 0;  dst[7] = 0;
	dst[8] = 0;  dst[9] = 0;  dst[10] = sz;dst[11] = 0;
	dst[12] = tx;dst[13] = ty;dst[14] = tz;dst[15] = 1;
}

void MatrixInverse(float *mIn, float *mOut) {
	double det_1;
	double pos, neg, temp;
	
    /* Calculate the determinant of submatrix A and determine if the
	 the matrix is singular as limited by the double precision
	 floating-point data representation. */
    pos = neg = 0.0;
    temp =  mIn[ 0] * mIn[ 5] * mIn[10];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp =  mIn[ 4] * mIn[ 9] * mIn[ 2];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp =  mIn[ 8] * mIn[ 1] * mIn[ 6];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp = -mIn[ 8] * mIn[ 5] * mIn[ 2];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp = -mIn[ 4] * mIn[ 1] * mIn[10];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp = -mIn[ 0] * mIn[ 9] * mIn[ 6];
    if (temp >= 0.0) pos += temp; else neg += temp;
    det_1 = pos + neg;
	
    /* Is the submatrix A singular? */
	if ((det_1 <= EPSILON)) {
		return;
	} else {
        /* Calculate inverse(A) = adj(A) / det(A) */
        det_1 = 1.0 / det_1;
        mOut[ 0] =   ( mIn[ 5] * mIn[10] - mIn[ 9] * mIn[ 6] ) * (float)det_1;
        mOut[ 1] = - ( mIn[ 1] * mIn[10] - mIn[ 9] * mIn[ 2] ) * (float)det_1;
        mOut[ 2] =   ( mIn[ 1] * mIn[ 6] - mIn[ 5] * mIn[ 2] ) * (float)det_1;
        mOut[ 4] = - ( mIn[ 4] * mIn[10] - mIn[ 8] * mIn[ 6] ) * (float)det_1;
        mOut[ 5] =   ( mIn[ 0] * mIn[10] - mIn[ 8] * mIn[ 2] ) * (float)det_1;
        mOut[ 6] = - ( mIn[ 0] * mIn[ 6] - mIn[ 4] * mIn[ 2] ) * (float)det_1;
        mOut[ 8] =   ( mIn[ 4] * mIn[ 9] - mIn[ 8] * mIn[ 5] ) * (float)det_1;
        mOut[ 9] = - ( mIn[ 0] * mIn[ 9] - mIn[ 8] * mIn[ 1] ) * (float)det_1;
        mOut[10] =   ( mIn[ 0] * mIn[ 5] - mIn[ 4] * mIn[ 1] ) * (float)det_1;
		
        /* Calculate -C * inverse(A) */
        mOut[12] = - ( mIn[12] * mOut[ 0] + mIn[13] * mOut[ 4] + mIn[14] * mOut[ 8] );
        mOut[13] = - ( mIn[12] * mOut[ 1] + mIn[13] * mOut[ 5] + mIn[14] * mOut[ 9] );
        mOut[14] = - ( mIn[12] * mOut[ 2] + mIn[13] * mOut[ 6] + mIn[14] * mOut[10] );
		
        /* Fill in last row */
        mOut[ 3] = 0.0f;
		mOut[ 7] = 0.0f;
		mOut[11] = 0.0f;
        mOut[15] = 1.0f;
	}
}

void MatrixMultVec4(float *mIn, float *vIn, float *vOut) {
	vOut[X] = vIn[X]*mIn[ 0]+vIn[Y]*mIn[ 4]+vIn[Z]*mIn[ 8]+vIn[W]*mIn[12];
	vOut[Y] = vIn[X]*mIn[ 1]+vIn[Y]*mIn[ 5]+vIn[Z]*mIn[ 9]+vIn[W]*mIn[13];
	vOut[Z] = vIn[X]*mIn[ 2]+vIn[Y]*mIn[ 6]+vIn[Z]*mIn[10]+vIn[W]*mIn[14];
	vOut[W] = vIn[X]*mIn[ 3]+vIn[Y]*mIn[ 7]+vIn[Z]*mIn[11]+vIn[W]*mIn[15];
}

void MouseToWorld(CGPoint point,
				  const float modelMatrix[16], 
				  const float projMatrix[16],
				  const int viewport[4],
				  float *lineSegment)
{
    float finalMatrix1[16];
    float finalMatrix[16];
    float inVec[4];
    float outVec[4];
	
    MatrixMultiply(projMatrix, modelMatrix, finalMatrix1);
    MatrixInverse(finalMatrix1, finalMatrix);
	
    inVec[0]=point.x;
    inVec[1]=(float)viewport[3]-point.y;
    inVec[3]=1.0f;
	
    /* Map x and y from window coordinates */
    inVec[0] = (inVec[0] - viewport[0]) / viewport[2];
    inVec[1] = (inVec[1] - viewport[1]) / viewport[3];
	
    /* Map to range -1 to 1 */
    inVec[0] = inVec[0] * 2 - 1;
    inVec[1] = inVec[1] * 2 - 1;
    inVec[2] = -1;
	
    MatrixMultVec4(finalMatrix, inVec, outVec);
    
	lineSegment[0] = outVec[0]/outVec[3];
    lineSegment[1] = outVec[1]/outVec[3];
    lineSegment[2] = outVec[2]/outVec[3];
	
    inVec[2] = 1;
    MatrixMultVec4(finalMatrix, inVec, outVec);
	
	lineSegment[3] = outVec[0]/outVec[3];
    lineSegment[4] = outVec[1]/outVec[3];
    lineSegment[5] = outVec[2]/outVec[3];
}

// dot product (3D) which allows vector operations in arguments
#define dot(u,v)   ((u[0] * v[0]) + (u[1] * v[1]) + (u[2] * v[2]))
#define norm(v)    sqrt(dot(v,v))  // norm = length of vector
//#define d(u,v)     norm(u-v)       // distance = norm of difference

static inline float d(float *u, float *v) {
	float dif[3] = {
		u[0]-v[0],
		u[1]-v[1],
		u[2]-v[2],
	};
	return norm(dif);
}

float PointToSegmentDistance(float *p, float *s) {
	float v[3] = {
		s[3]-s[0],
		s[4]-s[1],
		s[5]-s[2],
	};
	float w[3] = {
		p[0]-s[0],
		p[1]-s[1],
		p[2]-s[2],
	};
	
    double c1 = dot(w,v);
    if ( c1 <= 0 )
        return d(p, s);
	
    double c2 = dot(v,v);
    if ( c2 <= c1 )
        return d(p, &s[3]);
	
    double b = c1 / c2;
    float pb[3] = {
		s[0] + b * v[0],
		s[1] + b * v[1],
		s[2] + b * v[2],
	};
    return d(p, pb);
}
//===================================================================

void ProjectPoint(float objx, float objy, float objz, 
				  float modelMatrix[16], 
				  float projMatrix[16],
				  int viewport[4],
				  float *winx, float *winy, float *winz)
{
    float inPoint[4];
    float outPoint[4];
	
    inPoint[0]=objx;
    inPoint[1]=objy;
    inPoint[2]=objz;
    inPoint[3]=1.0;
    
	MatrixMultVec4(modelMatrix, inPoint, outPoint);
    MatrixMultVec4(projMatrix, outPoint, inPoint);
	
	if (inPoint[3] > EPSILON) {
		inPoint[0] /= inPoint[3];
		inPoint[1] /= inPoint[3];
		inPoint[2] /= inPoint[3];
	}
    /* Map x, y and z to range 0-1 */
    inPoint[0] = inPoint[0] * 0.5 + 0.5;
    inPoint[1] = inPoint[1] * 0.5 + 0.5;
    inPoint[2] = inPoint[2] * 0.5 + 0.5;
	
    /* Map x,y to viewport */
    inPoint[0] = inPoint[0] * viewport[2] + viewport[0];
    inPoint[1] = inPoint[1] * viewport[3] + viewport[1];
	
    *winx=inPoint[0];
    *winy=inPoint[1];
    *winz=inPoint[2];
}

float Vector3fLengthSquared(float *vec) {
	return  (vec[X] *vec[X])+(vec[Y]*vec[Y])+(vec[Z]*vec[Z]);
}

/**
 * Returns the length of this vector.
 * @return the length of this vector
 */
float Vector3fLength(float *vec) {
	return sqrt(Vector3fLengthSquared(vec));
}

float VectorDotProduct(const float *vec1, const float *vec2) {
	return  (vec1[X]*vec2[X])+(vec1[Y]*vec2[Y])+(vec1[Z]*vec2[Z]);
}

void VectorCrossProduct(const float *v1, const float *v2, float *vOut) {
	vOut[X] = (v1[Y] * v2[Z]) - (v1[Z] * v2[Y]);
	vOut[Y] = (v1[Z] * v2[X]) - (v1[X] * v2[Z]);
	vOut[Z] = (v1[X] * v2[Y]) - (v1[Y] * v2[X]);
}

void VectorNormalize(float *v) {
	float len = Vector3fLength(v);
	v[X] /= len;
	v[Y] /= len;
	v[Z] /= len;
}

//Takes in triangle, outputs normal
void GetNormal(float *vertex1, float *vertex2, float *vertex3, float *normal) {
	float vec1[] = {
		vertex2[0] - vertex1[0],
		vertex2[1] - vertex1[1],
		vertex2[2] - vertex1[2],
	};
	float vec2[] = {
		vertex3[0] - vertex1[0],
		vertex3[1] - vertex1[1],
		vertex3[2] - vertex1[2],
	};
	VectorCrossProduct(vec1, vec2, normal);
	float len = Vector3fLength(normal);
	normal[0] /= len;
	normal[1] /= len;
	normal[2] /= len;
}