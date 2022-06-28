//
//  DataResourceManager.h
//  NezFFModelViewer
//
//  Created by David Nesbitt on 2/14/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "NezBonedModelStructures.h"

//CONSTANTS:

typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGBA4444,
	kTexture2DPixelFormat_RGBA5551,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_RGB888,
	kTexture2DPixelFormat_L8,
	kTexture2DPixelFormat_A8,
	kTexture2DPixelFormat_LA88,
	kTexture2DPixelFormat_RGB_PVRTC2,
	kTexture2DPixelFormat_RGB_PVRTC4,
	kTexture2DPixelFormat_RGBA_PVRTC2,
	kTexture2DPixelFormat_RGBA_PVRTC4
} Texture2DPixelFormat;

@class TextureManager;

@interface TextureManager : NSObject {
	NSMutableDictionary *textureDict;
}

+(TextureManager*)instance;

-(TextureInfo)loadTextureWithPathForResource:(NSString*)filename ofType:(NSString*)fileType inDirectory:(NSString*)dir;
-(TextureInfo)loadTextureWithCGImage:(CGImageRef)image orientation:(UIImageOrientation)orientation sizeToFit:(BOOL)sizeToFit pixelFormat:(Texture2DPixelFormat)pixelFormat;
-(TextureInfo)loadTexture:(unsigned char*)pixels Width:(int)width Height:(int)height Name:(char*)name PixelFormat:(Texture2DPixelFormat)pixelFormat;

-(void)releaseAll;

@end
