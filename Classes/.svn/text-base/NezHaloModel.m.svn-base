//
//  NezHaloModel.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/13/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezHaloModel.h"

@implementation NezHaloModel

-(id)initWithModel:(NezBonedModel*)modelObject {
	if (self = [super initWithModel:modelObject]) {
		haloScale = 0.0f;
		haloScaleMax = 0.0f;
		haloIncrement = 0.002f;
		haloProgram = [[[GLSLProgramManager instance] loadProgram:@"HaloModel"] retain];
	}
	return self;
}

-(void)setHaloIncrement:(float)scale {
	haloScaleMax = scale;
}

-(void)setHaloScaleMax:(float)scale {
	haloScaleMax = scale;
	haloIncrementing = YES;
}

-(void)updateWithFramesElapsed:(float)framesElapsed {
	[super updateWithFramesElapsed:framesElapsed];
	if (haloScaleMax > 0.0f) {
		if (haloIncrementing) {
			haloScale += (haloIncrement*framesElapsed);
			if (haloScale > haloScaleMax) {
				haloScale = haloScaleMax;
				haloIncrementing = NO;
			}
		} else {
			haloScale -= (haloIncrement*framesElapsed);
			if (haloScale <= 0.0f) {
				haloScale = 0.0f;
				haloIncrementing = YES;
			}
		}
	}
}

-(void)drawWithMatrix:(float*)matrix {
	if (haloScaleMax > 0.0f) {
		glEnable(GL_STENCIL_TEST);
		glStencilFunc(GL_ALWAYS, 0x2, 0x2);
		glStencilMask(0x2);
		glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
	}
	[model drawWithMatrix:matrix BoneArray:boneArray];
	if (haloScaleMax > 0.0f) {
		glEnable(GL_BLEND);
		glStencilFunc(GL_NOTEQUAL, 0x2, 0x2);
		glStencilMask(0x2);
		glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

		glUseProgram(haloProgram->program);
		
		// Update uniform value
		glUniformMatrix4fv(haloProgram->u_modelViewProjectionMatrix, 1, GL_FALSE, matrix);
		glUniform1f(haloProgram->u_haloScale, haloScale);
		
		glEnableVertexAttribArray(haloProgram->a_position);
		glEnableVertexAttribArray(haloProgram->a_normal);
		glEnableVertexAttribArray(haloProgram->a_uv);
		glEnableVertexAttribArray(haloProgram->a_color);
		glEnableVertexAttribArray(haloProgram->a_indexArray);
		glEnableVertexAttribArray(haloProgram->a_weightArray);
		
		[model drawWithBoneArray:boneArray andProgram:haloProgram];
		
		glDisable(GL_BLEND);
		glDisable(GL_STENCIL_TEST);
	}
}

@end
