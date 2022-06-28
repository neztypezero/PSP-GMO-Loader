//
//  GimDataStructures.h
//  GmoLoader
//
//  Created by David Nesbitt on 8/23/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

/* ---------------------------------------------------------------- */
/*  picture structures                                              */
/* ---------------------------------------------------------------- */

#define	GIM_FORMAT_SIGNATURE	(0x2e47494d)	/* '.GIM' */
#define	GIM_FORMAT_VERSION		(0x312e3030)	/* '1.00' */
#define	GIM_FORMAT_STYLE_PSP	(0x00505350)	/* 'PSP'  */

enum {
	GIM_BASE_RESERVED	= 0x0000,	/* 0000-0fff : reserved */
	GIM_BASE_PRIVATE	= 0x1000,	/* 1000-3fff : private use */
	GIM_BASE_PUBLIC		= 0x4000,	/* 4000-7fff : public use */
	
	GIM_BLOCK			= 0x0001,
	GIM_FILE			= 0x0002,
	GIM_PICTURE			= 0x0003,
	GIM_IMAGE			= 0x0004,
	GIM_PALETTE			= 0x0005,
	GIM_SEQUENCE		= 0x0006,
	GIM_FILE_INFO		= 0x00ff
};

enum {
	GIM_FORMAT_RGBA5650	= 0,
	GIM_FORMAT_RGBA5551	= 1,
	GIM_FORMAT_RGBA4444	= 2,
	GIM_FORMAT_RGBA8888	= 3,
	GIM_FORMAT_INDEX4	= 4,
	GIM_FORMAT_INDEX8	= 5,
	GIM_FORMAT_INDEX16	= 6,
	GIM_FORMAT_INDEX32	= 7,
	GIM_FORMAT_DXT1		= 8,
	GIM_FORMAT_DXT3		= 9,
	GIM_FORMAT_DXT5		= 10,
	GIM_FORMAT_DXT1EXT	= 264,
	GIM_FORMAT_DXT3EXT	= 265,
	GIM_FORMAT_DXT5EXT	= 266
};

enum {
	GIM_ORDER_NORMAL	= 0,
	GIM_ORDER_PSPIMAGE	= 1
};

enum {
	GIM_TYPE_GENERIC	= 0,
	GIM_TYPE_MIPMAP		= 1,
	GIM_TYPE_MIPMAP2	= 2,
	GIM_TYPE_SEQUENCE	= 3
};

enum {
	GIM_INTERP_TYPEMASK	= 0x0f,
	GIM_INTERP_DISSOLVE	= 0x80,
	GIM_INTERP_EVENT	= 0x40,
	
	GIM_INTERP_CONSTANT	= 0,
	GIM_INTERP_LINEAR	= 1
};

enum {
	GIM_REPEAT_HOLD		= 0,
	GIM_REPEAT_CYCLE	= 1
};

enum {
	GIM_PARAM_IMAGE_INDEX	= 0,
	GIM_PARAM_IMAGE_PLANE	= 1,
	GIM_PARAM_IMAGE_LEVEL	= 2,
	GIM_PARAM_IMAGE_FRAME	= 3,
	GIM_PARAM_PALETTE_INDEX	= 8,
	GIM_PARAM_PALETTE_LEVEL	= 10,
	GIM_PARAM_PALETTE_FRAME	= 11,
	GIM_PARAM_CROP_U		= 16,
	GIM_PARAM_CROP_V		= 17,
	GIM_PARAM_CROP_W		= 18,
	GIM_PARAM_CROP_H		= 19,
	GIM_PARAM_BLEND_MODE	= 32,
	GIM_PARAM_FUNC_MODE		= 34,
	GIM_PARAM_FUNC_COMP		= 35,
	GIM_PARAM_FILTER_MAG	= 36,
	GIM_PARAM_FILTER_MIN	= 37,
	GIM_PARAM_WRAP_U		= 38,
	GIM_PARAM_WRAP_V		= 39
};

enum {
	GIM_BLEND_OFF		= 0,
	GIM_BLEND_MIX		= 1,
	GIM_BLEND_ADD		= 2,
	GIM_BLEND_SUB		= 3,
	GIM_BLEND_MIN		= 4,
	GIM_BLEND_MAX		= 5,
	GIM_BLEND_ABS		= 6
};

enum {
	GIM_FUNC_MODULATE	= 0,
	GIM_FUNC_DECAL		= 1,
	
	GIM_FUNC_RGB		= 0,
	GIM_FUNC_RGBA		= 1
};

enum {
	GIM_FILTER_NEAREST		= 0,
	GIM_FILTER_LINEAR		= 1,
	GIM_FILTER_NEAREST_MIPMAP_NEAREST = 4,
	GIM_FILTER_LINEAR_MIPMAP_NEAREST = 5,
	GIM_FILTER_NEAREST_MIPMAP_LINEAR = 6,
	GIM_FILTER_LINEAR_MIPMAP_LINEAR = 7
};

enum {
	GIM_WRAP_REPEAT		= 0,
	GIM_WRAP_CLAMP		= 1
};

enum {
	TM2_FORMAT_SIGNATURE	= 0x324d4954,	// '2MIT'
	BMP_FORMAT_SIGNATURE	= 0x4d42	// 'MB'
};

/* ---------------------------------------------------------------- */
/*   header structure                                               */
/* ---------------------------------------------------------------- */

typedef struct {
	unsigned int signature;
	unsigned int version;
	unsigned int style;
	unsigned int option;
} GimHeader;

/* ---------------------------------------------------------------- */
/*  chunk structure                                                 */
/* ---------------------------------------------------------------- */

typedef struct {
	unsigned short type;
	unsigned short unused;
	unsigned int nextOffset;
	unsigned int childOffset;
	unsigned int dataOffset;
} GimChunk;

static __inline__ int GetGimChunkType(const GimChunk *chunk) {
	return chunk->type;
}

static __inline__ GimChunk *GetNextGimChunk(const GimChunk *chunk) {
	return (GimChunk *)((char *)chunk + chunk->nextOffset);
}

static __inline__ GimChunk *GetChildGimChunk(const GimChunk *chunk) {
	return (GimChunk *)((char *)chunk + chunk->childOffset);
}

static __inline__ void *GetGimChunkData(const GimChunk *chunk) {
	return (char *)chunk + chunk->dataOffset;
}

static __inline__ int GetGimChunkDataSize(const GimChunk *chunk) {
	return chunk->childOffset - chunk->dataOffset;
}

/* ---------------------------------------------------------------- */
/*   image chunk data                                               */
/* ---------------------------------------------------------------- */

typedef struct {
	unsigned short headerSize;
	unsigned short reference;
	unsigned short format;
	unsigned short order;
	unsigned short width;
	unsigned short height;
	unsigned short bpp;
	unsigned short pitchAlign;
	unsigned short heightAlign;
	unsigned short dimCount;
	unsigned short reserved;
	unsigned short reserved2;
	unsigned int offsets;
	unsigned int images;
	unsigned int total;
	unsigned int planeMask;
	unsigned short levelType;
	unsigned short levelCount;
	unsigned short frameType;
	unsigned short frameCount;
} GimImageHeader;

/* ---------------------------------------------------------------- */
/*  palette chunk data                                              */
/* ---------------------------------------------------------------- */

typedef GimImageHeader GimPaletteHeader;

static __inline__ void *GetGimImagePixels(const GimImageHeader *image, int level, int frame) {
	void **offsets = (void**)((char*)image + image->offsets);
	int n_levels = image->levelCount;
	int n_frames = image->frameCount;
	if (level < 0 || level >= n_levels) return 0;
	frame %= n_frames;
	if (frame < 0) frame += n_frames;
	return offsets[n_levels * frame + level];
}

static __inline__ int GetGimImageWidth(const GimImageHeader *image, int level) {
	int width = image->width;
	if (level > 0 && image->levelType == GIM_TYPE_MIPMAP) {
		while (-- level >= 0) width = (width + 1) / 2;
	}
	return width;
}

static __inline__ int GetGimImageHeight(const GimImageHeader *image, int level) {
	int height = image->height;
	if (level > 0 && image->levelType == GIM_TYPE_MIPMAP) {
		while (-- level >= 0) height = (height + 1) / 2;
	}
	return height;
}

static __inline__ int GetGimImagePitch(const GimImageHeader *image, int width) {
	int align = image->pitchAlign * 8 - 1;
	return ((image->bpp * width + align) & ~align) / 8;
}

int CheckGimPictureHeader(const void *buf, int size);

GimChunk *GetGimPictureChunk(const void *buf, int size, int idx);
GimChunk *GetGimPictureRootChunk(const void *buf, int size);
GimChunk *FindGimPictureChildChunk(const GimChunk *chunk, int type, int idx);

void Copy5650(unsigned int *dst, unsigned short *src, int w);
void Copy5551(unsigned int *dst, unsigned short *src, int w);
void Copy4444(unsigned int *dst, unsigned short *src, int w);
void Copy8888(unsigned int *dst, unsigned int *src, int w);

/*******************************************************************
 * Objective C structures
 *******************************************************************/

#define MAX_FILENAME_LENGTH 32

@interface NezGimPicture : NSObject {
	
@public
	int width;
	int height;
	unsigned char *texturePixels;
	char filename[MAX_FILENAME_LENGTH+1];
}

+(NezGimPicture*) makeNezGimPicture;

@end





