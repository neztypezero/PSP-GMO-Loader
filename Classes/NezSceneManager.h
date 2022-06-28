//
//  DataResourceManager.h
//  NezFFModelViewer
//
//  Created by David Nesbitt on 2/14/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "DataResourceManager.h"
#import "GLSLProgramManager.h"
#import "TextureManager.h"

#import "NezScene.h"

@class NezSceneManager;

@interface NezSceneManager : NSObject {
	NezScene *currentScene;
}

+(NezSceneManager*)instance;

-(NezScene*)loadScene:(NSString*)name;
-(NSArray*)getAllSceneClasses;

@end
