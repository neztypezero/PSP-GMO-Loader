//
//  NezAnimationSelectionView.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NezAnimationSelectionView.h"
#import "GmoLoaderAppDelegate.h"
#import "ModelNameAniIndexHolder.h"
#import "DataResourceManager.h"
#import "matrix.h"
#import "EAGLView.h"


#define HALO_SCALE 0.04f

@interface NezAnimationSelectionView (private)

-(void)loadModels;
-(void)setSelectedAnimationIndex:(int)i;
-(int)getThumbSize;

@end

@implementation NezAnimationSelectionView

@synthesize animationCount;
@synthesize thumbWidth;
@synthesize thumbHeight;
@synthesize thumbnailOffset;
@synthesize selectedAnimationIndex;

-(NSInteger)getAnimationFrameInterval {
	return 2;
}

-(vec3)getInitialEye {
	static vec3 v = {0.0f, 0.9f, 5.0f};
	return v;
}

-(vec3)getInitialTarget {
	static vec3 v = {0.0f, 0.9f, 0.0f};
	return v;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		modelAnimationArray = NULL;
		thumbnailOffset = 0;
		mainModel = nil;
		modelName = nil;
		selectedAnimationIndex = 0;
		isAutoZooming = YES;
		autoZoomFlag = YES;
		autoZoomRate = 0.2;
    }
    return self;
}

-(void)setThumbnailOffset:(float)offset {
	thumbnailOffset = -offset*screenScale;
}

-(void)setThumbY:(float)y {
	thumbY = y;
}

-(void)layoutSubviews {
	if (firstLayout) {
		float thumbCount = 6;
		thumbWidth = self.frame.size.width/thumbCount;
		scaledThumbWidth = screenWidth/thumbCount;
		thumbHeight = (self.frame.size.width*(self.frame.size.height/self.frame.size.width))/thumbCount;
		scaledThumbHeight = (screenWidth*(self.frame.size.height/self.frame.size.width))/thumbCount;
		thumbY = -scaledThumbHeight;
	}
	[super layoutSubviews];
}

-(void)loadSceneWithContext:(EAGLContext*)context andArguments:(id)arguments {
	ModelNameAniIndexHolder *modelInfo = (ModelNameAniIndexHolder*)arguments;
	modelName = [modelInfo->modelName retain];
	selectedAnimationIndex = modelInfo->animationIndex;
	[self loadModels];
}

-(void)loadModels {
	modelData = [[DataResourceManager instance] loadModel:modelName ofType:@"gmo"];
	
	animationCount = [modelData->motionArray count];
	if (animationCount > 0) {
		NezHaloModel **aniArray = malloc(sizeof(NezHaloModel*)*animationCount);
		for (int i=0; i<animationCount; i++) {
			aniArray[i] = [[NezHaloModel alloc] initWithModel:modelData];
			[aniArray[i] setMotion:i];
		}
		[aniArray[selectedAnimationIndex] setHaloScaleMax:HALO_SCALE];
		mainModel = [[NezAnimatedModel alloc] initWithModel:modelData];
		[mainModel setMotion:selectedAnimationIndex];
		
		modelAnimationArray = aniArray;
	}
	float y = modelData->boundingBox[0].y+(modelData->boundingBox[1].y-modelData->boundingBox[0].y)/2.0f;
	float z = modelData->boundingBox[0].z+(modelData->boundingBox[1].z-modelData->boundingBox[0].z)/2.0f;
	
	vec3 e = {0.0f, y, z+5};
	vec3 t = {0.0f, y, z};
	[camera setEye:e andTarget:t];
}

-(void) dealloc {
	if (animationCount > 0) {
		for (int i=0; i<animationCount; i++) {
			[modelAnimationArray[i] release];
		}
		free(modelAnimationArray);
	}
	if (mainModel) {
		[mainModel release];
	}
	if (modelName) {
		[modelName release];
	}
    [super dealloc];
}

-(void)setSelectedAnimationIndex:(int)i {
	[modelAnimationArray[selectedAnimationIndex] setHaloScaleMax:0.0f];
	selectedAnimationIndex = i;
	[modelAnimationArray[selectedAnimationIndex] setHaloScaleMax:HALO_SCALE];
	[mainModel setMotion:i];
}

-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed {
	float framesElapsed  = timeElapsed*framesPerSecond;
	
	if (modelAnimationArray) {
		for (int i=0; i<animationCount; i++) {
			[modelAnimationArray[i] updateWithFramesElapsed:framesElapsed];
		}
		[mainModel updateWithFramesElapsed:framesElapsed];
		if (isAutoZooming) {
			MatrixMultiply(projectionMatrix, [camera matrix], modelViewProj);
			vec4 target = {modelData->boundingBox[1].x, modelData->boundingBox[1].y*1.12, 0.0, 1.0f};
			vec4 outTarget;
			MatrixMultVec4(modelViewProj, &target.x, &outTarget.x);
			float x = outTarget.x/outTarget.w;
			float y = outTarget.y/outTarget.w;
			vec3 newEye = camera->eye;
			float yZoomPoint;
			if (x > 0) {
				yZoomPoint = 0.9;
			} else {
				yZoomPoint = 0.19;
			}
			if (y < yZoomPoint) {
				if (autoZoomFlag == NO) {
					autoZoomRate /= 10.0;
					autoZoomFlag = YES;
				}
				newEye.z -= autoZoomRate;
				[camera setEye:newEye andTarget:camera->target];
			} else if (y > yZoomPoint) {
				if (autoZoomFlag == YES) {
					autoZoomRate /= 10.0;
					autoZoomFlag = NO;
				}
				newEye.z += autoZoomRate;
				[camera setEye:newEye andTarget:camera->target];
			} else {
				isAutoZooming = NO;
			}
			MatrixCopy([camera matrix], smallCameraMat);
		}
		if (thumbY < 0) {
			thumbY+=12;
			if (thumbY > 0) {
				thumbY = 0;
			}
		}
	}
	[super updateWithTimeElapsed:timeElapsed];
}

-(void)draw {
	if (modelAnimationArray) {
		glViewport(0, 0, screenWidth, screenHeight);
		
		MatrixMultiply(projectionMatrix, [camera matrix], modelViewProj);
		[mainModel drawWithMatrix:modelViewProj];
		
		glClear(GL_DEPTH_BUFFER_BIT);
		
		MatrixMultiply(projectionMatrix, smallCameraMat, modelViewProj);
		int x=thumbnailOffset;
		for (int i=0; i<animationCount; i++) {
			if (x > -scaledThumbWidth) {
				glViewport(x, thumbY, scaledThumbWidth, scaledThumbHeight);
				[modelAnimationArray[i] drawWithMatrix:modelViewProj];
			}
			if (x >= screenWidth) {
				break;
			}
			x += scaledThumbWidth;
		}
	}
}

@end
