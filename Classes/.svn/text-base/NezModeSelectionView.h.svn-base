//
//  NezModeSelectionView.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezZoomRotationView.h"
#import "NezScene.h"
#import "NezAnimatedModel.h"
#import "GLSLProgram.h"

@interface NezModeSelectionView : NezZoomRotationView {
	// Hold id of the framebuffer for light POV rendering
	GLuint depthFBO;
	
	// Z values will be rendered to this texture when using depthFBO framebuffer
	GLuint depthTextureId;
	GLuint colorDepthbuffer;
	GLuint zBuffer;
	
	float textureMatrix[16];
	
	float reflectedProjectionMatrix[16];
	
	int modelCount;
	int modelLoadedCount;
    NezAnimatedModel **modelArray;
	
	int walkingIndex;
	int animationIndex;
	float rotationMatrix[16];
	float nextAnimationStart;
	float translationMatrix[16];
	float scaleUpsideDownMatrix[16];
	float maxX;
	float dx, dz;
	float rotY;
	float distanceTravelled;
	float distancePerFrame;
	
	float cameraY, cameraZ;
	
	unsigned int floorVboPtr;

	float cameraLookAtSLERPRatio;
	float cameraPosSLERPRatio;
	
	vec3 currentLookAt;
	vec3 currentTarget;
	
	int cameraMode;
	int currentCameraMode;
	CFTimeInterval autoCameraDelay;
	
	GLSLProgram *floorProgram;
	GLSLProgram *reflectionProgram;
	
	NezCamera *light;
}

@property (readonly, nonatomic, getter=getCurrentModelName) NSString *currentModelName;
@property (nonatomic, setter=setCameraMode:) int cameraMode;

@end
