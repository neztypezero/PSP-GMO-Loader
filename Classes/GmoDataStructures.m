//
//  GmoDataStructures.m
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "GmoDataStructures.h"
#import "Math.h"

@implementation NezGmoPart

+(NezGmoPart*) makeNezGmoPart {
	return [[[NezGmoPart alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		meshArray = [[NSMutableArray arrayWithCapacity:64] retain];
		vertexArrayArray = [[NSMutableArray arrayWithCapacity:64] retain];
		blendOffsetArray = [[NSMutableArray arrayWithCapacity:64] retain];
		blendIndexArray = [[NSMutableArray arrayWithCapacity:64] retain];
		boneIndex = -1;
    }
    return self;
}

- (void)dealloc {
	[meshArray release];
	[vertexArrayArray release];
	[blendOffsetArray release];
	[blendIndexArray release];
	[super dealloc];
}

@end

@implementation NezGmoMesh

+(NezGmoMesh*) makeNezGmoMesh {
	return [[[NezGmoMesh alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		blendOffsetIndexArray = [[NSMutableArray arrayWithCapacity:8] retain];
		indexArrayArray = [[NSMutableArray arrayWithCapacity:4] retain];
		vertexArrayIndexArray = [[NSMutableArray arrayWithCapacity:4] retain];
		materialIndex = -1;
    }
    return self;
}

- (void)dealloc {
	[blendOffsetIndexArray release];
	[indexArrayArray release];
	[vertexArrayIndexArray release];
	[super dealloc];
}

@end

@implementation NezGmoBone

+(NezGmoBone*) makeNezGmoBone {
	return [[[NezGmoBone alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		name = nil;
		parent = -1;
		QuaternionGetIdentity(quaternion);
		QuaternionGetIdentity(inverseQuaternion);
		flags = 0;
		visibility = 0;
		partIndex = -1;
		translate[0] = translate[1] = translate[2] = 0.0f;
		pivot[0] = pivot[1] = pivot[2] = 0.0f;
		scale[0] = scale[1] = scale[2] = 1.0f;
    }
	
    return self;
}

- (void)dealloc {
	if (name) {
		[name release];
	}
	[super dealloc];
}

@end

@implementation NezGmoVertex

+(NezGmoVertex*) makeNezGmoVertex {
	return [[[NezGmoVertex alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		pos[0] = pos[1] = pos[2] = 0;
		normal[0] = normal[1] = normal[2] = 0;
		normalSumation[0] = normalSumation[1] = normalSumation[2] = 0;
		uv[0] = uv[1] = 0;
		color[0] = color[1] = color[2] = color[3] = 0;
		blendCount = 0;
		for (int i=0; i<MAX_BLEND_COUNT; i++) {
			blendOffsetIndexList[i] = 0;
			boneWeightList[i] = 0;
		}
		materialIndex = 0;
		normalAdds = 0;
    }
	
    return self;
}

@end

@implementation NezGmoMatrix

+(NezGmoMatrix*) makeNezGmoMatrixWithGmoMat4F:(GmoMat4F*)mat4F {
	NezGmoMatrix *matrixObject = [NezGmoMatrix alloc];
	return [[matrixObject initWithGmoMat4F:mat4F] autorelease];
}

- (id)initWithGmoMat4F:(GmoMat4F*)mat4F {
    if ((self = [super init])) {
		memcpy(&matrix, mat4F, sizeof(GmoMat4F));
    }
	
    return self;
}

@end

@implementation NezGmoMaterial

+(NezGmoMaterial*) makeNezGmoMaterial {
	return [[[NezGmoMaterial alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		flags = 0 ;
		
		layerArray = [[NSMutableArray arrayWithCapacity:GMO_MATERIAL_MAX_LAYERS] retain];
		
		enableMask = 0 ;
		enableBits = 0 ;
		
		GmoCol4BSet(colors + GMO_MATERIAL_COLOR_BLACK, 0, 0, 0, 255);
		GmoCol4BSet(colors + GMO_MATERIAL_COLOR_SPECULAR, 0, 0, 0, 255);
		GmoCol4BSet(colors + GMO_MATERIAL_COLOR_EMISSION, 0, 0, 0, 255);
		GmoCol4BSet(colors + GMO_MATERIAL_COLOR_DIFFUSE, 255, 255, 255, 255);
		GmoCol4BSet(colors + GMO_MATERIAL_COLOR_AMBIENT, 255, 255, 255, 255);
		GmoCol4BSet(colors + GMO_MATERIAL_COLOR_REFLECTION, 255, 255, 255, 0);
		shininess = 0.0f ;
		refraction = 1.0f ;
		bump = 0.0f ;
		
		animFlags = 0 ;
		memset(animWeights, 0, sizeof(animWeights));
    }
	
    return self;
}

- (void)dealloc {
	[layerArray release];
	[super dealloc];
}

@end

@implementation NezGmoLayer

+(NezGmoLayer*) makeNezGmoLayer {
	return [[[NezGmoLayer alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		flags = 0;
		
		mapType = GMO_DIFFUSE;
		mapFactor = 1.0f;
		blendFunc[0] = GMO_BLEND_ADD; 
		blendFunc[1] = GMO_BLEND_SRC_ALPHA;
		blendFunc[2] = GMO_BLEND_INV_SRC_ALPHA;
		texture = -1;
		
		enableMask = 0;
		enableBits = 0;
		diffuse = GMO_MATERIAL_COLOR_DIFFUSE;
		specular = GMO_MATERIAL_COLOR_BLACK;
		ambient = GMO_MATERIAL_COLOR_BLACK;
		
		GmoRectSet(&texCrop, 0, 0, 1, 1);
    }
	
    return self;
}

@end

@implementation NezGmoMotion

+(NezGmoMotion*) makeNezGmoMotion {
	return [[[NezGmoMotion alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		flags = 0;
		
		animationArray = [[NSMutableArray arrayWithCapacity:16] retain];
		fCurveArray = [[NSMutableArray arrayWithCapacity:16] retain];
		
		frameLoop[0] = -1000000.0f;
		frameLoop[1] = 1000000.0f;
		frameRate = 60.0f;
		frameRepeat = GMO_REPEAT_CYCLE;
		frame = 0.0f;
		weight = 0.0f;
    }
	
    return self;
}

- (void)dealloc {
	[animationArray release];
	[fCurveArray release];
	[super dealloc];
}

@end

@implementation NezGmoAnimate

+(NezGmoAnimate*) makeNezGmoAnimate {
	return [[[NezGmoAnimate alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		type = 0;
    }
	
    return self;
}

@end

@implementation NezGmoFCurve

+(NezGmoFCurve*) makeNezGmoFCurve {
	return [[[NezGmoFCurve alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		format = 0;
		dims = 0;
		keys = 0;
		data = 0;
    }
	
    return self;
}

- (void)dealloc {
	if (data) {
		free(data);
	}
	[super dealloc];
}

@end



