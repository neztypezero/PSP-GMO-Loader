//
//  NezPlaybackBar.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/5/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezPlaybackBar.h"
#import "GLSLProgramManager.h"
#import "TextureManager.h"
#import "matrix.h"
#import "Math.h"

#define BUTTON_BIG_SIZE 64.0
#define BUTTON_SMALL_SIZE 48.0

@implementation NezPlaybackBar

-(id)initWithScreenWidth:(int)width Height:(int)height {
	if (self = [super init]) {
		blitTextureProgram = [[[GLSLProgramManager instance] loadProgram:@"BlitTexture"] retain];
		buttonsTexture = [[TextureManager instance] loadTextureWithPathForResource:@"buttons" ofType:@"png" inDirectory:@"Icons"];
		
		float orthoMatrix[16];
		mat4f_LoadOrtho(0, width , 0 , height, -1, 1, orthoMatrix);
		
		float texCoordWidth = BUTTON_BIG_SIZE/buttonsTexture.width;
		int vIndex = 0;
		float uv[PLAYBACK_BUTTON_COUNT][4] = {
			{0, 0, texCoordWidth, 1},
			{texCoordWidth, 0, 0, 1},
			{texCoordWidth*3, 0, texCoordWidth*2, 1},
			{0, 0, texCoordWidth, 1},
			{texCoordWidth*2, 0, texCoordWidth*3, 1},
		};
		
		int centerX = width/2;
		int buttonCenterY = 12+BUTTON_BIG_SIZE/2;
		
		Button b[PLAYBACK_BUTTON_COUNT] = {
			{centerX-BUTTON_BIG_SIZE/2, buttonCenterY-BUTTON_BIG_SIZE/2, BUTTON_BIG_SIZE, BUTTON_BIG_SIZE},
			{centerX-BUTTON_BIG_SIZE/2-5-BUTTON_SMALL_SIZE*1, buttonCenterY-BUTTON_SMALL_SIZE/2, BUTTON_SMALL_SIZE, BUTTON_SMALL_SIZE},
			{centerX-BUTTON_BIG_SIZE/2-10-BUTTON_SMALL_SIZE*2, buttonCenterY-BUTTON_SMALL_SIZE/2, BUTTON_SMALL_SIZE, BUTTON_SMALL_SIZE},
			{centerX+BUTTON_BIG_SIZE/2+5+BUTTON_SMALL_SIZE*0, buttonCenterY-BUTTON_SMALL_SIZE/2, BUTTON_SMALL_SIZE, BUTTON_SMALL_SIZE},
			{centerX+BUTTON_BIG_SIZE/2+10+BUTTON_SMALL_SIZE*1, buttonCenterY-BUTTON_SMALL_SIZE/2, BUTTON_SMALL_SIZE, BUTTON_SMALL_SIZE},
		};
		for (int i=0; i<PLAYBACK_BUTTON_COUNT; i++) {
			buttons[i] = b[i];
			
			vec4 pos1 = {buttons[i].x, buttons[i].y, 0, 1};
			vec4 pos2 = {buttons[i].x+buttons[i].w, buttons[i].y+buttons[i].h, 0, 1};
			vec4 cPos1, cPos2;
			
			MatrixMultVec4(orthoMatrix, &pos1.x, &cPos1.x);
			MatrixMultVec4(orthoMatrix, &pos2.x, &cPos2.x);
			
			if (i > 0) {
				//Add degenerate triangles
				buttonVertices[vIndex].pos.x = buttonVertices[vIndex-1].pos.x;
				buttonVertices[vIndex].pos.y = buttonVertices[vIndex-1].pos.y;
				buttonVertices[vIndex].uv.x = buttonVertices[vIndex-1].uv.x;
				buttonVertices[vIndex].uv.y = buttonVertices[vIndex-1].uv.y;		
				vIndex++;

				buttonVertices[vIndex].pos.x = cPos1.x;
				buttonVertices[vIndex].pos.y = cPos2.y;
				buttonVertices[vIndex].uv.x = uv[i][0];
				buttonVertices[vIndex].uv.y = uv[i][3];
				vIndex++;
			}
			
			buttonVertices[vIndex].pos.x = cPos1.x;
			buttonVertices[vIndex].pos.y = cPos2.y;
			buttonVertices[vIndex].uv.x = uv[i][0];
			buttonVertices[vIndex].uv.y = uv[i][3];
			vIndex++;
			buttonVertices[vIndex].pos.x = cPos1.x;
			buttonVertices[vIndex].pos.y = cPos1.y;
			buttonVertices[vIndex].uv.x = uv[i][0];
			buttonVertices[vIndex].uv.y = uv[i][1];
			vIndex++;
			buttonVertices[vIndex].pos.x = cPos2.x;
			buttonVertices[vIndex].pos.y = cPos2.y;
			buttonVertices[vIndex].uv.x = uv[i][2];
			buttonVertices[vIndex].uv.y = uv[i][3];
			vIndex++;
			buttonVertices[vIndex].pos.x = cPos2.x;
			buttonVertices[vIndex].pos.y = cPos1.y;
			buttonVertices[vIndex].uv.x = uv[i][2];
			buttonVertices[vIndex].uv.y = uv[i][1];
			vIndex++;
		}
	}
	return self;
}

-(void)draw {
	glEnableVertexAttribArray(blitTextureProgram->a_position);
	glEnableVertexAttribArray(blitTextureProgram->a_uv);
	
	glDisable(GL_DEPTH_TEST);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	
	glUseProgram(blitTextureProgram->program);

	// Set the sampler texture unit to 0
	glUniform1i(blitTextureProgram->u_sampler, 0);
	
	glBindTexture(GL_TEXTURE_2D, buttonsTexture.name);

	int stride = sizeof(struct Vertex2D);
	glVertexAttribPointer(blitTextureProgram->a_position, 2, GL_FLOAT, GL_FALSE, stride, &buttonVertices[0].pos);
	glVertexAttribPointer(blitTextureProgram->a_uv, 2, GL_FLOAT, GL_FALSE, stride, &buttonVertices[0].uv);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, PLAYBACK_VERTEX_COUNT);
}

-(int)pointInButton:(vec2)point {
	for (int i=0; i<PLAYBACK_BUTTON_COUNT; i++) {
		int cx = buttons[i].x+buttons[i].w/2;
		int cy = buttons[i].y+buttons[i].h/2;
		int dx = point.x-cx;
		int dy = point.y-cy;
		int distance = sqrt(dx*dx+dy*dy);
		if (distance <= buttons[i].w/2) {
			return i;
		}
	}
	return -1;
}

@end
