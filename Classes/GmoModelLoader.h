//
//  GmoModelLoader.h
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NezModelLoader.h"


@interface GmoModelLoader : NSObject <NezModelLoader> {
	@public
	NSMutableArray *boneArray;
	NSMutableArray *materialArray;
	NSMutableArray *partArray;
	NSMutableArray *textureArray;
	NSMutableArray *motionArray;

	float *vertexOffset;
	float *textureOffset;
	float vertexOffsetMatrix[16];
	float textureOffsetMatrix[4];
	
	BOOL hasBoundingBox;
	float boundingBox[2][3];
}

@end
