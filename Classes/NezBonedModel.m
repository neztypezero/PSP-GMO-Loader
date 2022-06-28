//
//  NezBonedModel.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/2/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezBonedModel.h"
#import "Math.h"

static const void *POSITION_OFFSET;
static const void *NORMAL_OFFSET;
static const void *UV_OFFSET;
static const void *COLOR_OFFSET;
static const void *INDEX_ARRAY_OFFSET;
static const void *WEIGHT_ARRAY_OFFSET;

@implementation NezBonedModel

#define ADDR_OFFSET(a, b) ((const void*)((unsigned int)a-(unsigned int)b))

+ (void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
		Vertex v; 
		
		POSITION_OFFSET     = ADDR_OFFSET(v.pos, v.pos);
		NORMAL_OFFSET       = ADDR_OFFSET(v.normal, v.pos);
		UV_OFFSET           = ADDR_OFFSET(v.uv, v.pos);
		COLOR_OFFSET        = ADDR_OFFSET(v.color, v.pos);
		INDEX_ARRAY_OFFSET  = ADDR_OFFSET(v.indexArray, v.pos);
		WEIGHT_ARRAY_OFFSET = ADDR_OFFSET(v.weightArray, v.pos);

        initialized = YES;
    }
}

- (id)init {
	if ((self = [super init])) {
		programObject = [[[GLSLProgramManager instance] loadProgram:@"BonedModel"] retain];
		programObjectMultColors = [[[GLSLProgramManager instance] loadProgram:@"BonedModelMultColors"] retain];
		cameraLookAtBone = 0;
	}
	return self;
}

- (void)dealloc {
	if (basePoseBoneArray) {
		free(basePoseBoneArray);
	}
	if (motionArray) {
		[motionArray removeAllObjects];
		[motionArray release];
	}
	[programObject release];
	[programObjectMultColors release];
	[super dealloc];
}

-(void)drawWithMatrix:(float*)matrix {
	[self drawWithMatrix:matrix andProgram:programObject];
}

-(void)drawWithMatrix:(float*)matrix andProgram:(GLSLProgram*)program {
	[self drawWithMatrix:matrix BoneArray:basePoseBoneArray];
}

-(void)drawWithMatrix:(float*)matrix BoneArray:(Bone*)boneArray {
	[self drawWithMatrix:matrix BoneArray:boneArray andProgram:programObject];
}

-(void)drawWithMatrix:(float*)matrix BoneArray:(Bone*)boneArray andProgram:(GLSLProgram*)program {
	// Use shader program
    glUseProgram(program->program);
	
    // Update uniform value
	glUniformMatrix4fv(program->u_modelViewProjectionMatrix, 1, GL_FALSE, matrix);
	
	// Set the sampler texture unit to 0
	glEnable(GL_TEXTURE);
	glActiveTexture(GL_TEXTURE0);
	glUniform1i(program->u_sampler, 0);
	
    glEnableVertexAttribArray(program->a_position);
    glEnableVertexAttribArray(program->a_normal);
    glEnableVertexAttribArray(program->a_uv);
    glEnableVertexAttribArray(program->a_color);
	glEnableVertexAttribArray(program->a_indexArray);
    glEnableVertexAttribArray(program->a_weightArray);
	
	[self drawWithBoneArray:boneArray andProgram:program];
	/*

	GLSLProgram *p = [[GLSLProgramManager instance] loadProgram:@"Blit"];
	
    glUseProgram(p->program);
	glUniformMatrix4fv(p->u_modelViewProjectionMatrix, 1, GL_FALSE, matrix);
	
	vec4 line[256];
	vec4 point = {0,0,0,1};
	
	glDisable(GL_DEPTH_TEST);
	
    glEnableVertexAttribArray(p->a_position);

	int count = 0;
	for (int i=0; i<boneCount; i++) {
		Bone *bone = &boneArray[i];
		if (bone->parent > -1) {
			Bone *pbone = &boneArray[bone->parent];
			MatrixMultVec4(bone->currentMatrix, &point, &line[count++]);
			MatrixMultVec4(pbone->currentMatrix, &point, &line[count++]);
		}
	}
	for (int z=0; z<2; z++) {
		for (int y=0; y<2; y++) {
			for (int x=0; x<2; x++) {
				line[count].x = boundingBox[x].x;
				line[count].y = boundingBox[y].y;
				line[count].z = boundingBox[z].z;
				line[count++].w = 1;
			}
		}
	}

	line[count].x = boundingBox[0].x;
	line[count].y = boundingBox[0].y;
	line[count].z = boundingBox[0].z;
	line[count++].w = 1;

	line[count].x = boundingBox[1].x;
	line[count].y = boundingBox[1].y;
	line[count].z = boundingBox[1].z;
	line[count++].w = 1;

	glVertexAttribPointer(p->a_position, 4, GL_FLOAT, GL_FALSE, 0, line);
	glDrawArrays(GL_LINES, 0, count);
	 */
}

-(void)drawWithProjectionMatrix:(float*)projectionMatrix CameraMatrix:(float*)cameraMatrix {
	[self drawWithProjectionMatrix:projectionMatrix CameraMatrix:cameraMatrix andProgram:programObjectMultColors];
}

-(void)drawWithProjectionMatrix:(float*)projectionMatrix CameraMatrix:(float*)cameraMatrix andProgram:(GLSLProgram*)program {
	// Use shader program
    glUseProgram(program->program);
	
	// Set the sampler texture unit to 0
	glEnable(GL_TEXTURE);
	glActiveTexture(GL_TEXTURE0);
	glUniform1i(program->u_sampler, 0);
	
    glEnableVertexAttribArray(program->a_position);
    glEnableVertexAttribArray(program->a_normal);
    glEnableVertexAttribArray(program->a_uv);
    glEnableVertexAttribArray(program->a_color);
	glDisableVertexAttribArray(program->a_indexArray);
    glDisableVertexAttribArray(program->a_weightArray);
	
	Bone *boneArray = basePoseBoneArray;

	glEnable(GL_BLEND);
	
	float modelViewMatrix[16];
	float mvpMatrix[16];
	
	for (int i=0; i<boneCount; i++) {
		Bone *bone = &boneArray[i];
		
		if (bone->partIndex == -1) {
			continue;
		}
		
		Part *part = &partArray[bone->partIndex];
		
		MatrixMultiply(cameraMatrix, bone->currentMatrix, modelViewMatrix);
		MatrixMultiply(projectionMatrix, modelViewMatrix, mvpMatrix);
		
		glUniformMatrix4fv(program->u_modelViewProjectionMatrix, 1, GL_FALSE, mvpMatrix);
		
		for (int j=0; j<part->meshCount; j++) {
			for (int j=0; j<part->meshCount; j++) {
				Mesh *mesh = &part->meshArray[j];

				Material *material = &materialArray[mesh->materialIndex];
				if (material->enableMask == 32) {
					glDepthMask(GL_FALSE);
				} else {
					glDepthMask(GL_TRUE);
				}
				for (int layerIndex=0; layerIndex<material->layerCount; layerIndex++) { // More than 1 layer means multiple passes?
					glBlendEquation(material->layerArray[layerIndex].blendFunc[0]);
					glBlendFunc(material->layerArray[layerIndex].blendFunc[1], material->layerArray[layerIndex].blendFunc[2]);
					glBindTexture(GL_TEXTURE_2D, textureArray[material->layerArray[layerIndex].textureIndex].name);
					for (int k=0; k<mesh->indexArrayCount; k++) {
						IndexArray *indexArray = &mesh->indexArrayArray[k];
						
						VertexArray *va = &part->vertexArrayArray[indexArray->vertexArrayIndex];
						
						glBindBuffer(GL_ARRAY_BUFFER, va->vboPtr);
						glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexArray->vboPtr); 
						
						glUniform1i(program->u_blendCount, 0);
						
						int stride = va->vertexStride;
						glVertexAttribPointer(program->a_position, 3, GL_FLOAT, GL_FALSE, stride, POSITION_OFFSET);
						glVertexAttribPointer(program->a_normal, 3, GL_FLOAT, GL_FALSE, stride, NORMAL_OFFSET);
						glVertexAttribPointer(program->a_uv, 2, GL_FLOAT, GL_FALSE, stride, UV_OFFSET);
						glVertexAttribPointer(program->a_color, 4, GL_UNSIGNED_BYTE, GL_TRUE, stride, COLOR_OFFSET);
						glDrawElements(GL_TRIANGLES, indexArray->indexCount, GL_UNSIGNED_SHORT, 0);
					}
				}
			}
		}
	}
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); 
}

-(void)drawWithBoneArray:(Bone*)boneArray andProgram:(GLSLProgram*)program {
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	static GLfloat matrixPalette[MATRIX_PALETTE_ENTRIES*4*3]; //Row major order matrix palette

	drawCallCount = 0;
	
	for (int i=0; i<partCount; i++) {
		Part *part = &partArray[i];
		if (part->state & PART_INVISIBLE) {
			continue;
		}
		for (int j=0; j<part->meshCount; j++) {
			Mesh *mesh = &part->meshArray[j];
			for (int idx=0; idx<mesh->blendIndexCount; idx++) {
				int idx2 = part->boneIndexArray[mesh->blendIndexArray[idx]];

				GLfloat *matrix = boneArray[idx2].currentMatrix;
				GLfloat *inverseMatrix = boneArray[idx2].inverseMatrix;
				GLfloat m[16];
				
				MatrixMultiply(matrix, inverseMatrix, m);
				
				int matIdx = idx*12;
				matrixPalette[matIdx+0] = m[0]; matrixPalette[matIdx+1] = m[4]; matrixPalette[matIdx+2 ] = m[8 ]; matrixPalette[matIdx+3 ] = m[12]; //row0
				matrixPalette[matIdx+4] = m[1]; matrixPalette[matIdx+5] = m[5]; matrixPalette[matIdx+6 ] = m[9 ]; matrixPalette[matIdx+7 ] = m[13]; //row1
				matrixPalette[matIdx+8] = m[2]; matrixPalette[matIdx+9] = m[6]; matrixPalette[matIdx+10] = m[10]; matrixPalette[matIdx+11] = m[14]; //row2
			}
			// Set the matrix palette uniform 3 rows per matrix
			glUniform4fv(program->u_matPal, mesh->blendIndexCount*3, matrixPalette);

			Material *material = &materialArray[mesh->materialIndex];
			for (int layerIndex=0; layerIndex<material->layerCount; layerIndex++) { // More than 1 layer means multiple passes?
				glBindTexture(GL_TEXTURE_2D, textureArray[material->layerArray[layerIndex].textureIndex].name);
				for (int k=0; k<mesh->indexArrayCount; k++) {
					IndexArray *indexArray = &mesh->indexArrayArray[k];

					VertexArray *va = &part->vertexArrayArray[indexArray->vertexArrayIndex];

					glBindBuffer(GL_ARRAY_BUFFER, va->vboPtr);
					glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexArray->vboPtr); 
					
					glUniform1i(program->u_blendCount, va->maxBlendCount);

					int stride = va->vertexStride;
					glVertexAttribPointer(program->a_position, 3, GL_FLOAT, GL_FALSE, stride, POSITION_OFFSET);
					glVertexAttribPointer(program->a_normal, 3, GL_FLOAT, GL_FALSE, stride, NORMAL_OFFSET);
					glVertexAttribPointer(program->a_uv, 2, GL_FLOAT, GL_FALSE, stride, UV_OFFSET);
					glVertexAttribPointer(program->a_color, 4, GL_UNSIGNED_BYTE, GL_TRUE, stride, COLOR_OFFSET);
					glVertexAttribPointer(program->a_indexArray, va->maxBlendCount, GL_UNSIGNED_BYTE, GL_FALSE, stride, INDEX_ARRAY_OFFSET);
					glVertexAttribPointer(program->a_weightArray, va->maxBlendCount, GL_FLOAT, GL_FALSE, stride, WEIGHT_ARRAY_OFFSET); 
					glDrawElements(GL_TRIANGLES, indexArray->indexCount, GL_UNSIGNED_SHORT, 0);
					drawCallCount++;
				}
			}
		}
	}
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); 
}

@end
