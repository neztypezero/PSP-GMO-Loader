//
//  NezPlaybackBar.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/5/10.
//  Copyright 2010 NezSoft. All rights reserved.
//


#import "GLSLProgram.h"
#import "NezBonedModelStructures.h"

typedef struct Button {
	int x, y;
	int w, h;
	vec2 uvUp;
	vec2 uvDown;
	vec2 uvDisabled;
} Button;

typedef enum PlaybackButon {
	BUTTON_PLAY,
	BUTTON_BACK,
	BUTTON_START,
	BUTTON_FORWARD,
	BUTTON_END,
	PLAYBACK_BUTTON_COUNT
} PlaybackButon;

#define PLAYBACK_VERTEX_COUNT (4+(6*(PLAYBACK_BUTTON_COUNT-1)))

@interface NezPlaybackBar : NSObject {
	GLSLProgram *blitTextureProgram;
	TextureInfo buttonsTexture;
	Vertex2D buttonVertices[PLAYBACK_VERTEX_COUNT];
	Button buttons[PLAYBACK_BUTTON_COUNT];
}

-(id)initWithScreenWidth:(int)width Height:(int)height;
-(void)draw;
-(int)pointInButton:(vec2)point;

@end
