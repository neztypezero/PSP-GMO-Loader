//
//  GimDataStructures.m
//  GmoLoader
//
//  Created by David Nesbitt on 8/23/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "GimDataStructures.h"


int CheckGimPictureHeader(const void *buf, int size) {
	if (buf == 0) return false ;
	if (size > 0 && size < (int)(sizeof(GimHeader) + sizeof(GimChunk))) {
		printf("wrong gim header (size)\n") ;
		return 0;
	}
	GimHeader *header = (GimHeader *)buf ;
	if (header->signature != GIM_FORMAT_SIGNATURE) {
		printf("wrong gim header (signature)\n") ;
		return 0;
	}
	if (header->version != GIM_FORMAT_VERSION) {
		printf("wrong gim header (version)\n") ;
		return 0;
	}
	if (header->style != GIM_FORMAT_STYLE_PSP) {
		printf("wrong gim header (style)\n") ;
		return 0;
	}
	return 1;
}

GimChunk *GetGimPictureChunk(const void *buf, int size, int idx) {
	GimChunk *root = GetGimPictureRootChunk(buf, size);
	return FindGimPictureChildChunk(root, GIM_PICTURE, idx);
}

//----------------------------------------------------------------
//  chunk functions
//----------------------------------------------------------------

GimChunk *GetGimPictureRootChunk(const void *buf, int size) {
	if (buf == 0) return 0 ;
	GimHeader *header = (GimHeader*)buf;
	return (GimChunk*)(header+1);
}

GimChunk *FindGimPictureChildChunk(const GimChunk *chunk, int type, int idx) {
	if (chunk == 0) return 0 ;
	GimChunk *end = GetNextGimChunk(chunk);
	for (chunk = GetChildGimChunk(chunk); chunk < end; chunk = GetNextGimChunk(chunk)) {
		if (type == 0 || GetGimChunkType(chunk) == type) {
			if (--idx == -1) return (GimChunk*)chunk;
		}
	}
	return 0 ;
}

//----------------------------------------------------------------
//  Pixel Copy Functions
//----------------------------------------------------------------

void Copy5650( unsigned int *dst, unsigned short *src, int w )
{
	for ( int i = 0 ; i < w ; i ++ ) {
		unsigned int color = *( src ++ ) ;
		unsigned int r = ( ( ( color & 0x001f ) * 0x21 ) << 14 ) & 0x00ff0000 ;
		unsigned int g = ( ( ( color & 0x07e0 ) * 0x41 ) >> 1 ) & 0x0000ff00 ;
		unsigned int b = ( ( color & 0xf800 ) * 0x21 ) >> 13 ;
		unsigned int a = 0xff000000 ;
		*( dst ++ ) = r | g | b | a ;
	}
}

void Copy5551( unsigned int *dst, unsigned short *src, int w )
{
	for ( int i = 0 ; i < w ; i ++ ) {
		unsigned int color = *( src ++ ) ;
		unsigned int r = ( ( ( color & 0x001f ) * 0x21 ) << 14 ) & 0x00ff0000 ;
		unsigned int g = ( ( ( color & 0x03e0 ) * 0x21 ) << 1 ) & 0x0000ff00 ;
		unsigned int b = ( ( ( color & 0x7c00 ) * 0x21 ) >> 12 ) ;
		unsigned int a = ( ( color & 0x8000 ) * 0xff ) << 12 ;
		*( dst ++ ) = r | g | b | a ;
	}
}

void Copy4444( unsigned int *dst, unsigned short *src, int w )
{
	for ( int i = 0 ; i < w ; i ++ ) {
		unsigned int color = *( src ++ ) ;
		unsigned int r = ( ( color & 0x000f ) * 0x11 ) << 16 ;
		unsigned int g = ( ( color & 0x00f0 ) * 0x11 ) << 4 ;
		unsigned int b = ( ( color & 0x0f00 ) * 0x11 ) >> 8 ;
		unsigned int a = ( ( color & 0xf000 ) * 0x11 ) << 12 ;
		*( dst ++ ) = r | g | b | a ;
	}
}

void Copy8888( unsigned int *dst, unsigned int *src, int w ) {
	memcpy(dst, src, w*sizeof(unsigned int));
}

/*******************************************************************
 * Objective C structures
 *******************************************************************/

@implementation NezGimPicture

+(NezGimPicture*) makeNezGimPicture {
	return [[[NezGimPicture alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		width = 0;
		height = 0;
		texturePixels = 0;
		memset(filename, 0, sizeof(filename));
    }
	
    return self;
}

- (void)dealloc {
	if (texturePixels) {
		free(texturePixels);
	}
	[super dealloc];
}

@end