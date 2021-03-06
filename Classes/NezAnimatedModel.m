//
//  NezAnimatedModel.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/8/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezAnimatedModel.h"
#import "GmoDataStructures.h"
#import "Math.h"

#define HAS_ROTATE 1
#define HAS_TRANSLATE (HAS_ROTATE<<1)
#define HAS_SCALE (HAS_TRANSLATE<<1)

@interface NezAnimatedModel (private)

-(int)FCurveEval:(const NezGmoFCurve*)fcurve :(float)frame :(float*)output;
-(int)FCurveEvalHalfFloat:(const NezGmoFCurve*)fcurve :(float)frame :(float*)output;
-(float)halfToFloat:(int)val;
-(float)extrapFrame:(float)frame :(float)start :(float)end :(int)extrap;
-(float)findRoot:(float)f0 :(float)f1 :(float)f2 :(float)f3 :(float)f;

@end

@implementation NezAnimatedModel

-(id)initWithModel:(NezBonedModel*)modelObject {
	if (self = [super init]) {
		model = [modelObject retain];
		boneCount = model->boneCount;
		boneArray = malloc(sizeof(Bone)*boneCount);
		memcpy(boneArray, model->basePoseBoneArray, sizeof(Bone)*boneCount);

		currentMotion = 0;
		currentFrame = 0.0f;
		loopAnimation = YES;
		
		callbackObject = nil;
		animationFinishedCallback = nil;
	}
	return self;
}

- (void)dealloc {
	if (boneArray) {
		free(boneArray);
	}
	if (model) {
		[model release];
	}
	[super dealloc];
}

-(void)setAnimationFinishedCallback:(id)obj Selector:(SEL)callback {
	callbackObject = obj;
	animationFinishedCallback = callback;
}

-(void)setMotion:(int)motionIndex {
	NezGmoMotion *motion = [model->motionArray objectAtIndex:motionIndex];
	
	currentMotion = motionIndex;
	currentFrame = motion->frameLoop[0];
	[self updateWithFramesElapsed:0];
}

-(void)setCurrentFrame:(float)frame {
	currentFrame = frame;
	[self updateWithFramesElapsed:0];
}

-(void)updateWithFramesElapsed:(float)framesElapsed {
	float tmp[16];
	NezGmoMotion *motion = [model->motionArray objectAtIndex:currentMotion];
	
	currentFrame += framesElapsed;
	if (currentFrame > (int)motion->frameLoop[1]) {
		if (loopAnimation) {
			currentFrame = (int)motion->frameLoop[0];
			if (callbackObject && animationFinishedCallback) {
				[callbackObject performSelector:animationFinishedCallback];
				return;
			}
		} else {
			currentFrame = (int)motion->frameLoop[1];
		}
	}
	if (currentFrame < (int)motion->frameLoop[0]) {
		currentFrame = (int)motion->frameLoop[0];
	}
	
	for (NezGmoAnimate *animate in motion->animationArray) {
		if (animate->index >= boneCount || animate->fCurve >= [motion->fCurveArray count]) {
			continue;
		}
		NezGmoFCurve *fcurve = [motion->fCurveArray objectAtIndex:animate->fCurve];
		Bone *bone = &boneArray[animate->index];		
		
		switch (animate->type) {
			case GMO_BONE : {
				switch (animate->cmd) {
					case GMO_TRANSLATE:
						[self FCurveEval :fcurve :currentFrame :bone->translate];
						bone->updateFlags |= HAS_TRANSLATE;
						break;
					case GMO_ROTATE_Q:
						[self FCurveEval :fcurve :currentFrame :tmp];
						QuaternionGetInverse(tmp, bone->rotate);
						bone->updateFlags |= HAS_ROTATE;
						break;
					case GMO_ROTATE_ZYX:
						NSLog(@"      GMO_ROTATE_ZYX");
						break;
					case GMO_ROTATE_YXZ:
						NSLog(@"      GMO_ROTATE_YXZ");
						break;
					case GMO_SCALE:
						NSLog(@"      GMO_SCALE");
						break;
					case GMO_SCALE_2:
						[self FCurveEval :fcurve :currentFrame :bone->scale];
						bone->updateFlags |= HAS_SCALE;
						break;
					case GMO_SCALE_3:
						NSLog(@"      GMO_SCALE_3");
						break;
					case GMO_MULT_MATRIX:
						NSLog(@"      GMO_MULT_MATRIX");
						break;
					case GMO_MORPH_WEIGHTS:
						NSLog(@"      GMO_MORPH_WEIGHTS");
						break;
					case GMO_MORPH_INDEX:
						NSLog(@"      GMO_MORPH_INDEX");
						break ;
					case GMO_VISIBILITY:
						NSLog(@"      GMO_VISIBILITY");
						break;
					default :
						NSLog(@"      SHITE!!!");
						break;
				}
				break;
			}
			case GMO_MATERIAL : {
				NSLog(@"   GMO_MATERIAL, material index:%d", animate->index);
				break ;
			}
		}
	}
	float parentMatrix[16], localBoneMatrix[16];
	for (int i=0; i<boneCount; i++) {
		Bone *bone = &boneArray[i];
		Bone *baseBone = &model->basePoseBoneArray[i];

		if(bone->parent == -1) {
			if (!bone->updateFlags) {
				MatrixGetIdentity(parentMatrix);
				continue;
			} else {
				MatrixGetIdentity(parentMatrix);
			}
		} else {
			if (!bone->updateFlags) {
				Bone *parentBone = &boneArray[bone->parent];
				MatrixCopy(parentBone->currentMatrix, bone->currentMatrix);
				continue;
			} else {
				Bone *parentBone = &boneArray[bone->parent];
				MatrixCopy(parentBone->currentMatrix, parentMatrix);
			}
		}
		if (bone->updateFlags&HAS_ROTATE) {
			QuaternionToMatrix(bone->rotate, localBoneMatrix);
		} else {
			QuaternionToMatrix(baseBone->rotate, localBoneMatrix);
		}
		if (bone->updateFlags&HAS_SCALE) {
			MatrixMultiplyScale(localBoneMatrix, bone->scale, localBoneMatrix);
		} else {
			MatrixMultiplyScale(localBoneMatrix, baseBone->scale, localBoneMatrix);
		}
		if (bone->updateFlags&HAS_TRANSLATE) {
			localBoneMatrix[12] = bone->translate[0];
			localBoneMatrix[13] = bone->translate[1];
			localBoneMatrix[14] = bone->translate[2];
		} else {
			localBoneMatrix[12] = baseBone->translate[0];
			localBoneMatrix[13] = baseBone->translate[1];
			localBoneMatrix[14] = baseBone->translate[2];
		}
		MatrixMultiply(parentMatrix, localBoneMatrix, bone->currentMatrix);
		bone->updateFlags = 0;
	}
}

-(void)drawWithMatrix:(float*)matrix {
	[model drawWithMatrix:matrix BoneArray:boneArray];
}

-(void)drawWithMatrix:(float*)matrix andProgram:(GLSLProgram*)program {
	[model drawWithMatrix:matrix BoneArray:boneArray andProgram:program];
}

-(void)getCameraLookatPosition:(vec4*)outPos {
	int boneIndex = model->cameraLookAtBone;
	Bone *bone = &boneArray[boneIndex];
	float *m = bone->currentMatrix;
	vec4 pos = {0,0,0,1};
	MatrixMultVec4(m, &pos.x, &outPos->x);
}

//----------------------------------------------------------------
//  fcurve calculation
//----------------------------------------------------------------

-(int)FCurveEval:(const NezGmoFCurve*)fcurve :(float)frame :(float*)output {
	memset(output, 0, fcurve->dims*sizeof(float));
	static char Elements[] = { 1, 1, 3, 5, 1 } ;
	
	int format = fcurve->format ;
	
	if (format & GMO_FCURVE_FLOAT16) {
		return [self FCurveEvalHalfFloat:fcurve :frame :output];
	}
	
	int interp = GMO_FCURVE_INTERP_MASK & format ;
	int n_dims = fcurve->dims ;
	int n_elems = Elements[ interp ] ;
	int stride = n_elems * n_dims + 1 ;
	
	float *data = (float *)(fcurve->data);
	int lower = 0 ;
	int upper = fcurve->keys - 1 ;
	
	int extrap = GMO_FCURVE_EXTRAP_MASK & format ;
	if (extrap != GMO_FCURVE_HOLD) {
		frame = [self extrapFrame:frame :data[0] :data[stride*upper] :extrap];
	}
	
	while ( upper - lower > 1 ) {
		int idx = ( upper + lower ) / 2 ;
		float frame2 = data[ stride * idx ] ;
		if ( frame < frame2 ) {
			upper = idx ;
		} else {
			lower = idx ;
		}
	}
	
	float *k1 = data + stride * lower ;
	float *k2 = data + stride * upper ;
	float f1 = *( k1 ++ ) ;
	float f2 = *( k2 ++ ) ;
	float t = f2 - f1 ;
	if ( t != 0.0f ) t = ( frame - f1 ) / t ;
	if ( t <= 0.0f ) {
		interp = GMO_FCURVE_CONSTANT ;
	} else if ( t >= 1.0f ) {
		interp = GMO_FCURVE_CONSTANT ;
		k1 = k2 ;
	}
	
	switch (interp) {
		case GMO_FCURVE_CONSTANT : {
			for ( int i = 0 ; i < n_dims ; i ++ ) {
				*( output ++ ) = *k1 ;
				k1 += n_elems ;
			}
			break ;
	    }
	    case GMO_FCURVE_LINEAR : {
			for ( int i = 0 ; i < n_dims ; i ++ ) {
				float v1 = *( k1 ++ ) ;
				float v2 = *( k2 ++ ) ;
				*( output ++ ) = ( v2 - v1 ) * t + v1 ;
			}
			break ;
	    }
	    case GMO_FCURVE_HERMITE : {
			float s = 1.0f - t ;
			float t2 = t * t ;
			float s2 = s * s ;
			float b1 = s2 * t * 3.0f ;
			float b2 = t2 * s * 3.0f ;
			float b0 = s2 * s + b1 ;
			float b3 = t2 * t + b2 ;
			for ( int i = 0 ; i < n_dims ; i ++ ) {
				*( output ++ ) = k1[ 0 ] * b0 + k1[ 2 ] * b1 + k2[ 1 ] * b2 + k2[ 0 ] * b3 ;
				k1 += 3 ;
				k2 += 3 ;
			}
			break ;
	    }
	    case GMO_FCURVE_CUBIC : {
			for ( int i = 0 ; i < n_dims ; i ++ ) {
				float fa = f1 + k1[ 3 ] ;
				float fb = f2 + k2[ 1 ] ;
				float t = [self findRoot:f1 :fa :fb :f2 :frame];
				float s = 1.0f - t ;
				float t2 = t * t ;
				float s2 = s * s ;
				float b1 = s2 * t * 3.0f ;
				float b2 = t2 * s * 3.0f ;
				float b0 = s2 * s + b1 ;
				float b3 = t2 * t + b2 ;
				*( output ++ ) = k1[ 0 ] * b0 + k1[ 4 ] * b1 + k2[ 2 ] * b2 + k2[ 0 ] * b3 ;
				k1 += 5 ;
				k2 += 5 ;
			}
			break ;
	    }
	    case GMO_FCURVE_SPHERICAL : {
			QuaternionSlerp((float*)k1, (float*)k2, t, (float*)output);
			break ;
	    }
	}
	return fcurve->dims;
}

-(int)FCurveEvalHalfFloat:(const NezGmoFCurve*)fcurve :(float)frame :(float*)output {
	static char Elements[] = { 1, 1, 3, 5, 1 } ;
	
	int format = fcurve->format ;
	int interp = GMO_FCURVE_INTERP_MASK & format;
	int n_dims = fcurve->dims;
	int n_elems = Elements[interp];
	int stride = n_elems * n_dims + 1;
	
	short *data = (short *)(fcurve->data);
	int lower = 0 ;
	int upper = fcurve->keys-1;
	
	int extrap = GMO_FCURVE_EXTRAP_MASK & format;
	
	if (extrap != GMO_FCURVE_HOLD) {
		frame = [self extrapFrame:frame :data[0] :data[stride * upper] :extrap];
	}
	
	while (upper - lower > 1) {
		int idx = (upper + lower)/2;
		float frame2 = [self halfToFloat:data[stride*idx]];
		if (frame < frame2) {
			upper = idx ;
		} else {
			lower = idx ;
		}
	}
	
	short *k1 = data + stride * lower;
	short *k2 = data + stride * upper;
	float f1 = [self halfToFloat:*(k1++)];
	float f2 = [self halfToFloat:*(k2++)];
	float t = f2 - f1;
	if (t != 0.0f) t = (frame - f1)/t;
	if (t <= 0.0f) {
		interp = GMO_FCURVE_CONSTANT;
	} else if (t >= 1.0f) {
		interp = GMO_FCURVE_CONSTANT;
		k1 = k2 ;
	}
	
	switch (interp) {
	    case GMO_FCURVE_CONSTANT : {
			for ( int i = 0 ; i < n_dims ; i ++ ) {
				*(output++) = [self halfToFloat:*k1];
				k1 += n_elems;
			}
			break ;
	    }
		case GMO_FCURVE_LINEAR : {
			for ( int i = 0 ; i < n_dims ; i ++ ) {
				float v1 = [self halfToFloat:*(k1++)];
				float v2 = [self halfToFloat:*(k2++)];
				*(output++) = (v2 - v1) * t + v1;
			}
			break ;
	    }
	    case GMO_FCURVE_HERMITE : {
			float s = 1.0f - t;
			float t2 = t * t;
			float s2 = s * s;
			float b1 = s2 * t * 3.0f;
			float b2 = t2 * s * 3.0f;
			float b0 = s2 * s + b1;
			float b3 = t2 * t + b2;
			for ( int i = 0; i < n_dims; i++) {
				float v = [self halfToFloat:k1[0]] * b0;
				v += [self halfToFloat:k1[2]] * b1;
				v += [self halfToFloat:k2[1]] * b2;
				v += [self halfToFloat:k2[0]] * b3;
				*(output++) = v ;
				k1 += 3 ;
				k2 += 3 ;
			}
			break ;
	    }
	    case GMO_FCURVE_CUBIC : {
			for ( int i = 0 ; i < n_dims ; i ++ ) {
				float fa = f1 + [self halfToFloat:k1[3]];
				float fb = f2 + [self halfToFloat:k2[1]];
				float t = [self findRoot:f1 :fa :fb :f2 :frame];
				float s = 1.0f - t ;
				float t2 = t * t ;
				float s2 = s * s ;
				float b1 = s2 * t * 3.0f ;
				float b2 = t2 * s * 3.0f ;
				float b0 = s2 * s + b1 ;
				float b3 = t2 * t + b2 ;
				float v = [self halfToFloat:k1[0]] * b0;
				v += [self halfToFloat:k1[4]] * b1;
				v += [self halfToFloat:k2[2]] * b2;
				v += [self halfToFloat:k2[0]] * b3;
				*(output++) = v;
				k1 += 5;
				k2 += 5;
			}
			break ;
	    }
	    case GMO_FCURVE_SPHERICAL : {
			float q1[4], q2[4];
			q1[0] = [self halfToFloat:k1[0]];
			q1[1] = [self halfToFloat:k1[1]];
			q1[2] = [self halfToFloat:k1[2]];
			q1[3] = [self halfToFloat:k1[3]];
			q2[0] = [self halfToFloat:k2[0]];
			q2[1] = [self halfToFloat:k2[1]];
			q2[2] = [self halfToFloat:k2[2]];
			q2[3] = [self halfToFloat:k2[3]];
			QuaternionSlerp(q1, q2, t, output);
			break ;
	    }
	}
	
	return fcurve->dims ;
}

-(float)halfToFloat:(int)val {
	union {
		float val ;
		int bits ;
	} tmp ;
	int e = ( val >> 10 ) & 0x1f ;
	if ( ( val & 0x7fff ) != 0 ) {
		e += ( 127 - 15 ) ;
	}
	int f = ( val & 0x3ff ) << 13 ;
	int s = ( val & 0x8000 ) << 16 ;
	tmp.bits = s | f | ( e << 23 ) ;
	return tmp.val ;
}

#define FMODF(x,y) ( (x) - (int)( (x) / (y) ) * (y) )

-(float)extrapFrame:(float)frame :(float)start :(float)end :(int)extrap {
	frame -= start ;
	end -= start ;
	
	if (frame < 0.0f) {
		switch (GMO_FCURVE_EXTRAP_LEFT_MASK & extrap) {
			case GMO_FCURVE_HOLD_LEFT :
				frame = 0.0f ;
				break ;
			case GMO_FCURVE_CYCLE_LEFT :
				frame = FMODF( frame, end ) + end ;
				break ;
			case GMO_FCURVE_SHUTTLE_LEFT :
				end += end ;
				frame = FMODF( frame, end ) + end ;
				if ( frame > end - frame ) frame = end - frame ;
				break ;
			case GMO_FCURVE_REPEAT_LEFT :	// not implemented
			case GMO_FCURVE_EXTEND_LEFT :	// not implemented
				frame = 0.0f ;
				break ;
		}
	} else if (frame >= end) {
		switch (GMO_FCURVE_EXTRAP_RIGHT_MASK & extrap ) {
		    case GMO_FCURVE_HOLD_RIGHT :
				frame = end ;
				break ;
		    case GMO_FCURVE_CYCLE_RIGHT :
				frame = FMODF( frame, end ) ;
				break ;
		    case GMO_FCURVE_SHUTTLE_RIGHT :
				end += end ;
				frame = FMODF( frame, end ) ;
				if ( frame > end - frame ) frame = end - frame ;
				break ;
		    case GMO_FCURVE_REPEAT_RIGHT :	// not implemented
		    case GMO_FCURVE_EXTEND_RIGHT :	// not implemented
				frame = end ;
				break ;
		}
	}
	return start + frame ;
}

-(float)findRoot:(float)f0 :(float)f1 :(float)f2 :(float)f3 :(float)f {
	float E = ( f3 - f0 ) * 0.01f ;
	if ( E < 0.0001f ) E = 0.0001f ;
	float t0 = 0.0f ;
	float t3 = 1.0f ;
	for ( int i = 0 ; i < 8 ; i ++ ) {
		float d = f3 - f0 ;
		if ( d > -E && d < E ) break ;
		float r = ( f2 - f1 ) / d - ( 1.0f / 3.0f ) ;
		if ( r > -0.01f && r < 0.01f ) break ;
		float fc = ( f0 + f1 * 3.0f + f2 * 3.0f + f3 ) / 8.0f ;
		if ( f < fc ) {
			f3 = fc ;
			f2 = ( f1 + f2 ) * 0.5f ;
			f1 = ( f0 + f1 ) * 0.5f ;
			f2 = ( f1 + f2 ) * 0.5f ;
			t3 = ( t0 + t3 ) * 0.5f ;
		} else {
			f0 = fc ;
			f1 = ( f1 + f2 ) * 0.5f ;
			f2 = ( f2 + f3 ) * 0.5f ;
			f1 = ( f1 + f2 ) * 0.5f ;
			t0 = ( t0 + t3 ) * 0.5f ;
		}
	}
	float c = f0 - f ;
	float b = 3.0f * ( f1 - f0 ) ;
	float a = f3 - f0 - b ;
	float x ;
	if ( a == 0.0f ) {
		x = ( b == 0.0f ) ? 0.5f : -c / b ;
	} else {
		float D2 = b * b - 4.0f * a * c ;
		if ( D2 < 0.0f ) D2 = 0.0f ;
		D2 = sqrtf( D2 ) ;
		if ( a + b < 0.0f ) D2 = -D2 ;
		x = ( -b + D2 ) / ( 2.0f * a ) ;
	}
	return ( t3 - t0 ) * x + t0 ;
}

@end
