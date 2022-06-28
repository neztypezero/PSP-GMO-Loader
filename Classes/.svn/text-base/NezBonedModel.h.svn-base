//
//  NezBonedModel.h
//  GmoLoader
//
//  Created by David Nesbitt on 9/2/10.
//  Copyright 2010 NezSoft. All rights reserved.
//
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "GLSLProgramManager.h"
#import "GLSLProgram.h"

#import "NezBonedModelStructures.h"

@interface NezBonedModel : NSObject {
	
@public
	Part *partArray;
	int partCount;
	
	Bone *basePoseBoneArray;
	int boneCount;
	
	Material *materialArray;
	int materialCount;
	
	TextureInfo *textureArray;
	int textureCount;
	
	vec3 boundingBox[2];
	
	int cameraLookAtBone;
	
	GLSLProgram *programObject;
	GLSLProgram *programObjectMultColors;
	
	NSMutableArray *motionArray;
	
	int drawCallCount;
}

-(void)drawWithMatrix:(float*)matrix;
-(void)drawWithMatrix:(float*)matrix andProgram:(GLSLProgram*)program;
-(void)drawWithMatrix:(float*)matrix BoneArray:(Bone*)boneArray;
-(void)drawWithMatrix:(float*)matrix BoneArray:(Bone*)boneArray andProgram:(GLSLProgram*)program;
-(void)drawWithProjectionMatrix:(float*)projectionMatrix CameraMatrix:(float*)cameraMatrix;
-(void)drawWithProjectionMatrix:(float*)projectionMatrix CameraMatrix:(float*)cameraMatrix andProgram:(GLSLProgram*)program;
-(void)drawWithBoneArray:(Bone*)boneArray andProgram:(GLSLProgram*)program;
							
@end
