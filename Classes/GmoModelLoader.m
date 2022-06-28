//
//  GmoModelLoader.m
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright 2010 NezSoft. All rights reserved.
//
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "GmoModelLoader.h"
#import "GmoDataStructures.h"
#import "GimDataStructures.h"
#import "Math.h"
#import "NezBonedModel.h"
#import "DataResourceManager.h"
#import "TextureManager.h"

@interface IndexRepair : NSObject {

@public
	int oldBlendOffsetIndex;
	int newBlendOffsetIndex;
	int blendIndex;
	int addIndex;
}

@end

@implementation IndexRepair

-(id)init {
	if (self = [super init]) {
		oldBlendOffsetIndex = -1;
		newBlendOffsetIndex = -1;
		blendIndex = -1;
		addIndex = 0;
	}
	return self;
}

-(NSComparisonResult)compareAddIndex:(IndexRepair*)other {
	if (addIndex == other->addIndex) {
		if (blendIndex != other->blendIndex) {
			return (blendIndex < other->blendIndex ? NSOrderedAscending : NSOrderedDescending);
		}
		return NSOrderedSame;
	}
	return (addIndex < other->addIndex ? NSOrderedAscending : NSOrderedDescending);
}

-(NSComparisonResult)compareBlendIndex:(IndexRepair*)other {
	if (blendIndex == other->blendIndex) return NSOrderedSame;
	return (blendIndex < other->blendIndex ? NSOrderedAscending : NSOrderedDescending);
}

-(NSComparisonResult)compareOldBlendOffsetIndex:(IndexRepair*)other {
	if (oldBlendOffsetIndex == other->oldBlendOffsetIndex) return NSOrderedSame;
	return (oldBlendOffsetIndex < other->oldBlendOffsetIndex ? NSOrderedAscending : NSOrderedDescending);
}

@end


@interface GmoModelLoader (private)

-(NezBonedModel*)loadGmo:(const void *)gmoBuffer;

-(void)loadGmoChunksWithRootChild:(const GmoChunk*)chunk Type:(int)type;

-(void)loadGmoPart:(const GmoChunk*)chunk;
-(void)loadGmoMesh:(const GmoChunk*)chunk Part:(NezGmoPart*)part;
-(void)loadGmoMeshDrawArrays:(const GmoChunk*)chunk Mesh:(NezGmoMesh*)mesh;
-(void)loadGmoVertexArray:(const GmoChunk*)chunk Part:(NezGmoPart*)part;
-(void*)loadGmoVertex:(void*)buffer Format:(int)format Array:(NSMutableArray*)array;

-(void)loadGmoBone:(const GmoChunk*)chunk;

-(void)loadGmoMaterial:(const GmoChunk*)chunk;
-(NezGmoLayer*)loadGmoLayer:(const GmoChunk*)chunk;

-(void)loadGmoTexture:(const GmoChunk*)chunk;
-(void)loadGim:(const GimChunk*)chunk Filename:(char*)filename;
-(void)loadTextureDataWithPalette:(GimPaletteHeader*)pal Image:(GimImageHeader*)img Filename:(char*)filename;

-(void)loadGmoMotion:(const GmoChunk*)chunk;

-(void)updateBoneMatrices;
-(void)initializeBoneMatrices;

-(int)FCurveEval:(const NezGmoFCurve*)fcurve :(float)frame :(float*)output;
-(int)FCurveEvalHalfFloat:(const NezGmoFCurve*)fcurve :(float)frame :(float*)output;
-(float)halfToFloat:(int)val;
-(float)extrapFrame:(float)frame :(float)start :(float)end :(int)extrap;
-(float)findRoot:(float)f0 :(float)f1 :(float)f2 :(float)f3 :(float)f;

-(void)reorganizePartData:(NezGmoPart*)part;
-(void)reorganizeVertexArrays:(NezGmoPart*)part;
-(void)reorganizeMeshData:(NezGmoPart*)part;
-(void)fixNegativeIndexes:(NSMutableDictionary*)newIndexDic AddToMesh:(NezGmoMesh*)mesh Part:(NezGmoPart*)part;

@end

@implementation GmoModelLoader

-(void)reorganizePartData:(NezGmoPart*)part {
	[self reorganizeVertexArrays:part];
	[self reorganizeMeshData:part];
}

-(void)reorganizeVertexArrays:(NezGmoPart*)part {
	for (NezGmoMesh *mesh in part->meshArray) {
		if ([mesh->blendOffsetIndexArray count] == 0) {
			for (int i=0; i<[part->blendIndexArray count]; i++) {
				[mesh->blendOffsetIndexArray addObject:[NSNumber numberWithInt:i]];
			}
		}
		int arrayIndex = 0;
		for (NSMutableArray *indexArray in mesh->indexArrayArray) {
			NSNumber *vertexArrayIndex = [mesh->vertexArrayIndexArray objectAtIndex:arrayIndex++];
			NSMutableArray *vertexArray = [part->vertexArrayArray objectAtIndex:[vertexArrayIndex intValue]];
			for (NSNumber *index in indexArray) {
				NezGmoVertex *v = [vertexArray objectAtIndex:[index intValue]];
				for (int i=0; i<v->blendCount; i++) {
					if ([mesh->blendOffsetIndexArray count] > 0) {
						NSNumber *boneIndex = [part->blendIndexArray objectAtIndex:[[mesh->blendOffsetIndexArray objectAtIndex:v->blendOffsetIndexList[i]] intValue]];
						v->blendIndexList[i] = [boneIndex intValue];
					}
				}
			}
		}
	}
	NSMutableArray *offsetArray = [NSMutableArray arrayWithCapacity:[part->vertexArrayArray count]];
	NSMutableArray *newVertexArray = [NSMutableArray arrayWithCapacity:[part->vertexArrayArray count]];
	for (NSMutableArray *vertexArray in part->vertexArrayArray) {
		[offsetArray addObject:[NSNumber numberWithInt:[newVertexArray count]]];
		[newVertexArray addObjectsFromArray:vertexArray];
	}
	[part->vertexArrayArray removeAllObjects];
	[part->vertexArrayArray addObject:newVertexArray];
	for (NezGmoMesh *mesh in part->meshArray) {
		for (int i=0; i<[mesh->vertexArrayIndexArray count]; i++) {
			NSNumber *vertexArrayIndex = [mesh->vertexArrayIndexArray objectAtIndex:i];
			[mesh->vertexArrayIndexArray replaceObjectAtIndex:i withObject:[offsetArray objectAtIndex:[vertexArrayIndex intValue]]];
		}
	}
}

-(void)reorganizeMeshData:(NezGmoPart*)part {
	NSMutableArray *oldArray = [NSMutableArray arrayWithCapacity:[part->meshArray count]];
	[oldArray addObjectsFromArray:part->meshArray];
	[part->meshArray removeAllObjects];
	for (NezGmoMesh *mesh in oldArray) {
		NSMutableDictionary *meshDic = [NSMutableDictionary dictionaryWithCapacity:2];
		NSMutableArray *mArray;
		int idx = 0;
		for (NSNumber *vaIndex in mesh->vertexArrayIndexArray) {
			mArray = [meshDic objectForKey:vaIndex];
			if (!mArray) {
				mArray = [NSMutableArray arrayWithCapacity:4];
				[meshDic setObject:mArray forKey:vaIndex];
			}
			[mArray addObject:[NSNumber numberWithInt:idx++]];
		}
		if ([meshDic count] == 1) {
			[part->meshArray addObject:mesh];
		} else {
			for (NSNumber *vaIndex in meshDic) {
				NezGmoMesh *newMesh = [NezGmoMesh makeNezGmoMesh];
				newMesh->materialIndex = mesh->materialIndex;
				[newMesh->blendOffsetIndexArray addObjectsFromArray:mesh->blendOffsetIndexArray];
				for (NSNumber *aIdx in [meshDic objectForKey:vaIndex]) {
					idx = [aIdx intValue];
					[newMesh->indexArrayArray addObject:[mesh->indexArrayArray objectAtIndex:idx]];
					[newMesh->vertexArrayIndexArray addObject:[mesh->vertexArrayIndexArray objectAtIndex:idx]];
				}
				[part->meshArray addObject:newMesh];
			}
		}
	}
	NSMutableDictionary *remainingMeshDic = [NSMutableDictionary dictionaryWithCapacity:[part->meshArray count]];
	
	for (NezGmoMesh *mesh in part->meshArray) {
		while ([mesh->vertexArrayIndexArray count] > 1) {
			[[mesh->indexArrayArray objectAtIndex:0] addObjectsFromArray:[mesh->indexArrayArray objectAtIndex:1]];
			[mesh->vertexArrayIndexArray removeObjectAtIndex:1];
			[mesh->indexArrayArray removeObjectAtIndex:1];
		}
		[remainingMeshDic setObject:mesh forKey:[NSNumber numberWithUnsignedInt:[mesh hash]]];
	}
	int materialIndex = -1;
	NSMutableArray *newIndexDicArray = [NSMutableArray arrayWithCapacity:3];
	NSMutableDictionary *newIndexDic = [NSMutableDictionary dictionaryWithCapacity:MATRIX_PALETTE_ENTRIES];
	
	[newIndexDicArray addObject:newIndexDic];
	NSMutableArray *meshArray = [NSMutableArray arrayWithCapacity:3];
	NezGmoMesh *newMesh;
	NSMutableArray *indexArray = [NSMutableArray arrayWithCapacity:128];
	
	NSMutableArray *itemsToRemoveArray = [NSMutableArray arrayWithCapacity:16];

	NSNumber *numberZero = [NSNumber numberWithInt:0];

	int maxMaterialIndex = 0;
	for (NezGmoMesh *mesh in part->meshArray) {
		if (mesh->materialIndex > maxMaterialIndex) {
			maxMaterialIndex = mesh->materialIndex;
		}
	}
	for (int matIndex=0; matIndex<=maxMaterialIndex; matIndex++) {
		for (NezGmoMesh *mesh in part->meshArray) {
			if (mesh->materialIndex != matIndex) {
				continue;
			}
			[remainingMeshDic removeObjectForKey:[NSNumber numberWithUnsignedInt:[mesh hash]]];
			if ([meshArray count] == 0) {
				materialIndex = mesh->materialIndex;
				newMesh = [NezGmoMesh makeNezGmoMesh];
				[meshArray addObject:newMesh];
				newMesh->materialIndex = materialIndex;
				[newMesh->vertexArrayIndexArray addObject:numberZero];
				[newMesh->indexArrayArray addObject:indexArray];
			}
			[itemsToRemoveArray addObject:mesh];
			int count = 0;
			for (NSNumber *index in mesh->blendOffsetIndexArray) {
				NSNumber *boneIndex = [part->blendIndexArray objectAtIndex:[index intValue]];
				if (![newIndexDic objectForKey:boneIndex]) {
					count++;
				}
			}
			if ([newIndexDic count]+count >= MATRIX_PALETTE_ENTRIES || materialIndex != mesh->materialIndex) {
				[self fixNegativeIndexes:newIndexDic AddToMesh:newMesh Part:part];
				newIndexDic = [NSMutableDictionary dictionaryWithCapacity:MATRIX_PALETTE_ENTRIES];
				if ([newIndexDicArray count] > 0) {
					NSMutableDictionary *previousIndexDic = [newIndexDicArray lastObject];
					for (NezGmoMesh *remainingMesh in [remainingMeshDic allValues]) {
						for (NSNumber *index in remainingMesh->blendOffsetIndexArray) {
							NSNumber *boneIndex = [part->blendIndexArray objectAtIndex:[index intValue]];
							IndexRepair *rep = [previousIndexDic objectForKey:boneIndex];
							if (rep) {
								[newIndexDic setObject:rep forKey:boneIndex];
							}
						}
					}
				}
				[newIndexDicArray addObject:newIndexDic];
				indexArray = [NSMutableArray arrayWithCapacity:128];
				
				newMesh = [NezGmoMesh makeNezGmoMesh];
				[meshArray addObject:newMesh];
				materialIndex = mesh->materialIndex;
				newMesh->materialIndex = materialIndex;
				[newMesh->vertexArrayIndexArray addObject:[mesh->vertexArrayIndexArray objectAtIndex:0]];
				[newMesh->indexArrayArray addObject:indexArray];
			}
			int vertexIndexOffset = [[mesh->vertexArrayIndexArray objectAtIndex:0] intValue];
			for (NSNumber *index in [mesh->indexArrayArray objectAtIndex:0]) {
				int newIndex = [index intValue]+vertexIndexOffset;
				[indexArray addObject:[NSNumber numberWithInt:newIndex]];
			}
			int oldBlendOffsetIndex=0;
			int boaIndex = 0;
			for (NSNumber *index in mesh->blendOffsetIndexArray) {
				NSNumber *boneIndex = [part->blendIndexArray objectAtIndex:[index intValue]];
				if (![newIndexDic objectForKey:boneIndex]) {
					IndexRepair *rep = [[[IndexRepair alloc] init] autorelease];
					rep->oldBlendOffsetIndex = oldBlendOffsetIndex;
					rep->blendIndex = [index intValue];
					rep->addIndex = [newIndexDic count];
					for (int i=boaIndex++; i<[mesh->blendOffsetIndexArray count]; i++) {
						NSNumber *index2 = [mesh->blendOffsetIndexArray objectAtIndex:i];
						NSNumber *boneIndex2 = [part->blendIndexArray objectAtIndex:[index2 intValue]];
						IndexRepair *rep2 = [newIndexDic objectForKey:boneIndex2];
						if (rep2) {
							rep->addIndex = rep2->addIndex;
						}
					}
					[newIndexDic setObject:rep forKey:boneIndex];
				}
				oldBlendOffsetIndex++;
			}
		}
	}
	if ([newIndexDic count] > 0) {
		[self fixNegativeIndexes:newIndexDic AddToMesh:newMesh Part:part];
	}
	
	[part->meshArray removeObjectsInArray:itemsToRemoveArray];
	
	NSMutableArray *vertexArray = [part->vertexArrayArray objectAtIndex:0];

	int meshIndex=0;
	for (NezGmoMesh *mesh in meshArray) {
		newIndexDic = [newIndexDicArray objectAtIndex:meshIndex++];
		
		IndexRepair *repArray[MATRIX_PALETTE_ENTRIES];
		for (int i=0; i<MATRIX_PALETTE_ENTRIES; i++) {
			repArray[i] = nil;
		}
		NSEnumerator *enumerator = [newIndexDic objectEnumerator];
		IndexRepair *rep;
		while ((rep = [enumerator nextObject])) {
			if (repArray[rep->newBlendOffsetIndex]) {
				NSLog(@"This is an error!(unhandled:()");
			} else {
				repArray[rep->newBlendOffsetIndex] = rep;
			}
		}
		for (int i=0; i<MATRIX_PALETTE_ENTRIES; i++) {
			if (repArray[i]) {
				[mesh->blendOffsetIndexArray addObject:[NSNumber numberWithInt:repArray[i]->blendIndex]];
			} else {
				[mesh->blendOffsetIndexArray addObject:[NSNumber numberWithInt:0]];
			}
		}
		[part->meshArray addObject:mesh];
		NSMutableArray *indexArray = [mesh->indexArrayArray objectAtIndex:0];
		for (NSNumber *index in indexArray) {
			NezGmoVertex *vertex = [vertexArray objectAtIndex:[index intValue]];
			for(int i=0;i<vertex->blendCount;i++) {
				if (vertex->boneWeightList[i] != 0) {
					rep = [newIndexDic objectForKey:[NSNumber numberWithInt:vertex->blendIndexList[i]]];
					if (rep) {
						vertex->blendOffsetIndexList[i] = rep->newBlendOffsetIndex;
					} else {
						vertex->blendOffsetIndexList[i] = 0;
					}
				}
			}
		}
	}
	for (NezGmoMesh *mesh in part->meshArray) {
		for (int i=0; i<[mesh->vertexArrayIndexArray count]; i++) {
			[mesh->vertexArrayIndexArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
		}
	}
}

-(void)fixNegativeIndexes:(NSMutableDictionary*)newIndexDic AddToMesh:(NezGmoMesh*)mesh Part:(NezGmoPart*)part {
	IndexRepair *repArray[MATRIX_PALETTE_ENTRIES];
	for (int i=0; i<MATRIX_PALETTE_ENTRIES; i++) {
		repArray[i] = nil;
	}
	NSMutableArray *notSetArray = [NSMutableArray arrayWithCapacity:MATRIX_PALETTE_ENTRIES];
	NSArray *keysInOrder = [newIndexDic keysSortedByValueUsingSelector:@selector(compareAddIndex:)];
	for (NSNumber *key in keysInOrder) {
		IndexRepair *rep = [newIndexDic objectForKey:key];
		if (rep->newBlendOffsetIndex != -1) {
			if (repArray[rep->newBlendOffsetIndex]) {
				NSLog(@"error:%d already set.", rep->newBlendOffsetIndex);
			}
			repArray[rep->newBlendOffsetIndex] = rep;
		} else {
			[notSetArray addObject:rep];
		}
	}
	int blendOffsetIndex = 0;
	for (IndexRepair *newRep in notSetArray) {
		while (blendOffsetIndex < MATRIX_PALETTE_ENTRIES && repArray[blendOffsetIndex]) {
			blendOffsetIndex++;
		}
		newRep->newBlendOffsetIndex = blendOffsetIndex;
		repArray[blendOffsetIndex++] = newRep;
	}
	[newIndexDic removeAllObjects];
	for (int i=0; i<MATRIX_PALETTE_ENTRIES; i++) {
		if (repArray[i]) {
			NSNumber *boneIndex = [part->blendIndexArray objectAtIndex:repArray[i]->blendIndex];
			[newIndexDic setObject:repArray[i] forKey:boneIndex];
		}
	}
}

-(id)loadFile:(NSString*)path {
	NSError *fileError = nil;
	NSData *gmoData = [NSData dataWithContentsOfFile:path options:0 error:&fileError];
	if (!fileError) {
		return [self loadGmo:[gmoData bytes]];
	} else {
		//file open error occurred
		return nil;
	}
}

-(NezBonedModel*)loadGmo:(const void *)gmoBuffer {
	if (!gmoBuffer) return nil;

	vertexOffset=0;
	textureOffset=0;
	hasBoundingBox = NO;
	
	GmoHeader *header = (GmoHeader*)gmoBuffer;
	GmoChunk *rootChunk = (GmoChunk*)(header + 1);
	GmoChunk *chunk = GetChildGmoChunk(rootChunk);
	
	if (!chunk || GetGmoChunkType(chunk) != GMO_MODEL) {
		return nil;
	}
	
	boneArray = [NSMutableArray arrayWithCapacity:128];
	materialArray = [NSMutableArray arrayWithCapacity:8];
	partArray = [NSMutableArray arrayWithCapacity:8];
	textureArray = [NSMutableArray arrayWithCapacity:8];
	motionArray = [NSMutableArray arrayWithCapacity:16];
	
	[self loadGmoChunksWithRootChild:chunk Type:GMO_PART];
	[self loadGmoChunksWithRootChild:chunk Type:GMO_BONE];
	[self loadGmoChunksWithRootChild:chunk Type:GMO_MATERIAL];
	[self loadGmoChunksWithRootChild:chunk Type:GMO_TEXTURE];
	[self loadGmoChunksWithRootChild:chunk Type:GMO_MOTION];
	[self loadGmoChunksWithRootChild:chunk Type:GMO_VERTEX_OFFSET];
	[self loadGmoChunksWithRootChild:chunk Type:GMO_BOUNDING_BOX];
	[self loadGmoChunksWithRootChild:chunk Type:GMO_BOUNDING_POINTS];
	
	[self initializeBoneMatrices];

	for (NezGmoPart *part in partArray) {
		for (int b=0; b < [part->blendOffsetArray count]; b++) {
			NSNumber *blendIndex = [part->blendIndexArray objectAtIndex:b];
			int idx = [blendIndex intValue];
			NezGmoBone *bone = [boneArray objectAtIndex:idx];
			float *world = (float*)bone->matrix;
			NezGmoMatrix *blendOffsetMatrix = [part->blendOffsetArray objectAtIndex:b];
			float *blendOffset = (float*)(&blendOffsetMatrix->matrix);
			float m[16];
			MatrixMultiply(world, blendOffset, m);
			if (vertexOffset) {
				MatrixMultiply(m, vertexOffsetMatrix, blendOffset);
			} else {
				MatrixCopy(m, blendOffset);
			}
		}
		
		NSMutableDictionary *vertexArrayDic = [NSMutableDictionary dictionaryWithCapacity:128];
		
		for (NezGmoMesh *mesh in part->meshArray) {
			for (NSNumber *vertexArrayIndex in mesh->vertexArrayIndexArray) {
				if ([vertexArrayDic objectForKey:vertexArrayIndex]) { // do not mutliply the blend offset more than once!!!
					continue;
				}
				NSMutableArray *vertexArray = [part->vertexArrayArray objectAtIndex:[vertexArrayIndex intValue]];
				[vertexArrayDic setObject:vertexArrayIndex forKey:vertexArrayIndex];
				
				for (NezGmoVertex *vertex in vertexArray) {
					if (textureOffset) {
						vertex->uv[0] = vertex->uv[0]*textureOffset[2]+textureOffset[0];
						vertex->uv[1] = vertex->uv[1]*textureOffset[3]+textureOffset[1];
					}
					if (!vertex->blendCount) {
						if (vertexOffsetMatrix) {
							float vIn[4] = {vertex->pos[0], vertex->pos[1], vertex->pos[2], 1};
							float vOut[4];
							MatrixMultVec4(vertexOffsetMatrix, vIn, vOut);
							vertex->pos[0] = vOut[0];
							vertex->pos[1] = vOut[1];
							vertex->pos[2] = vOut[2];
						}
						continue;
					}
					float vx = vertex->pos[0];
					float vy = vertex->pos[1];
					float vz = vertex->pos[2];
					
					float nx = vertex->normal[0];
					float ny = vertex->normal[1];
					float nz = vertex->normal[2];
					
					vertex->pos[0] = vertex->pos[1] = vertex->pos[2] = 0;
					vertex->normal[0] = vertex->normal[1] = vertex->normal[2] = 0;
					
					for (int n=0; n<vertex->blendCount; n++) {
						float weight = vertex->boneWeightList[n];
						if (weight == 0.0f) continue;
						
						int idx;
						int subIdx = vertex->blendOffsetIndexList[n];
						
						if ([mesh->blendOffsetIndexArray count] == 0) {
							idx = subIdx;
						} else {
							NSNumber *blendOffsetIndex = [mesh->blendOffsetIndexArray objectAtIndex:subIdx];
							idx = [blendOffsetIndex intValue];
						}
						NezGmoMatrix *blendMatrix = [part->blendOffsetArray objectAtIndex:idx];
						GmoMat4F *m = &blendMatrix->matrix;
						
						vertex->pos[0] += (m->x.x * vx + m->y.x * vy + m->z.x * vz + m->w.x) * weight;
						vertex->pos[1] += (m->x.y * vx + m->y.y * vy + m->z.y * vz + m->w.y) * weight;
						vertex->pos[2] += (m->x.z * vx + m->y.z * vy + m->z.z * vz + m->w.z) * weight;
						
						vertex->normal[0] += (m->x.x * nx + m->y.x * ny + m->z.x * nz) * weight;
						vertex->normal[1] += (m->x.y * nx + m->y.y * ny + m->z.y * nz) * weight;
						vertex->normal[2] += (m->x.z * nx + m->y.z * ny + m->z.z * nz) * weight;
					}
				}
			}
		}
	}
	for (NezGmoPart *part in partArray) {
		for (NezGmoMesh *mesh in part->meshArray) {
			for (int i=0; i<[mesh->indexArrayArray count]; i++) {
				NSArray *va = [part->vertexArrayArray objectAtIndex:[[mesh->vertexArrayIndexArray objectAtIndex:i] intValue]];
				NSArray *indexArray = [mesh->indexArrayArray objectAtIndex:i];
				for (int j=0; j<[indexArray count]; j+=3) { // loop per triangle
					float normal[3];
					NezGmoVertex *v[3];
					for (int k=0; k<3; k++) {
						v[k] = [va objectAtIndex:[[indexArray objectAtIndex:j+k] intValue]];
					}
					GetNormal(v[0]->pos, v[1]->pos, v[2]->pos, normal);
					for (int k=0; k<3; k++) {
						if (v[k]->normalAdds == 0) {
							v[k]->normal[0] += normal[0];
							v[k]->normal[1] += normal[1];
							v[k]->normal[2] += normal[2];
							v[k]->normalAdds++;
						}
					}
				}
			}
		}
	}
	for (NezGmoPart *part in partArray) {
		for (NSArray *va in part->vertexArrayArray) {
			for (NezGmoVertex *v1 in va) {
				for (NezGmoVertex *v2 in va) {
					if (fabs(v1->pos[0]-v2->pos[0]) < 0.00005 && fabs(v1->pos[1]-v2->pos[1]) < 0.00005 && fabs(v1->pos[2]-v2->pos[2]) < 0.00005) {
						v1->normalSumation[0] += v2->normal[0];
						v1->normalSumation[1] += v2->normal[1];
						v1->normalSumation[2] += v2->normal[2];
						v1->normalAdds++;
					}
				}
			}
		}
	}
	for (NezGmoPart *part in partArray) {
		for (NSArray *va in part->vertexArrayArray) {
			for (NezGmoVertex *v1 in va) {
				if (v1->normalAdds > 1) {
					v1->normal[0] = v1->normalSumation[0] / v1->normalAdds;
					v1->normal[1] = v1->normalSumation[1] / v1->normalAdds;
					v1->normal[2] = v1->normalSumation[2] / v1->normalAdds;
				}
			}
		}
	}
	
	NezBonedModel *model = [[[NezBonedModel alloc] init] autorelease];
	
	model->boundingBox[0].x = 1000000;
	model->boundingBox[0].y = 1000000;
	model->boundingBox[0].z = 1000000;
	model->boundingBox[1].x = -1000000;
	model->boundingBox[1].y = -1000000;
	model->boundingBox[1].z = -1000000;
//	if (hasBoundingBox) {
//		model->boundingBox[0].x = boundingBox[0][0];
//		model->boundingBox[0].y = boundingBox[0][1];
//		model->boundingBox[0].z = boundingBox[0][2];
//		model->boundingBox[1].x = boundingBox[1][0];
//		model->boundingBox[1].y = boundingBox[1][1];
//		model->boundingBox[1].z = boundingBox[1][2];
//	}
	
	model->materialArray = malloc(sizeof(Material)*[materialArray count]);
	model->materialCount = 0;
	for (NezGmoMaterial *material in materialArray) {
		Material *materialStruct = &model->materialArray[model->materialCount++];

		materialStruct->layerArray = malloc(sizeof(Layer)*[material->layerArray count]);
		materialStruct->layerCount = 0;
		
		materialStruct->enableMask = material->enableMask;
		materialStruct->enableBits = material->enableBits;
		
		for (NezGmoLayer *layer in material->layerArray) {
			Layer *layerStruct = &materialStruct->layerArray[materialStruct->layerCount++];
			layerStruct->textureIndex = layer->texture;
			switch (layer->blendFunc[0]) {
				case GMO_BLEND_ADD:
					layerStruct->blendFunc[0] = GL_FUNC_ADD;
					break;
				case GMO_BLEND_SUB:
					layerStruct->blendFunc[0] = GL_FUNC_SUBTRACT;
					break;
				case GMO_BLEND_REV:
					layerStruct->blendFunc[0] = GL_FUNC_REVERSE_SUBTRACT;
					break;
				case GMO_BLEND_MIN:
				case GMO_BLEND_MAX:
				case GMO_BLEND_DIFF:
				default:
					layerStruct->blendFunc[0] = GL_FUNC_ADD; // Not implemented
					break;
			}
			for (int i=1; i<=2; i++) {
				switch (layer->blendFunc[i]) {
					case GMO_BLEND_ZERO:
						layerStruct->blendFunc[i] = GL_ZERO;
						break;
					case GMO_BLEND_ONE:
						layerStruct->blendFunc[i] = GL_ONE;
						break;
					case GMO_BLEND_SRC_COLOR:
						layerStruct->blendFunc[i] = GL_SRC_COLOR;
						break;
					case GMO_BLEND_INV_SRC_COLOR:
						layerStruct->blendFunc[i] = GL_ONE_MINUS_SRC_COLOR;
						break;
					case GMO_BLEND_DST_COLOR:
						layerStruct->blendFunc[i] = GL_DST_COLOR;
						break;
					case GMO_BLEND_INV_DST_COLOR:
						layerStruct->blendFunc[i] = GL_ONE_MINUS_DST_COLOR;
						break;
					case GMO_BLEND_SRC_ALPHA:
						layerStruct->blendFunc[i] = GL_SRC_ALPHA;
						break;
					case GMO_BLEND_INV_SRC_ALPHA:
						layerStruct->blendFunc[i] = GL_ONE_MINUS_SRC_ALPHA;
						break;
					case GMO_BLEND_DST_ALPHA:
						layerStruct->blendFunc[i] = GL_DST_ALPHA;
						break;
					case GMO_BLEND_INV_DST_ALPHA:
						layerStruct->blendFunc[i] = GL_ONE_MINUS_DST_ALPHA;
						break;
					default:
						layerStruct->blendFunc[i] = GL_ONE;  //Error?
						break;
				}
			}
		}
	}
	
	model->textureArray = malloc(sizeof(TextureInfo)*[textureArray count]);
	model->textureCount = 0;
	TextureInfo *texArray = model->textureArray;
	for (NezGimPicture *pic in textureArray) {
		texArray[model->textureCount++] = [[TextureManager instance] loadTexture:pic->texturePixels Width:pic->width Height:pic->height Name:pic->filename PixelFormat:kTexture2DPixelFormat_RGBA8888];
	}

	model->motionArray = [motionArray retain];
	model->basePoseBoneArray = malloc(sizeof(Bone)*[boneArray count]);
	model->boneCount = 0;
	for (NezGmoBone *bone in boneArray) {
		Bone *boneStruct = &model->basePoseBoneArray[model->boneCount++];
		boneStruct->parent = bone->parent;
		memcpy(boneStruct->inverseMatrix, bone->inverseMatrix, sizeof(float)*16);
		memcpy(boneStruct->currentMatrix, bone->matrix, sizeof(float)*16);
		memcpy(boneStruct->rotate, bone->quaternion, sizeof(float)*4);
		memcpy(boneStruct->scale, bone->scale, sizeof(float)*3);
		memcpy(boneStruct->translate, bone->translate, sizeof(float)*3);
		boneStruct->updateFlags = 0;
		boneStruct->partIndex = bone->partIndex;
		if ([bone->name hasPrefix:@"head"]) {
			model->cameraLookAtBone = model->boneCount-1;
		}
	}
	model->partArray = malloc(sizeof(Part)*[partArray count]);
	model->partCount = 0;
	for (NezGmoPart *part in partArray) {
		[self reorganizePartData:part];

		Part *partStruct = &model->partArray[model->partCount++];

		partStruct->state = 0;
		partStruct->boneIndexArray = malloc(sizeof(unsigned short)*[part->blendIndexArray count]);
		partStruct->boneIndexCount = 0;
		for (NSNumber *blendIndex in part->blendIndexArray) {
			partStruct->boneIndexArray[partStruct->boneIndexCount++] = [blendIndex unsignedShortValue];
		}
		
		partStruct->vertexArrayArray = malloc(sizeof(VertexArray)*[part->vertexArrayArray count]);
		partStruct->vertexArrayCount = 0;
		for (NSMutableArray *vertexArray in part->vertexArrayArray) {
			VertexArray *vertexArrayStruct = &partStruct->vertexArrayArray[partStruct->vertexArrayCount++];
			
			vertexArrayStruct->maxBlendCount = 0;
			for (NezGmoVertex *vertex in vertexArray) {
				if (vertex->blendCount > vertexArrayStruct->maxBlendCount) {
					vertexArrayStruct->maxBlendCount = vertex->blendCount;
				}
			}
			
			vertexArrayStruct->vertexStride = sizeof(Vertex);
			Vertex *vertexArrayBuffer = malloc(vertexArrayStruct->vertexStride*[vertexArray count]);
			vertexArrayStruct->vertexCount = 0;
			
			for (NezGmoVertex *vertex in vertexArray) {
				Vertex *vertexStruct = &vertexArrayBuffer[vertexArrayStruct->vertexCount++];
				
				vertexStruct->pos[0] = vertex->pos[0];
				vertexStruct->pos[1] = vertex->pos[1];
				vertexStruct->pos[2] = vertex->pos[2];
				
				if (model->partCount == 1) {
					if(model->boundingBox[0].x > vertexStruct->pos[0]) model->boundingBox[0].x = vertexStruct->pos[0];
					if(model->boundingBox[0].y > vertexStruct->pos[1]) model->boundingBox[0].y = vertexStruct->pos[1];
					if(model->boundingBox[0].z > vertexStruct->pos[2]) model->boundingBox[0].z = vertexStruct->pos[2];
					if(model->boundingBox[1].x < vertexStruct->pos[0]) model->boundingBox[1].x = vertexStruct->pos[0];
					if(model->boundingBox[1].y < vertexStruct->pos[1]) model->boundingBox[1].y = vertexStruct->pos[1];
					if(model->boundingBox[1].z < vertexStruct->pos[2]) model->boundingBox[1].z = vertexStruct->pos[2];
				}
				
				vertexStruct->normal[0] = vertex->normal[0];
				vertexStruct->normal[1] = vertex->normal[1];
				vertexStruct->normal[2] = vertex->normal[2];
				
				vertexStruct->uv[0] = vertex->uv[0];
				vertexStruct->uv[1] = vertex->uv[1];
				
				vertexStruct->color[0] = vertex->color[3];
				vertexStruct->color[1] = vertex->color[2];
				vertexStruct->color[2] = vertex->color[1];
				vertexStruct->color[3] = vertex->color[0];
				
				int i=0;
				float totalWeight = 0.0;
				for (i=0; i<vertex->blendCount; i++) {
					vertexStruct->indexArray[i] = vertex->blendOffsetIndexList[i];
					vertexStruct->weightArray[i]= vertex->boneWeightList[i];
					totalWeight += vertex->boneWeightList[i];
				}
				for (; i<vertexArrayStruct->maxBlendCount; i++) {
					vertexStruct->indexArray[i] = 0;
					vertexStruct->weightArray[i]= 0;
				}
			}
			glGenBuffers(1, &vertexArrayStruct->vboPtr);
			glBindBuffer(GL_ARRAY_BUFFER, vertexArrayStruct->vboPtr);
			glBufferData(GL_ARRAY_BUFFER, vertexArrayStruct->vertexStride*vertexArrayStruct->vertexCount, vertexArrayBuffer, GL_STATIC_DRAW);
			
			free(vertexArrayBuffer);
		}
		partStruct->meshArray = malloc(sizeof(Mesh)*[part->meshArray count]);
		partStruct->meshCount = 0;
		for (NezGmoMesh *mesh in part->meshArray) {
			Mesh *meshStruct = &partStruct->meshArray[partStruct->meshCount++];

			meshStruct->indexArrayArray = malloc(sizeof(IndexArray)*[mesh->indexArrayArray count]);
			meshStruct->materialIndex = mesh->materialIndex;
			meshStruct->indexArrayCount = [mesh->indexArrayArray count];
			for (int i=0; i<[mesh->indexArrayArray count]; i++) {
				NSNumber *vertexArrayIndex = [mesh->vertexArrayIndexArray objectAtIndex:i];
				NSMutableArray *indexArray = [mesh->indexArrayArray objectAtIndex:i];
				
				unsigned short *indexArrayBuffer = malloc(sizeof(unsigned short)*[indexArray count]);
				meshStruct->indexArrayArray[i].vertexArrayIndex = [vertexArrayIndex intValue];
				meshStruct->indexArrayArray[i].indexCount = 0;
				
				IndexArray *indexArrayStruct = &meshStruct->indexArrayArray[i];
				for (NSNumber *vertexIndex in indexArray) {
					indexArrayBuffer[indexArrayStruct->indexCount++] = [vertexIndex intValue];
				}
				glGenBuffers(1, &indexArrayStruct->vboPtr);
				glBindBuffer(GL_ARRAY_BUFFER, indexArrayStruct->vboPtr);
				glBufferData(GL_ARRAY_BUFFER, sizeof(unsigned short)*indexArrayStruct->indexCount, indexArrayBuffer, GL_STATIC_DRAW);

				free(indexArrayBuffer);
			}
			if ([mesh->blendOffsetIndexArray count] > 0) {
				meshStruct->blendIndexArray = malloc(sizeof(unsigned short)*[mesh->blendOffsetIndexArray count]);
				meshStruct->blendIndexCount = 0;
				for (NSNumber *blendIndex in mesh->blendOffsetIndexArray) {
					meshStruct->blendIndexArray[meshStruct->blendIndexCount++] = [blendIndex unsignedShortValue];
				}
			} else {
				meshStruct->blendIndexArray = malloc(sizeof(unsigned short)*partStruct->boneIndexCount);
				meshStruct->blendIndexCount = 0;
				for (int i=0; i<partStruct->boneIndexCount; i++) {
					meshStruct->blendIndexArray[meshStruct->blendIndexCount++] = i;
				}
			}
		}
		glBindBuffer(GL_ARRAY_BUFFER, 0); // unbind the vertex array buffer
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); // unbind the index array buffer
	}
	return model;
}

-(void)loadGmoChunksWithRootChild:(const GmoChunk*)chunk Type:(int)type {
	GmoChunk *end = GetNextGmoChunk(chunk);
	
	switch (type) {
		case GMO_BONE : {
			for(chunk = GetChildGmoChunk(chunk);chunk<end;chunk=GetNextGmoChunk(chunk)) {
				if (GetGmoChunkType(chunk) == type) {
					[self loadGmoBone:chunk];
				}
			}
			break;
		}
		case GMO_PART : {
			for(chunk = GetChildGmoChunk(chunk);chunk<end;chunk=GetNextGmoChunk(chunk)) {
				if (GetGmoChunkType(chunk) == type) {
					[self loadGmoPart:chunk];
				}
			}
			break;
		}
		case GMO_MATERIAL : {
			for(chunk = GetChildGmoChunk(chunk);chunk<end;chunk=GetNextGmoChunk(chunk)) {
				if (GetGmoChunkType(chunk) == type) {
					[self loadGmoMaterial:chunk];
				}
			}
			break;
		}
		case GMO_TEXTURE : {
			for(chunk = GetChildGmoChunk(chunk);chunk<end;chunk=GetNextGmoChunk(chunk)) {
				if (GetGmoChunkType(chunk) == type) {
					[self loadGmoTexture:chunk];
				}
			}
			break;
		}
		case GMO_MOTION : {
			for(chunk = GetChildGmoChunk(chunk);chunk<end;chunk=GetNextGmoChunk(chunk)) {
				if (GetGmoChunkType(chunk) == type) {
					[self loadGmoMotion:chunk];
				}
			}
			break;
		}
		case GMO_BOUNDING_BOX : {
			GmoBoundingBox *cmd = (GmoBoundingBox*)GetGmoChunkArgs(chunk);
			boundingBox[0][0] = cmd->lower.x;
			boundingBox[0][1] = cmd->lower.y;
			boundingBox[0][2] = cmd->lower.z;
			boundingBox[1][0] = cmd->upper.x;
			boundingBox[1][1] = cmd->upper.y;
			boundingBox[1][2] = cmd->upper.z;
			hasBoundingBox = YES;
			break;
		}
		case GMO_VERTEX_OFFSET : {
			for(chunk = GetChildGmoChunk(chunk);chunk<end;chunk=GetNextGmoChunk(chunk)) {
				if (GetGmoChunkType(chunk) == type) {
					GmoVertexOffset *cmd = (GmoVertexOffset*)GetGmoChunkArgs(chunk);
					switch (cmd->format) {
						case CMD_VERTEX_FLOAT :
							MatrixSet(vertexOffsetMatrix,
									  cmd->offset[0], cmd->offset[1], cmd->offset[2],
									  cmd->offset[3], cmd->offset[4], cmd->offset[5]);
							vertexOffset = vertexOffsetMatrix;
							break;
						case CMD_TEXTURE_FLOAT :
							textureOffsetMatrix[0] = cmd->offset[0];
							textureOffsetMatrix[1] = cmd->offset[1];
							textureOffsetMatrix[2] = cmd->offset[2];
							textureOffsetMatrix[3] = cmd->offset[3];
							textureOffset = textureOffsetMatrix;
							break;
					}
				}
			}
			break;
		}
			/*		    case GMO_BOUNDING_POINTS : {
			 GMOBoundingPoints *cmd = (GMOBoundingPoints *)GMO_CHUNK_ARGS( chunk );
			 if ( cmd->n_points % 8 != 0 ) break;
			 int size = GMO_CHUNK_ARGSSIZE( chunk );
			 if ( !GMOModelCopyPtr( &( model->m_bounding_points ), cmd, size ) ) {
			 WARNING( "cannot alloc GMOModel ( convex closure )\n" );
			 return false;
			 }
			 break;
			 }
			 */		
	}
}

-(void)loadGmoPart:(GmoChunk*)chunk {
	NezGmoPart *part = [NezGmoPart makeNezGmoPart];
	[partArray addObject:part];
	
	GmoChunk *end = GetNextGmoChunk(chunk);
	for (chunk=GetChildGmoChunk(chunk); chunk<end; chunk=GetNextGmoChunk(chunk)) {
		switch (GetGmoChunkType(chunk)) {
		    case GMO_MESH : {
				[self loadGmoMesh:chunk Part:part];
				break;
		    }
		    case GMO_ARRAYS : {
				[self loadGmoVertexArray:chunk Part:part];
				break;
		    }
		}
	}
}

-(void)loadGmoMesh:(const GmoChunk*)chunk Part:(NezGmoPart*)part {
	NezGmoMesh *mesh = [NezGmoMesh makeNezGmoMesh];
	[part->meshArray addObject:mesh];
	
	[self loadGmoMeshDrawArrays:chunk Mesh:mesh];
	
	GmoChunk *end = GetNextGmoChunk(chunk);
	for (chunk=GetChildGmoChunk(chunk);chunk<end;chunk=GetNextGmoChunk(chunk)) {
		void *args = GetGmoChunkArgs(chunk);
		
		switch (GetGmoChunkType(chunk)) {
		    case GMO_SET_MATERIAL : {
				mesh->materialIndex = GMO_REF_INDEX(*((int*)args));
				break;
		    }
		    case GMO_BLEND_SUBSET : {
				GmoBlendSubset *cmd = (GmoBlendSubset*)args;
				for (int i=0; i<cmd->n_indices; i++) {
					[mesh->blendOffsetIndexArray addObject:[NSNumber numberWithUnsignedShort:cmd->indices[i]]];
				}
				break;
		    }
//		    case GMO_SUBDIVISION : {
//				SceGmoSubdivision *cmd = (SceGmoSubdivision *)args;
//				mesh->m_subdiv.x = cmd->div_u;
//				mesh->m_subdiv.y = cmd->div_v;
//				mesh->m_flags |= GMO_MESH_HAS_SUBDIV;
//				break;
//		    }
//		    case GMO_BOUNDING_POINTS : {
//				SceGmoBoundingPoints *cmd = (SceGmoBoundingPoints *)args;
//				if ( cmd->n_points % 8 != 0 ) break;
//				mesh->m_bounding_points = cmd;
//				break;
//		    }
		}
	}
}

-(void)loadGmoMeshDrawArrays:(const GmoChunk*)org Mesh:(NezGmoMesh*)mesh {
	GmoChunk *chunk;
	GmoChunk *end = GetNextGmoChunk(org);

	for (chunk = GetChildGmoChunk(org); chunk < end; chunk=GetNextGmoChunk(chunk)) {
		if (GetGmoChunkType(chunk) == GMO_DRAW_ARRAYS) {
			GmoDrawArrays *cmd = (GmoDrawArrays *)GetGmoChunkArgs(chunk);
			
			NSMutableArray *indexArray = [NSMutableArray arrayWithCapacity:32];
			[mesh->indexArrayArray addObject:indexArray];
			[mesh->vertexArrayIndexArray addObject:[NSNumber numberWithInt:GMO_REF_INDEX(cmd->arrays)]];
			 // It is possible for the vertex array index to be different for each draw arrays cmd so a list is necessary.
			 
			switch (GMO_PRIM_TYPE_MASK & cmd->mode) {
				case GMO_PRIM_TRIANGLES :
					for (int i=0; i<cmd->n_verts; i++) {
						[indexArray addObject:[NSNumber numberWithInt:cmd->indices[i]]];
					}
					break;
				case GMO_PRIM_TRIANGLE_STRIP : {
					unsigned short *src = cmd->indices;
					if (GMO_PRIM_SEQUENTIAL & cmd->mode) {
						int num = src[0];
						for (int i=0; i<cmd->n_prims; i++) {
							int flip = 0;
							for (int j=2; j<cmd->n_verts; j++) {
								[indexArray addObject:[NSNumber numberWithInt:num++]];
								[indexArray addObject:[NSNumber numberWithInt:num+flip]];
								flip = 1-flip;
								[indexArray addObject:[NSNumber numberWithInt:num+flip]];
							}
							num += 2;
						}
					} else {
						int num = 0;
						for (int i=0; i<cmd->n_prims; i++) {
							int flip = 0;
							for (int j=2; j<cmd->n_verts; j++) {
								[indexArray addObject:[NSNumber numberWithInt:src[num++]]];
								[indexArray addObject:[NSNumber numberWithInt:src[num+flip]]];
								flip = 1-flip;
								[indexArray addObject:[NSNumber numberWithInt:src[num+flip]]];
							}
							num += 2;
						}
					}
					break;
				}
				case GMO_PRIM_TRIANGLE_FAN :
					NSLog(@"      GMO_PRIM_TRIANGLE_FAN");
					break;
				default:
					continue;
			}
		}
	}
}

-(void)loadGmoVertexArray:(const GmoChunk*)chunk Part:(NezGmoPart*)part {
	GmoArraysHeader *arrays = (GmoArraysHeader *)GetGmoChunkArgs(chunk);
	int format = arrays->format;
	void *buffer = arrays + 1;
	int vertexCount = arrays->n_verts;
	int morph1Count = CMD_VF_MORPH_COUNT(format);
	int morph2Count = arrays->n_morphs;
	int morphCount = morph1Count*morph2Count;
	if (morphCount > 1) morphCount++;		// reserve morph buffer
	
	NSMutableArray *vertexArray = [NSMutableArray arrayWithCapacity:morphCount*vertexCount];
	[part->vertexArrayArray addObject:vertexArray];

	for (int i=0;i<morph2Count;i++) {
		for (int j=0;j<morph1Count;j++) {
			for (int k=0;k<vertexCount;k++) {
				buffer = [self loadGmoVertex:buffer Format:format Array:vertexArray];
			}
		}
	}
}

-(void*)loadGmoVertex:(void*)buffer Format:(int)format Array:(NSMutableArray*)array {
	NezGmoVertex *vertex = [NezGmoVertex makeNezGmoVertex];
	[array addObject:vertex];
	
	int type = CMD_VF_WEIGHT_TYPE(format);
	
	if (type != CMD_VF_NONE) {
		int weightCount = CMD_VF_WEIGHT_COUNT(format);
		switch (type) {
		    case CMD_VF_FLOAT : {
				float *fp = (float*)buffer;
				for (int i=0;i<weightCount;i++) {
					if (fp[i] > 0) {
						vertex->blendOffsetIndexList[vertex->blendCount] = i;
						vertex->boneWeightList[vertex->blendCount++] = *(fp);
					}
					fp++;
				}
				buffer = fp;
				break;
		    }
		    case CMD_VF_SHORT : {
				unsigned short *sp = (unsigned short*)buffer;
				for (int i=0;i<weightCount;i++) {
					float weight = USHORTX_TO_FLOAT(*(sp++));
					if (weight > 0) {
						vertex->blendOffsetIndexList[vertex->blendCount] = i;
						vertex->boneWeightList[vertex->blendCount++] = weight;
					}
				}
				buffer = sp;
				break;
		    }
		    case CMD_VF_BYTE : {
				unsigned char *cp = (unsigned char*)buffer;
				for (int i=0;i<weightCount;i++) {
					float weight = BYTEX_TO_FLOAT(*(cp++));
					if (weight > 0) {
						vertex->blendOffsetIndexList[vertex->blendCount] = i;
						vertex->boneWeightList[vertex->blendCount++] = weight;
					}
				}
				buffer = cp;
				break;
		    }
		}
	}
	type = CMD_VF_TEXTURE_TYPE(format);
	if (type != CMD_VF_NONE) {
		switch(type) {
		    case CMD_VF_FLOAT : {
				float *fp = (float*)(((int)buffer+3) & ~3);
				buffer = fp+2;
				vertex->uv[0] = fp[0];
				vertex->uv[1] = fp[1];
				break;
		    }
		    case CMD_VF_SHORT : {
				unsigned short *sp = (unsigned short*)(((int)buffer+1) & ~1);
				buffer = sp+2;
				vertex->uv[0] = USHORTX_TO_FLOAT(sp[0]);
				vertex->uv[1] = USHORTX_TO_FLOAT(sp[1]);
				break;
		    }
		    case CMD_VF_BYTE : {
				unsigned char *cp = (unsigned char*)buffer;
				buffer = cp+2;
				vertex->uv[0] = UBYTEX_TO_FLOAT(cp[0]);
				vertex->uv[1] = UBYTEX_TO_FLOAT(cp[1]);
				break;
		    }
		}
	}
	type = CMD_VF_COLOR_TYPE(format);
	if (type != CMD_VF_NONE) {
		switch(type) {
		    case CMD_VF_PF8888 : {
				unsigned int *ip = (unsigned int*)(((int)buffer+3) & ~3);
				buffer = ip+1;
				vertex->color[0] = ((ip[0] >> 24) & 0xFF);
				vertex->color[1] = ((ip[0] >> 16) & 0xFF);
				vertex->color[2] = ((ip[0] >>  8) & 0xFF);
				vertex->color[3] = ((ip[0] >>  0) & 0xFF);
				break;
		    }
		    case CMD_VF_PF4444 : {
				unsigned short *sp = (unsigned short*)(((int)buffer+1) & ~1);
				buffer = sp+1;
				vertex->color[0] = ((sp[0] >> 12) & 0xF) * 0x11;
				vertex->color[1] = ((sp[0] >>  8) & 0xF) * 0x11;
				vertex->color[2] = ((sp[0] >>  4) & 0xF) * 0x11;
				vertex->color[3] = ((sp[0] >>  0) & 0xF) * 0x11;
				break;
		    }
		    case CMD_VF_PF5551 : {
				unsigned short *sp = (unsigned short*)(((int)buffer+1) & ~1);
				buffer = sp+1;
				vertex->color[0] = ((sp[0] >> 11) * 0x08) * 0x21 / 4;
				vertex->color[1] = ((sp[0] >>  6) * 0x08) * 0x21 / 4;
				vertex->color[2] = ((sp[0] >>  1) * 0x08) * 0x21 / 4;
				vertex->color[3] = (sp[0] & 1)?0xFF:0;
				break;
		    }
		    case CMD_VF_PF5650 : {
				unsigned short *sp = (unsigned short*)(((int)buffer+1) & ~1);
				buffer = sp + 1;
				vertex->color[0] = ((sp[0] >> 11) & 0x1F) * 0x21 / 4;
				vertex->color[1] = ((sp[0] >>  5) & 0x3F) * 0x41 / 16;
				vertex->color[2] = ((sp[0] >>  0) & 0x1F) * 0x21 / 4;
				vertex->color[3] = 0xFF;
				break;
		    }
		}
	}
	type = CMD_VF_NORMAL_TYPE(format);
	if (type != CMD_VF_NONE) {
		switch(type) {
		    case CMD_VF_FLOAT : {
				float *fp = (float*)(((int)buffer+3) & ~3);
				buffer = fp+3;
				vertex->normal[0] = fp[0];
				vertex->normal[1] = fp[1];
				vertex->normal[2] = fp[2];
				break;
		    }
		    case CMD_VF_SHORT : {
				short *sp = (short*)(((int)buffer+1) & ~1);
				buffer = sp + 3;
				vertex->normal[0] = SHORTX_TO_FLOAT(sp[0]);
				vertex->normal[1] = SHORTX_TO_FLOAT(sp[1]);
				vertex->normal[2] = SHORTX_TO_FLOAT(sp[2]);
				break;
		    }
		    case CMD_VF_BYTE : {
				char *cp = (char*)buffer;
				buffer = cp + 3;
				vertex->normal[0] = BYTEX_TO_FLOAT(cp[0]);
				vertex->normal[1] = BYTEX_TO_FLOAT(cp[1]);
				vertex->normal[2] = BYTEX_TO_FLOAT(cp[2]);
				break;
		    }
		}
		vertex->normalAdds++;
	}
	type = CMD_VF_VERTEX_TYPE(format);
	if (type != CMD_VF_NONE) {
		switch ( type ) {
		    case CMD_VF_FLOAT : {
				float *fp = (float*)(((int)buffer+3) & ~3);
				buffer = fp + 3;
				vertex->pos[0] = fp[0];
				vertex->pos[1] = fp[1];
				vertex->pos[2] = fp[2];
				break;
		    }
		    case CMD_VF_SHORT : {
				short *sp = (short*)(((int)buffer+1) & ~1);
				buffer = sp + 3;
				vertex->pos[0] = SHORTX_TO_FLOAT(sp[0]);
				vertex->pos[1] = SHORTX_TO_FLOAT(sp[1]);
				vertex->pos[2] = SHORTX_TO_FLOAT(sp[2]);
				break;
		    }
		    case CMD_VF_BYTE : {
				char *cp = (char*)buffer;
				buffer = cp + 3;
				vertex->pos[0] = BYTEX_TO_FLOAT(cp[0]);
				vertex->pos[1] = BYTEX_TO_FLOAT(cp[1]);
				vertex->pos[2] = BYTEX_TO_FLOAT(cp[2]);
				break;
		    }
		}
	}
	return buffer;
}

-(void)loadGmoBone:(const GmoChunk*)chunk {
	NezGmoBone *bone = [NezGmoBone makeNezGmoBone];
	[boneArray addObject:bone];
	
	GmoChunk *end = GetNextGmoChunk(chunk);
	bone->name = [[NSString stringWithFormat:@"%s", ((char*)chunk+16)] retain];
	NSLog(@"bone->name:%@", bone->name);
	
	GmoBlendOffsets *blend_offsets = 0;
	GmoBlendBones *blendBones = 0;
	
	for (chunk = GetChildGmoChunk(chunk);chunk < end;chunk = GetNextGmoChunk(chunk)) {
		void *args = GetGmoChunkArgs(chunk);
		
		switch (GetGmoChunkType(chunk)) {
		    case GMO_PARENT_BONE : {
				int p = ((GmoParentBone*)args)->bone;
				if (p != -1) {
					bone->parent = GMO_REF_INDEX(p);
				}
				break;
		    }
		    case GMO_VISIBILITY : {
				NSLog(@"   GMO_VISIBILITY");
				bone->visibility = *((int*)args);
				bone->flags |= GMO_BONE_HAS_VISIBILITY;
				break;
		    }
		    case GMO_MORPH_WEIGHTS : {
				NSLog(@"   GMO_MORPH_WEIGHTS");
				break;
		    }
		    case GMO_MORPH_INDEX : {
				NSLog(@"   GMO_MORPH_INDEX");
				break;
		    }
			case GMO_BLEND_BONES : {
				blendBones = (GmoBlendBones *)args;
				break;
		    }
		    case GMO_BLEND_OFFSETS : {
				blend_offsets = (GmoBlendOffsets *)args;
				break;
		    }
		    case GMO_PIVOT : {
				memcpy(bone->pivot, args, sizeof(float)*3);
				bone->flags |= GMO_BONE_HAS_PIVOT;
				break;
		    }
		    case GMO_MULT_MATRIX : {
				MatrixCopy(args, bone->matrix);
				bone->flags |= GMO_BONE_HAS_MULT_MATRIX;
				break;
		    }
		    case GMO_TRANSLATE : {
				memcpy(bone->translate, args, sizeof(float)*3);
				bone->flags |= GMO_BONE_HAS_TRANSLATE;
				break;
		    }
		    case GMO_ROTATE_ZYX : {
				float *angle = (float*)args;
				QuaternionFromEulerAngles(angle[2], angle[1], angle[0], bone->inverseQuaternion);
				QuaternionGetInverse(bone->inverseQuaternion, bone->quaternion);
				bone->flags |= GMO_BONE_HAS_ROTATE;
				break;
		    }
		    case GMO_ROTATE_YXZ : {
				float *angle = (float*)args;
				QuaternionFromEulerAngles(angle[1], angle[0], angle[2], bone->inverseQuaternion);
				QuaternionGetInverse(bone->inverseQuaternion, bone->quaternion);
				bone->flags |= GMO_BONE_HAS_ROTATE;
				break;
		    }
		    case GMO_ROTATE_Q : {
				QuaternionCopy(args, bone->inverseQuaternion);
				QuaternionGetInverse(bone->inverseQuaternion, bone->quaternion);
				bone->flags |= GMO_BONE_HAS_ROTATE;
				break;
		    }
		    case GMO_SCALE : {
				memcpy(bone->scale, args, sizeof(float)*3);
				bone->flags &= ~GMO_BONE_HAS_SCALE;
				bone->flags |= GMO_BONE_HAS_SCALE_1;
				break;
		    }
		    case GMO_SCALE_2 : {
				memcpy(bone->scale, args, sizeof(float)*3);
				bone->flags &= ~GMO_BONE_HAS_SCALE;
				bone->flags |= GMO_BONE_HAS_SCALE_2;
				break;
		    }
		    case GMO_SCALE_3 : {
				memcpy(bone->scale, args, sizeof(float)*3);
				bone->flags &= ~GMO_BONE_HAS_SCALE;
				bone->flags |= GMO_BONE_HAS_SCALE_3;
				break;
		    }
		    case GMO_DRAW_PART : {
				bone->partIndex = GMO_REF_INDEX(*((int*)args));
				break;
		    }
		    case GMO_BONE_STATE : {
				NSLog(@"   GMO_BONE_STATE");
				break;
		    }
			default: {
//				NSLog(@"   bone chunk: %x", GetGmoChunkType(chunk));
			}
		}
	}
	if (bone->partIndex > -1 && bone->partIndex < [partArray count]) {
		NezGmoPart *part = (NezGmoPart*)[partArray objectAtIndex:bone->partIndex];
		part->boneIndex = [boneArray count]-1;
		if (blend_offsets) {
			for (int i=0; i<blend_offsets->n_offsets; i++) {
				[part->blendOffsetArray addObject:[NezGmoMatrix makeNezGmoMatrixWithGmoMat4F:&blend_offsets->offsets[i]]];
			}
		}
		if (blendBones) {
			for (int i=0; i<blendBones->n_bones; i++) {
				[part->blendIndexArray addObject:[NSNumber numberWithInt:GMO_REF_INDEX(blendBones->bones[i])]];
			}
		}
	}
}

-(void)loadGmoMaterial:(const GmoChunk*)chunk {
	NezGmoMaterial *material = [NezGmoMaterial makeNezGmoMaterial];
	[materialArray addObject:material];
	
	GmoChunk *end = GetNextGmoChunk(chunk);
	for ( chunk = GetChildGmoChunk(chunk); chunk < end ; chunk = GetNextGmoChunk(chunk)) {
		void *args = GetGmoChunkArgs(chunk);
		
		switch (GetGmoChunkType(chunk)) {
		    case GMO_LAYER : {
				NezGmoLayer *layer = [self loadGmoLayer:chunk];
				
				int flag = 0;
				switch (layer->mapType) {
					case GMO_DIFFUSE : flag = GMO_MATERIAL_HAS_DIFFUSE ; break ;
					case GMO_SPECULAR : flag = GMO_MATERIAL_HAS_SPECULAR ; break ;
					case GMO_EMISSION : flag = GMO_MATERIAL_HAS_EMISSION ; break ;
					case GMO_AMBIENT : flag = GMO_MATERIAL_HAS_AMBIENT ; break ;
					case GMO_REFLECTION : flag = GMO_MATERIAL_HAS_REFLECTION ; break ;
					case GMO_REFRACTION :
					case GMO_BUMP : {	// not supported
						NSLog(@"Not Supported");
						layer = nil;
						break ;
					}
				}
				material->flags |= flag ;
				if (layer) {
					[material->layerArray addObject:layer];
				}
				break;
		    }
		    case GMO_RENDER_STATE : {
				NSLog(@"   GMO_RENDER_STATE");
				GmoRenderState *cmd = (GmoRenderState *)args ;
				int flag = 0 ;
				switch ( cmd->state ) {
					case GMO_STATE_LIGHTING :
						NSLog(@"      GMO_STATE_LIGHTING");
						flag = GMO_ENABLE_LIGHTING ;
						break ;
					case GMO_STATE_FOG :
						NSLog(@"      GMO_STATE_FOG");
						flag = GMO_ENABLE_FOG ;
						break ;
					case GMO_STATE_CULL_FACE :
						NSLog(@"      GMO_STATE_CULL_FACE");
						flag = GMO_ENABLE_CULL_FACE ;
						break ;
					case GMO_STATE_DEPTH_TEST :
						NSLog(@"      GMO_STATE_DEPTH_TEST");
						flag = GMO_ENABLE_DEPTH_TEST ;
						break ;
					case GMO_STATE_DEPTH_MASK :
						flag = GMO_ENABLE_DEPTH_MASK ;
						break ;
					case GMO_STATE_ALPHA_TEST :
						NSLog(@"      GMO_STATE_ALPHA_TEST");
						flag = GMO_ENABLE_ALPHA_TEST ;
						break ;
					case GMO_STATE_ALPHA_MASK :
						NSLog(@"      GMO_STATE_ALPHA_MASK");
						flag = GMO_ENABLE_ALPHA_MASK ;
						break ;
				}
				material->enableMask |= flag ;
				material->enableBits |= !(cmd->value) ? 0 : flag;
				break ;
		    }
		    case GMO_DIFFUSE : {
				NSLog(@"   GMO_DIFFUSE");
				GmoDiffuse *cmd = (GmoDiffuse *)args ;
				GmoCol4FToGmoCol4B(material->colors + GMO_MATERIAL_COLOR_DIFFUSE, &(cmd->color));
				break ;
		    }
		    case GMO_SPECULAR : {
				NSLog(@"   GMO_SPECULAR");
				GmoSpecular *cmd = (GmoSpecular *)args ;
				GmoCol4FToGmoCol4B(material->colors + GMO_MATERIAL_COLOR_SPECULAR, &(cmd->color));
				material->shininess = cmd->shininess ;
				break ;
		    }
		    case GMO_EMISSION : {
				NSLog(@"   GMO_EMISSION");
				GmoEmission *cmd = (GmoEmission *)args ;
				GmoCol4FToGmoCol4B(material->colors + GMO_MATERIAL_COLOR_EMISSION, &(cmd->color));
				break ;
		    }
		    case GMO_AMBIENT : {
				NSLog(@"   GMO_AMBIENT");
				GmoAmbient *cmd = (GmoAmbient *)args ;
				GmoCol4FToGmoCol4B(material->colors + GMO_MATERIAL_COLOR_AMBIENT, &(cmd->color));
				material->flags |= GMO_MATERIAL_HAS_EXPLICIT_AMBIENT ;
				break ;
		    }
		    case GMO_REFLECTION : {
				NSLog(@"   GMO_REFLECTION");
				GmoReflection *cmd = (GmoReflection *)args ;
				GmoCol4BSet(material->colors + GMO_MATERIAL_COLOR_REFLECTION, 255, 255, 255, (byte)(cmd->reflection*255));
				break ;
		    }
		    case GMO_REFRACTION : {
				NSLog(@"   GMO_REFRACTION");
				GmoRefraction *cmd = (GmoRefraction *)args ;
				material->refraction = cmd->refraction ;
				break ;
		    }
		    case GMO_BUMP : {
				NSLog(@"   GMO_BUMP");
				GmoBump *cmd = (GmoBump *)args ;
				material->bump = cmd->bump ;
				break ;
		    }
		}
	}
	
//	if ( !( material->m_flags & HAS_EXPLICIT_AMBIENT ) ) {
//		material->m_colors[ COLOR_AMBIENT ] = material->m_colors[ COLOR_DIFFUSE ] ;
//	}
//	reconfigure_material( material ) ;
}

-(NezGmoLayer*)loadGmoLayer:(const GmoChunk*)chunk {
	NezGmoLayer *layer = [NezGmoLayer makeNezGmoLayer];
	
	GmoChunk *end = GetNextGmoChunk(chunk);
	for (chunk = GetChildGmoChunk(chunk); chunk < end; chunk = GetNextGmoChunk(chunk)) {
		void *args = GetGmoChunkArgs(chunk);
		
		switch (GetGmoChunkType(chunk)) {
		    case GMO_SET_TEXTURE : {
				GmoSetTexture *cmd = (GmoSetTexture*)args;
				layer->texture = GMO_REF_INDEX(cmd->texture);
				break ;
		    }
		    case GMO_MAP_TYPE : {
				GmoMapType *cmd = (GmoMapType *)args;
				layer->mapType = cmd->type;
				NSLog(@"      GMO_MAP_TYPE %d", layer->mapType);
				break ;
		    }
		    case GMO_BLEND_FUNC : {
				GmoBlendFunc *cmd = (GmoBlendFunc*)args;
				layer->blendFunc[0] = cmd->mode;
				layer->blendFunc[1] = cmd->src;
				layer->blendFunc[2] = cmd->dst;
				break;
		    }
		    case GMO_TEX_CROP : {
				NSLog(@"      GMO_TEX_CROP");
				GmoTexCrop *cmd = (GmoTexCrop*)args;
				GmoRectCopy(&(layer->texCrop), &(cmd->crop));
				layer->flags |= GMO_LAYER_HAS_TEX_CROP;
				break ;
		    }
		}
	}
	return layer;
}

-(void)loadGmoTexture:(const GmoChunk*)chunk {
	char *filename = 0;
	void *fileimage = 0;
	int filesize = 0;
	
	GmoChunk *end = GetNextGmoChunk(chunk);
	for (chunk = GetChildGmoChunk(chunk); chunk<end; chunk=GetNextGmoChunk(chunk)) {
		void *args = GetGmoChunkArgs(chunk);
		switch (GetGmoChunkType(chunk)) {
		    case GMO_FILE_NAME : {
				GmoFileName *cmd = (GmoFileName*)args;
				filename = cmd->name;
				break;
		    }
		    case GMO_FILE_IMAGE : {
				GmoFileImage *cmd = (GmoFileImage*)args;
				fileimage = cmd->data;
				filesize = cmd->size;
				break;
		    }
		}
	}
	if (fileimage != 0) {
		int signature = *(int*)fileimage;
		if (signature == GIM_FORMAT_SIGNATURE) {
			if (!CheckGimPictureHeader(fileimage, filesize)) return;
			GimChunk *chunk = GetGimPictureChunk(fileimage, filesize, 0);
			if (chunk == 0) {
				return;
			}
			[self loadGim:chunk Filename:filename];
		} else if (signature == TM2_FORMAT_SIGNATURE) {
			NSLog(@"   TM2_FORMAT_SIGNATURE");
			//			return sceGimPictureLoadTm2( picture, buf, size, idx );
		} else if ((0xffff & signature) == BMP_FORMAT_SIGNATURE) {
			NSLog(@"   BMP_FORMAT_SIGNATURE");
			//			return sceGimPictureLoadBmp( picture, buf, size );
		} else {
			NSLog(@"   TGA?");
			//			return sceGimPictureLoadTga( picture, buf, size );
		}
	}
}

-(void)loadGim:(const GimChunk*)chunk Filename:(char*)filename {
	GimImageHeader *img=0;
	GimPaletteHeader *pal=0;
	
	GimChunk *end = GetNextGimChunk(chunk);
	for (chunk=GetChildGimChunk(chunk); chunk<end; chunk=GetNextGimChunk(chunk)) {
		void *data = GetGimChunkData(chunk);
		int size = GetGimChunkDataSize(chunk);
		switch (GetGimChunkType(chunk)) {
		    case GIM_IMAGE : {
				img = (GimImageHeader*)malloc(size);
				memcpy(img, data, size);
				int *offsets = (int *)((char*)img+img->offsets);
				for (int i=img->levelCount*img->frameCount; i>0; --i) {
					*(offsets++) += (int)img;
				}
				break;
		    }
		    case GIM_PALETTE : {
				pal = (GimPaletteHeader*)malloc(size);
				memcpy(pal, data, size);
				pal->reference = 1;
				int *offsets = (int*)((char *)pal+pal->offsets);
				for (int i = pal->levelCount*pal->frameCount; i>0; --i) {
					*(offsets++) += (int)pal;
				}
				break;
		    }
		}
	}
	[self loadTextureDataWithPalette:pal Image:img Filename:filename];
	
	if(img) free(img);
	if(pal) free(pal);
}

-(void)loadTextureDataWithPalette:(GimPaletteHeader*)pal Image:(GimImageHeader*)img Filename:(char*)filename {
	// palette
	unsigned int palettes[256];
	if (pal != 0) {
		void *pixels = GetGimImagePixels(pal, 0, 0);
		int width = pal->width;
		if (width > 256) width = 256;
		switch (pal->format) {
		    case GIM_FORMAT_RGBA5650 :
				Copy5650(palettes, (unsigned short *)pixels, width);
				break;
		    case GIM_FORMAT_RGBA5551 :
				Copy5551(palettes, (unsigned short *)pixels, width);
				break;
		    case GIM_FORMAT_RGBA4444 :
				Copy4444(palettes, (unsigned short *)pixels, width);
				break;
		    case GIM_FORMAT_RGBA8888 :
				Copy8888(palettes, (unsigned int *)pixels, width);
				break;
		}
	}
	
	// image
	unsigned int shift = 0;//picture->m_palette_offset[ 0 ];
	unsigned int mask = 255;//picture->m_palette_offset[ 1 ] & 255;
	unsigned int offs = 0;//picture->m_palette_offset[ 2 ] & 255;
	
	if (img == 0) return;
	void *imagePixels = GetGimImagePixels(img, 0, 0);
	int imageWidth = GetGimImageWidth(img, 0);
	int imageHeight = GetGimImageHeight(img, 0);
	int imagePitch = GetGimImagePitch(img, imageWidth);
	
	int texturePitch = imageWidth*4;
	unsigned char *texturePixels = malloc(texturePitch*imageHeight);

	switch (255 & img->format) {
		case GIM_FORMAT_INDEX4 : {
			unsigned int *dst = (unsigned int *)texturePixels;
			for (int block=0; block<16; block++) { // 16 blocks high
				for (int line=0; line<8; line++) { // 8 lines (interlaced) per block
					unsigned char *src = (unsigned char *)imagePixels+(imagePitch*8*block)+(line*16);
					for (int i=0; i<4; i++) { // go through 4 lines of src to make a full line of dst
						for (int j = 0; j < 16; j ++) { // 16 bytes (32 pixels) per src line
							unsigned int idx = src[j];
							*(dst++) = palettes[ (( idx & 15 ) >> shift & mask) | offs ];
							*(dst++) = palettes[ (( idx >> 4 ) >> shift & mask) | offs ];
						}
						src = (unsigned char *)((int)src + imagePitch*2); // it is interlaced so move 2 lines down
					}
				}
			}
			break;
		}
	    case GIM_FORMAT_INDEX8 : {
			unsigned int *dst = (unsigned int *)texturePixels;
			unsigned char *src = (unsigned char *)imagePixels;
			for ( int i = 0; i < imageHeight; i ++ ) {
				for ( int j = 0; j < imageWidth; j ++ ) {
					dst[ j ] = palettes[ (src[ j ] >> shift & mask) | offs ];
				}
				dst = (unsigned int *)( (int)dst + texturePitch );
				src = (unsigned char *)( (int)src + imagePitch );
			}
			break;
	    }
	    case GIM_FORMAT_INDEX16 : {
			unsigned int *dst = (unsigned int *)texturePixels;
			unsigned short *src = (unsigned short *)imagePixels;
			for ( int i = 0; i < imageHeight; i ++ ) {
				for ( int j = 0; j < imageWidth; j ++ ) {
					dst[ j ] = palettes[ (src[ j ] >> shift & mask) | offs ];
				}
				dst = (unsigned int *)( (int)dst + texturePitch );
				src = (unsigned short *)( (int)src + imagePitch );
			}
			break;
	    }
	    case GIM_FORMAT_INDEX32 : {
			unsigned int *dst = (unsigned int *)texturePixels;
			unsigned int *src = (unsigned int *)imagePixels;
			for (int i = 0; i < imageHeight; i++) {
				for (int j = 0; j < imageWidth; j++) {
					dst[j] = palettes[(src[j] >> shift & mask) | offs];
				}
				dst = (unsigned int*)((int)dst + texturePitch);
				src = (unsigned int*)((int)src + imagePitch);
			}
			break;
	    }
	}
	NezGimPicture *picture = [NezGimPicture makeNezGimPicture];
	
	picture->width = imageWidth;
	picture->height = imageHeight;
	picture->texturePixels = texturePixels;
	strncpy(picture->filename, filename, MAX_FILENAME_LENGTH);

	[textureArray addObject:picture];
}

-(void)loadGmoMotion:(const GmoChunk*)chunk {
	NezGmoMotion *motion = [NezGmoMotion makeNezGmoMotion];
	[motionArray addObject:motion];
	
	GmoChunk *end = GetNextGmoChunk(chunk);
	for (chunk = GetChildGmoChunk(chunk); chunk < end; chunk = GetNextGmoChunk(chunk)) {
		void *args = GetGmoChunkArgs(chunk);
		
		switch (GetGmoChunkType(chunk)) {
		    case GMO_FRAME_RATE : {
				motion->frameRate = ((GmoFrameRate*)args)->fps;
				break ;
		    }
		    case GMO_FRAME_LOOP : {
				motion->frameLoop[0] = ((GmoFrameLoop*)args)->start;
				motion->frameLoop[1] = ((GmoFrameLoop*)args)->end;
				break ;
		    }
		    case GMO_FRAME_REPEAT : {
				motion->frameRepeat = ((GmoFrameRepeat*)args )->mode;
				break ;
		    }
		    case GMO_ANIMATE : {
				GmoAnimate *anim = ((GmoAnimate*)args);
				NezGmoAnimate *animate = [NezGmoAnimate makeNezGmoAnimate];
				animate->type = GMO_REF_TYPE(anim->block);
				animate->index = GMO_REF_INDEX(anim->block);
				animate->cmd = anim->cmd;
				animate->dataIndex = anim->index;
				animate->fCurve = GMO_REF_INDEX(anim->fcurve);
				[motion->animationArray addObject:animate];
				break ;
		    }
		    case GMO_FCURVE : {
				GmoFCurveHeader *fcuv = ((GmoFCurveHeader*)args);
				NezGmoFCurve *fCurve = [NezGmoFCurve makeNezGmoFCurve];
				fCurve->format = fcuv->format;
				fCurve->dims = fcuv->n_dims;
				fCurve->keys = fcuv->n_keys;
				int dataLength = (int)GetNextGmoChunk(chunk)-(int)(fcuv+1);
				fCurve->data = malloc(dataLength);
				memcpy(fCurve->data, fcuv+1, dataLength);
				[motion->fCurveArray addObject:fCurve];
				break ;
		    }
		}
	}
}

-(void)initializeBoneMatrices {
	float m1[16];
	float m2[16];
	for (NezGmoBone *bone in boneArray) {
		if(bone->parent == -1) {
			MatrixGetIdentity(m1);
		} else {
			NezGmoBone *parentBone = [boneArray objectAtIndex:bone->parent];
			MatrixCopy(parentBone->matrix, m1);
		}
		QuaternionToMatrix(bone->quaternion, m2);
		MatrixMultiplyScale(m2, bone->scale, m2);
		m2[12] = bone->translate[0];
		m2[13] = bone->translate[1];
		m2[14] = bone->translate[2];
		
		MatrixMultiply(m1, m2, bone->matrix);
		MatrixInverse(bone->matrix, bone->inverseMatrix);
	}
}

-(void)updateBoneMatrices {
	float m1[16];
	float m2[16];
	for (NezGmoBone *bone in boneArray) {
		if(bone->parent == -1) {
			MatrixGetIdentity(m1);
		} else {
			NezGmoBone *parentBone = [boneArray objectAtIndex:bone->parent];
			MatrixCopy(parentBone->matrix, m1);
		}
		QuaternionToMatrix(bone->quaternion, m2);
		MatrixMultiplyScale(m2, bone->scale, m2);
		m2[12] = bone->translate[0];
		m2[13] = bone->translate[1];
		m2[14] = bone->translate[2];
		
		MatrixMultiply(m1, m2, bone->matrix);
	}
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

- (void)dealloc {
	[super dealloc];
}

@end
