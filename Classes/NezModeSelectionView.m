//
//  NezModeSelectionView.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezModeSelectionView.h"
#import "GmoLoaderAppDelegate.h"
#import "DataResourceManager.h"
#import "matrix.h"

#define CAMERA_MOTION_INCREMENT (1.0f/8.0f)
#define MAX_MODEL_NAME_LENGTH 32
#define MAX_MODEL_PART_LENGTH 16
#define SHADOW_MAP_RATIO 0.5

static char NEZ_SCENE_MODEL_NAMES[][MAX_MODEL_NAME_LENGTH] = {
	"yuna",
	"mithragirl",
	"lightning",
	"cloud",
	"tidus",
	"squall",
	"terra",
	"goddess",
	"firion",
	"garland",
	"sephiroth",
	"golbez",
	"jecht",
	"kefka",
	"onionknight",
	"warrioroflight",
	"zidane",
};

static int ANIMATION_INDEXES[][3] = {
	{5, 6, 7},
	{5, 6, 7},
	{1, 1, 2}, //0..6
	{5, 6, 7},
	{5, 6, 7},
	{5, 6, 7},
	{5, 6, 7},
	{3, 3, 6},
	{4, 4, 5},
	{4, 4, 9},
	{4, 4, 5},
	{4, 4, 5},
	{4, 4, 5},
	{4, 4, 12},
	{5, 6, 7},
	{5, 6, 7},
	{5, 6, 7},
};

static int HIDE_PART_LIST[][MAX_MODEL_PART_LENGTH] = {
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1},
};

#define FLOOR_SIZE 10

//Light position
static vec3 p_light = {0,3,0.01};

//Light lookAt
static vec3 l_light = {0,0,0};

static const void *POSITION_OFFSET;
static const void *UV_OFFSET;

#define ADDR_OFFSET(a, b) ((const void*)((unsigned int)a-(unsigned int)b))

@interface NezModeSelectionView (private)

-(void)loadModels:(EAGLContext*)context;
-(void)startWalkPath;
-(void)animationFinished;
-(void)drawScene;
-(void)drawFloorWithCamera:(NezCamera*)cam;
-(void)generateShadowFBO;
-(void)setTextureMatrix;
-(NSString*)getCurrentModelName;
-(void)setCameraMode:(int)cMode;
-(void)setCurrentCameraMode;

@end

@implementation NezModeSelectionView

@synthesize cameraMode;

-(vec3)getInitialEye {
	static vec3 v = {1,6,3};
	return v;
}

-(vec3)getInitialTarget {
	static vec3 v = {0,0,0};
	return v;
}

+ (void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
		Vertex v; 
		
		POSITION_OFFSET     = ADDR_OFFSET(v.pos, v.pos);
		UV_OFFSET           = ADDR_OFFSET(v.uv, v.pos);
        initialized = YES;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		float scale[] = {1, -1, 1};
		MatrixGetScale(scale, scaleUpsideDownMatrix);
		
		walkingIndex = -1;
		animationIndex = -1;
		rotY = 0;
		autoCameraDelay = 0;
		
		float t[3] = {0.0, 0.01f, 0.0f};
		MatrixGetTranslation(t, translationMatrix);
		
		Vertex floorVertices[4];
		floorVertices[0].pos[0] = FLOOR_SIZE;
		floorVertices[0].pos[1] = 0;
		floorVertices[0].pos[2] = -FLOOR_SIZE;
		floorVertices[0].uv[0]  = 1;
		floorVertices[0].uv[1]  = 0;
		
		floorVertices[1].pos[0] = -FLOOR_SIZE;
		floorVertices[1].pos[1] = 0;
		floorVertices[1].pos[2] = -FLOOR_SIZE;
		floorVertices[1].uv[0]  = 0;
		floorVertices[1].uv[1]  = 0;
		
		floorVertices[2].pos[0] = FLOOR_SIZE;
		floorVertices[2].pos[1] = 0;
		floorVertices[2].pos[2] = FLOOR_SIZE;
		floorVertices[2].uv[0]  = 1;
		floorVertices[2].uv[1]  = 1;
		
		floorVertices[3].pos[0] = -FLOOR_SIZE;
		floorVertices[3].pos[1] = 0;
		floorVertices[3].pos[2] = FLOOR_SIZE;
		floorVertices[3].uv[0]  = 0;
		floorVertices[3].uv[1]  = 1;
		
		glGenBuffers(1, &floorVboPtr);
		glBindBuffer(GL_ARRAY_BUFFER, floorVboPtr);
		glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex)*4, floorVertices, GL_STATIC_DRAW);
		
		floorProgram = [[[GLSLProgramManager instance] loadProgram:@"Floor"] retain];
		reflectionProgram = [[[GLSLProgramManager instance] loadProgram:@"BonedModelWithFalloff"] retain];
		
		light = [[NezCamera alloc] initWithEye:p_light Target:l_light];
		
		modelLoadedCount = 0;
		modelCount = sizeof(NEZ_SCENE_MODEL_NAMES)/MAX_MODEL_NAME_LENGTH;
		modelArray = malloc(sizeof(NezAnimatedModel*)*modelCount);
		
		cameraMode = 0;
    }
    return self;
}

-(NSString*)getCurrentModelName {
	if (walkingIndex > -1) {
		return [NSString stringWithFormat:@"%s", NEZ_SCENE_MODEL_NAMES[walkingIndex]];
	} else {
		return nil;
	}
}

-(void)loadSceneWithContext:(EAGLContext*)context andArguments:(id)arguments {
	// 	[self generateShadowFBO];
	[NSThread detachNewThreadSelector:@selector(loadModels:) toTarget:self withObject:context];
}

-(void)loadModels:(EAGLContext*)context {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    [EAGLContext setCurrentContext:context];
	
	for (int i=0; i<modelCount; i++) {
		NezBonedModel *modelData = [[DataResourceManager instance] loadModel:[NSString stringWithFormat:@"%s", NEZ_SCENE_MODEL_NAMES[i]] ofType:@"gmo"];
		for (int j=0; j<modelData->partCount; j++) { 
			if (HIDE_PART_LIST[i][j]) {
				modelData->partArray[j].state = PART_INVISIBLE;
			}
		}
		modelArray[i] = [[NezAnimatedModel alloc] initWithModel:modelData];
		[modelArray[i] setAnimationFinishedCallback:self Selector:@selector(animationFinished)];
		modelLoadedCount++;
		if (i==0) {
			[self animationFinished];
		}
	}
    [pool release];
}

-(void)setCameraMode:(int)cMode {
	cameraMode = cMode;
	[self setCurrentCameraMode];
}

-(void)setCurrentCameraMode {
	if (cameraMode < 3) {
		currentCameraMode = cameraMode;
	} else {
		currentCameraMode = arc4random()%3;
	}
}

-(void)animationFinished {
	[self setCurrentCameraMode];
	if (walkingIndex > -1 && (animationIndex == ANIMATION_INDEXES[walkingIndex][0] || animationIndex == ANIMATION_INDEXES[walkingIndex][1])) {
		animationIndex = ANIMATION_INDEXES[walkingIndex][2];
		[modelArray[walkingIndex] setMotion:animationIndex];
		return;
	} else {
		walkingIndex = arc4random()%modelLoadedCount;
		animationIndex = ANIMATION_INDEXES[walkingIndex][arc4random()%2];
	}
	[self startWalkPath];
}

-(void)startWalkPath {
	[modelArray[walkingIndex] setMotion:animationIndex];
	rotY = 3.141592653f*[self getRandomNumber];
	mat4f_LoadYRotation(rotY, rotationMatrix);
	cameraY = 5.0*[self getRandomNumber];
	cameraZ = 3.0+3.0f*[self getRandomNumber];
}

-(void)setAutoCameraDelay:(CFTimeInterval)delay {
	autoCameraDelay = delay;
}

-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed {
	float framesElapsed  = timeElapsed*framesPerSecond;
	if (walkingIndex > -1) {
		[modelArray[walkingIndex] updateWithFramesElapsed:framesElapsed];
		vec4 pos, eye, target;
		[modelArray[walkingIndex] getCameraLookatPosition:&pos];
		MatrixMultVec4(rotationMatrix, &pos.x, &target.x);
		if (currentCameraMode) {
			if (currentCameraMode == 2) {
				pos.y=cameraY;
				pos.z+=cameraZ;
			} else {
				pos.y=cameraY;
				pos.z-=cameraZ;
			}
			MatrixMultVec4(rotationMatrix, &pos.x, &eye.x);
			[camera movePartialWithEyePos:&eye.x Target:&target.x Increment:CAMERA_MOTION_INCREMENT];
		} else {
			[camera movePartialWithTarget:&target.x Increment:CAMERA_MOTION_INCREMENT];
		}
		vec3 lightPos = {target.x+2, target.y+6.5, target.z+2};
		vec3 lightTarget = {target.x, 0.0f, target.z};
		[light setEye:lightPos andTarget:lightTarget];
	}
}	

-(void)draw {
	glViewport(0, 0, screenWidth, screenHeight);
	
	// Prepare the render state for the disk.
	glEnable(GL_STENCIL_TEST);
	glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
	glStencilMask(0x1);
	glStencilFunc(GL_ALWAYS, 1, 1);
	
	glDepthMask(GL_FALSE);
	glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
	[self drawFloorWithCamera:camera];
	
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	glDepthMask(GL_TRUE);
		
	float m1[16], m2[16];
	if (walkingIndex > -1) {
		glCullFace(GL_FRONT);
		glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
		glStencilFunc(GL_EQUAL, 1, 1);
		
		MatrixMultiply(scaleUpsideDownMatrix, translationMatrix, m1);
		MatrixMultiply(m1, rotationMatrix, m2);
		MatrixMultiply([camera matrix], m2, modelViewMatrix);
		MatrixMultiply(projectionMatrix, modelViewMatrix, modelViewProj);
		
		[modelArray[walkingIndex] drawWithMatrix:modelViewProj andProgram:reflectionProgram];
	}
	glDisable(GL_STENCIL_TEST);
	glCullFace(GL_BACK);
		
	glBlendFuncSeparate(GL_DST_ALPHA, GL_ONE, GL_ZERO, GL_ONE_MINUS_SRC_ALPHA); // Alpha factors
	[self drawFloorWithCamera:camera];

	if (walkingIndex > -1) {
		MatrixMultiply(translationMatrix, rotationMatrix, m2);
		MatrixMultiply([camera matrix], m2, modelViewMatrix);
		MatrixMultiply(projectionMatrix, modelViewMatrix, modelViewProj);
		[modelArray[walkingIndex] drawWithMatrix:modelViewProj];
	}
}

-(void)drawWithFrameBufferAA:(GLuint)frameBuffer {
	if (walkingIndex > -1) {
		//First step: Render from the light POV to a FBO, story depth values only
		glBindFramebuffer(GL_FRAMEBUFFER, depthFBO);	//Rendering offscreen
		
		// In the case we render the shadowmap to a higher resolution, the viewport must be modified accordingly.
		glViewport(0,0,screenWidth*SHADOW_MAP_RATIO,screenHeight*SHADOW_MAP_RATIO);
		
		// Clear previous frame values
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_CULL_FACE);
		glCullFace(GL_FRONT);
		
		GLSLProgram *modelToZBufferProgram = [[GLSLProgramManager instance] loadProgram:@"BonedModelZBuffer"];
		
		MatrixMultiply([light matrix], rotationMatrix, modelViewMatrix);
		MatrixMultiply(projectionMatrix, modelViewMatrix, modelViewProj);
		[modelArray[walkingIndex] drawWithMatrix:modelViewProj andProgram:modelToZBufferProgram];
		
		[self setTextureMatrix];
		
		glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
		
		glViewport(0, 0, screenWidth, screenHeight);
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_CULL_FACE);
		glCullFace(GL_BACK);
		
		// Prepare the render state for the disk.
		glEnable(GL_STENCIL_TEST);
		glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
		glStencilFunc(GL_ALWAYS, 1, 1);
		
		glDepthMask(GL_FALSE);
		glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
		[self drawFloorWithCamera:camera];
		
		glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
		glDepthMask(GL_TRUE);
		
		glCullFace(GL_FRONT);
		glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
		glStencilFunc(GL_EQUAL, 1, 1);
		
		float m2[16];
		MatrixMultiply(scaleUpsideDownMatrix, rotationMatrix, m2);
		MatrixMultiply([camera matrix], m2, modelViewMatrix);
		MatrixMultiply(projectionMatrix, modelViewMatrix, modelViewProj);
		
		[modelArray[walkingIndex] drawWithMatrix:modelViewProj andProgram:reflectionProgram];
		glDisable(GL_STENCIL_TEST);
		glCullFace(GL_BACK);
		
		GLSLProgram *floorShadowProgram = [[GLSLProgramManager instance] loadProgram:@"FloorShadow"];
		
		glActiveTexture(GL_TEXTURE7);
		glBindTexture(GL_TEXTURE_2D, depthTextureId);
		
		// Use shader program
		glUseProgram(floorShadowProgram->program);
		
		// Update uniform value
		MatrixMultiply(projectionMatrix, [camera matrix], modelViewProj);
		glUniformMatrix4fv(floorShadowProgram->u_modelViewProjectionMatrix, 1, GL_FALSE, modelViewProj);
		glUniformMatrix4fv(floorShadowProgram->u_textureMatrix, 1, GL_FALSE, textureMatrix);
		glUniform1i(floorShadowProgram->u_shadowMapSampler, 7);
		
		glUniform1f(floorShadowProgram->u_frequency, 16);
		glUniform4f(floorShadowProgram->u_color0, 0.9, 0.9, 0.9, 1.0);
		glUniform4f(floorShadowProgram->u_color1, 0.7, 0.7, 0.7, 1.0);
		
		glEnableVertexAttribArray(floorShadowProgram->a_position);
		glEnableVertexAttribArray(floorShadowProgram->a_uv);
		
		glBlendFuncSeparate(GL_DST_ALPHA, GL_ONE, GL_ZERO, GL_ONE_MINUS_SRC_ALPHA); // Alpha factors
		
		int stride = sizeof(Vertex);
		glBindBuffer(GL_ARRAY_BUFFER, floorVboPtr);
		glVertexAttribPointer(floorShadowProgram->a_position, 3, GL_FLOAT, GL_FALSE, stride, POSITION_OFFSET);
		glVertexAttribPointer(floorShadowProgram->a_uv, 2, GL_FLOAT, GL_FALSE, stride, UV_OFFSET);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		
		//		GLSLProgram *modelShadowProgram = [[GLSLProgramManager instance] loadProgram:@"BonedModelShadow"];
		//		glUseProgram(modelShadowProgram->program);
		
		//		const float bias[16] = {	
		//			0.5, 0.0, 0.0, 0.0, 
		//			0.0, 0.5, 0.0, 0.0,
		//			0.0, 0.0, 0.5, 0.0,
		//			0.5, 0.5, 0.5, 1.0
		//		};
		//		float m[16];
		
		//		MatrixMultiply([light matrix], rotationMatrix, modelViewMatrix);
		//		MatrixMultiply(bias, projectionMatrix, m);
		//		MatrixMultiply(m, modelViewMatrix, textureMatrix);
		
		// Update uniform value
		//		glUniformMatrix4fv(modelShadowProgram->u_textureMatrix, 1, GL_FALSE, textureMatrix);
		//		glUniform1i(modelShadowProgram->u_shadowMapSampler, 7);
		//		glUniform1f(modelShadowProgram->u_shadowMapPixelWidth, screenWidth * SHADOW_MAP_RATIO);
		//		glUniform1f(modelShadowProgram->u_shadowMapPixelHeight, screenHeight * SHADOW_MAP_RATIO);
		
		MatrixMultiply([camera matrix], rotationMatrix, modelViewMatrix);
		MatrixMultiply(projectionMatrix, modelViewMatrix, modelViewProj);
		[modelArray[walkingIndex] drawWithMatrix:modelViewProj];
		//		[modelArray[walkingIndex] drawWithMatrix:modelViewProj andProgram:modelShadowProgram];
	}
}

-(void)drawFloorWithCamera:(NezCamera*)cam {
	// Use shader program
	glUseProgram(floorProgram->program);
	
    // Update uniform value
	MatrixMultiply(projectionMatrix, [cam matrix], modelViewProj);
	glUniformMatrix4fv(floorProgram->u_modelViewProjectionMatrix, 1, GL_FALSE, modelViewProj);
	glUniform1f(floorProgram->u_frequency, 16);
	glUniform4f(floorProgram->u_color0, 0.9, 0.9, 0.9, 1.0);
	glUniform4f(floorProgram->u_color1, 0.7, 0.7, 0.7, 1.0);
	
	//	glDisable(GL_BLEND);
	//	glEnable(GL_DEPTH_TEST);
	
	glEnableVertexAttribArray(floorProgram->a_position);
	glEnableVertexAttribArray(floorProgram->a_uv);
	
	int stride = sizeof(Vertex);
	glBindBuffer(GL_ARRAY_BUFFER, floorVboPtr);
	glVertexAttribPointer(floorProgram->a_position, 3, GL_FLOAT, GL_FALSE, stride, POSITION_OFFSET);
	glVertexAttribPointer(floorProgram->a_uv, 2, GL_FLOAT, GL_FALSE, stride, UV_OFFSET);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void)dealloc {
	for (int i=0; i<modelCount; i++) {
		[modelArray[i] release];
	}
	free(modelArray);
	[floorProgram release];
	[reflectionProgram release];
	
	[super dealloc];
}

-(void)generateShadowFBO {
	int shadowMapWidth = screenWidth * SHADOW_MAP_RATIO;
	int shadowMapHeight = screenHeight * SHADOW_MAP_RATIO;
	
	GLenum FBOstatus;
	
	// Try to use a texture depth component
	glGenTextures(1, &depthTextureId);
	glBindTexture(GL_TEXTURE_2D, depthTextureId);
	
	// GL_LINEAR does not make sense for depth texture. However, next tutorial shows usage of GL_LINEAR and PCF
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
	// Remove artifact on the edges of the shadowmap
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, shadowMapWidth, shadowMapHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
	glBindTexture(GL_TEXTURE_2D, 0);
	
	// create a framebuffer object
	glGenFramebuffers(1, &depthFBO);
	glBindFramebuffer(GL_FRAMEBUFFER, depthFBO);
	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, depthTextureId, 0);
	
	glGenRenderbuffers(1, &zBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, zBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, shadowMapWidth, shadowMapHeight);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, zBuffer);
	
	// check FBO status
	FBOstatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if(FBOstatus != GL_FRAMEBUFFER_COMPLETE) {
		printf("GL_FRAMEBUFFER_COMPLETE_EXT failed, CANNOT use FBO %x\n", FBOstatus);
	}
}

-(void)setTextureMatrix {
	// This is matrix transform every coordinate x,y,z
	// x = x* 0.5 + 0.5 
	// y = y* 0.5 + 0.5 
	// z = z* 0.5 + 0.5 
	// Moving from unit cube [-1,1] to [0,1]  
	const float bias[16] = {	
		0.5, 0.0, 0.0, 0.0, 
		0.0, 0.5, 0.0, 0.0,
		0.0, 0.0, 0.5, 0.0,
		0.5, 0.5, 0.5, 1.0
	};
	float m[16];
	
	//	MatrixMultiply([light matrix], rotationMatrix, modelViewMatrix);
	MatrixMultiply(bias, projectionMatrix, m);
	MatrixMultiply(m, [light matrix], textureMatrix);
}

@end
