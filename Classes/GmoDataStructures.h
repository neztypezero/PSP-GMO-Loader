//
//  GmoDataStructures.h
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

typedef unsigned char byte;

typedef struct GmoVec2F { float x, y; } GmoVec2F;
typedef struct GmoVec3F { float x, y, z; } GmoVec3F;
typedef struct GmoVec4F { float x, y, z, w; } GmoVec4F;
typedef struct GmoMat4F { GmoVec4F x, y, z, w; } GmoMat4F;
typedef struct GmoQuatF { float x, y, z, w; } GmoQuatF;
typedef struct GmoRectF { float x, y, w, h; } GmoRectF;
typedef struct GmoCol4F { float r, g, b, a; } GmoCol4F;
typedef struct GmoCol4B { byte r, g, b, a; } GmoCol4B;

enum {
	GMO_BASE_RESERVED	= 0x0000,	/* 0000-0fff : reserved */
	GMO_BASE_PRIVATE	= 0x1000,	/* 1000-3fff : private use */
	GMO_BASE_PUBLIC		= 0x4000,	/* 4000-7fff : public use */
	
	GMO_HALF_CHUNK		= 0x8000,	/* half chunk flag */
	
	GMO_BLOCK			= 0x0001,
	GMO_FILE			= 0x0002,
	GMO_MODEL			= 0x0003,
	GMO_BONE			= 0x0004,
	GMO_PART			= 0x0005,
	GMO_MESH			= 0x0006,
	GMO_ARRAYS			= 0x0007,
	GMO_MATERIAL		= 0x0008,
	GMO_LAYER			= 0x0009,
	GMO_TEXTURE			= 0x000a,
	GMO_MOTION			= 0x000b,
	GMO_FCURVE			= 0x000c,
	GMO_BLIND_BLOCK		= 0x000f,
	
	GMO_COMMAND			= 0x0011,
	GMO_FILE_NAME		= 0x0012,
	GMO_FILE_IMAGE		= 0x0013,
	GMO_BOUNDING_BOX	= 0x0014,
	GMO_BOUNDING_POINTS	= 0x0016,
	GMO_VERTEX_OFFSET	= 0x0015,
	
	GMO_DEFINE_ENUM		= 0x0021,
	GMO_DEFINE_BLOCK	= 0x0022,
	GMO_DEFINE_COMMAND	= 0x0023,
	
	GMO_PARENT_BONE		= 0x0041,
	GMO_VISIBILITY		= 0x0042,
	GMO_MORPH_WEIGHTS	= 0x0043,
	GMO_MORPH_INDEX		= 0x004f,
	GMO_BLEND_BONES		= 0x0044,
	GMO_BLEND_OFFSETS	= 0x0045,
	GMO_PIVOT			= 0x0046,
	GMO_MULT_MATRIX		= 0x0047,
	GMO_TRANSLATE		= 0x0048,
	GMO_ROTATE_ZYX		= 0x0049,
	GMO_ROTATE_YXZ		= 0x004a,
	GMO_ROTATE_Q		= 0x004b,
	GMO_SCALE			= 0x004c,
	GMO_SCALE_2			= 0x004d,
	GMO_SCALE_3			= 0x00e1,
	GMO_DRAW_PART		= 0x004e,
	GMO_BONE_STATE		= 0x00e2,
	
	GMO_SET_MATERIAL	= 0x0061,
	GMO_BLEND_SUBSET	= 0x0062,
	GMO_SUBDIVISION		= 0x0063,
	GMO_KNOT_VECTOR_U	= 0x0064,
	GMO_KNOT_VECTOR_V	= 0x0065,
	GMO_DRAW_ARRAYS		= 0x0066,
	GMO_DRAW_PARTICLE	= 0x0067,
	GMO_DRAW_B_SPLINE	= 0x0068,
	GMO_DRAW_RECT_MESH	= 0x0069,
	GMO_DRAW_RECT_PATCH	= 0x006a,
	
	GMO_RENDER_STATE	= 0x0081,
	GMO_DIFFUSE			= 0x0082,
	GMO_SPECULAR		= 0x0083,
	GMO_EMISSION		= 0x0084,
	GMO_AMBIENT			= 0x0085,
	GMO_REFLECTION		= 0x0086,
	GMO_REFRACTION		= 0x0087,
	GMO_BUMP			= 0x0088,
	
	GMO_SET_TEXTURE		= 0x0091,
	GMO_MAP_TYPE		= 0x0092,
	GMO_MAP_FACTOR		= 0x0093,
	GMO_BLEND_FUNC		= 0x0094,
	GMO_TEX_FUNC		= 0x0095,
	GMO_TEX_FILTER		= 0x0096,
	GMO_TEX_WRAP		= 0x0097,
	GMO_TEX_CROP		= 0x0098,
	
	GMO_FRAME_LOOP		= 0x00b1,
	GMO_FRAME_RATE		= 0x00b2,
	GMO_FRAME_REPEAT	= 0x00b4,
	GMO_ANIMATE			= 0x00b3,
	
	GMO_BLIND_DATA		= 0x00f1,
	GMO_FILE_INFO		= 0x00ff
};

enum {
	GMO_FCURVE_FLOAT16		= 0x0080,
	
	GMO_FCURVE_INTERP_MASK	= 0x000f,
	GMO_FCURVE_CONSTANT		= 0x0000,
	GMO_FCURVE_LINEAR		= 0x0001,
	GMO_FCURVE_HERMITE		= 0x0002,
	GMO_FCURVE_CUBIC		= 0x0003,
	GMO_FCURVE_SPHERICAL	= 0x0004,
	
	GMO_FCURVE_EXTRAP_MASK	= 0xff00,
	GMO_FCURVE_HOLD			= 0x0000,
	GMO_FCURVE_CYCLE		= 0x1100,
	GMO_FCURVE_SHUTTLE		= 0x2200,
	GMO_FCURVE_REPEAT		= 0x3300,
	GMO_FCURVE_EXTEND		= 0x4400,
	
	GMO_FCURVE_EXTRAP_LEFT_MASK	= 0x0f00,
	GMO_FCURVE_HOLD_LEFT		= 0x0000,
	GMO_FCURVE_CYCLE_LEFT		= 0x0100,
	GMO_FCURVE_SHUTTLE_LEFT		= 0x0200,
	GMO_FCURVE_REPEAT_LEFT		= 0x0300,
	GMO_FCURVE_EXTEND_LEFT		= 0x0400,
	
	GMO_FCURVE_EXTRAP_RIGHT_MASK	= 0xf000,
	GMO_FCURVE_HOLD_RIGHT			= 0x0000,
	GMO_FCURVE_CYCLE_RIGHT			= 0x1000,
	GMO_FCURVE_SHUTTLE_RIGHT		= 0x2000,
	GMO_FCURVE_REPEAT_RIGHT			= 0x3000,
	GMO_FCURVE_EXTEND_RIGHT			= 0x4000
};

enum {
	GMO_PRIM_SEQUENTIAL		= 0x0100,
	
	GMO_PRIM_TYPE_MASK		= 0x000f,
	GMO_PRIM_POINTS			= 0x0000,
	GMO_PRIM_LINES			= 0x0001,
	GMO_PRIM_LINE_STRIP		= 0x0002,
	GMO_PRIM_TRIANGLES		= 0x0003,
	GMO_PRIM_TRIANGLE_STRIP	= 0x0004,
	GMO_PRIM_TRIANGLE_FAN	= 0x0005,
	GMO_PRIM_RECTANGLES		= 0x0006,
	
	GMO_PRIM_SPLINE_MASK	= 0xf000,
	GMO_PRIM_OPEN_U			= 0x3000,
	GMO_PRIM_OPEN_V			= 0xc000,
	GMO_PRIM_OPEN_U_IN		= 0x1000,
	GMO_PRIM_OPEN_U_OUT		= 0x2000,
	GMO_PRIM_OPEN_V_IN		= 0x4000,
	GMO_PRIM_OPEN_V_OUT		= 0x8000
};

#define CMD_TEXTURE_NONE       (0 <<  0)
#define CMD_TEXTURE_UBYTE      (1 <<  0)
#define CMD_TEXTURE_USHORT     (2 <<  0)
#define CMD_TEXTURE_FLOAT      (3 <<  0)
#define CMD_COLOR_NONE         (0 <<  2)
#define CMD_COLOR_PF5650       (4 <<  2)
#define CMD_COLOR_PF5551       (5 <<  2)
#define CMD_COLOR_PF4444       (6 <<  2)
#define CMD_COLOR_PF8888       (7 <<  2)
#define CMD_NORMAL_NONE        (0 <<  5)
#define CMD_NORMAL_BYTE        (1 <<  5)
#define CMD_NORMAL_SHORT       (2 <<  5)
#define CMD_NORMAL_FLOAT       (3 <<  5)
#define CMD_VERTEX_NONE        (0 <<  7)
#define CMD_VERTEX_BYTE        (1 <<  7)
#define CMD_VERTEX_SHORT       (2 <<  7)
#define CMD_VERTEX_FLOAT       (3 <<  7)
#define CMD_WEIGHT_NONE        (0 <<  9)
#define CMD_WEIGHT_UBYTE       (1 <<  9)
#define CMD_WEIGHT_USHORT      (2 <<  9)
#define CMD_WEIGHT_FLOAT       (3 <<  9)
#define CMD_INDEX_NONE         (0 << 11)
#define CMD_INDEX_UBYTE        (1 << 11)
#define CMD_INDEX_USHORT       (2 << 11)
#define CMD_WEIGHT_1           (0 << 14)
#define CMD_WEIGHT_2           (1 << 14)
#define CMD_WEIGHT_3           (2 << 14)
#define CMD_WEIGHT_4           (3 << 14)
#define CMD_WEIGHT_5           (4 << 14)
#define CMD_WEIGHT_6           (5 << 14)
#define CMD_WEIGHT_7           (6 << 14)
#define CMD_WEIGHT_8           (7 << 14)
#define CMD_VERTEX_1           (0 << 18)
#define CMD_VERTEX_2           (1 << 18)
#define CMD_VERTEX_3           (2 << 18)
#define CMD_VERTEX_4           (3 << 18)
#define CMD_VERTEX_5           (4 << 18)
#define CMD_VERTEX_6           (5 << 18)
#define CMD_VERTEX_7           (6 << 18)
#define CMD_VERTEX_8           (7 << 18)
#define CMD_THROUGH            (1 << 23)

#define CMD_VF_NONE            (0)
#define CMD_VF_BYTE            (1)
#define CMD_VF_SHORT           (2)
#define CMD_VF_FLOAT           (3)
#define CMD_VF_PF5650          (4)
#define CMD_VF_PF5551          (5)
#define CMD_VF_PF4444          (6)
#define CMD_VF_PF8888          (7)
#define CMD_VF_TEXTURE(t)      (((t)&3)<<0)
#define CMD_VF_COLOR(t)        (((t)&7)<<2)
#define CMD_VF_NORMAL(t)       (((t)&3)<<5)
#define CMD_VF_VERTEX(t)       (((t)&3)<<7)
#define CMD_VF_WEIGHT(t)       (((t)&3)<<9)
#define CMD_VF_INDEX(t)        (((t)&3)<<11)
#define CMD_VF_WEIGHTS(t)      ((((t)-1)&7)<<14)
#define CMD_VF_MORPHS(t)       ((((t)-1)&7)<<18)
#define CMD_VF_TEXTURE_TYPE(f) (((f)>>0)&3)
#define CMD_VF_COLOR_TYPE(f)   (((f)>>2)&7)
#define CMD_VF_NORMAL_TYPE(f)  (((f)>>5)&3)
#define CMD_VF_VERTEX_TYPE(f)  (((f)>>7)&3)
#define CMD_VF_WEIGHT_TYPE(f)  (((f)>>9)&3)
#define CMD_VF_INDEX_TYPE(f)   (((f)>>11)&3)
#define CMD_VF_WEIGHT_COUNT(f) ((((f)>>14)&7)+1)
#define CMD_VF_MORPH_COUNT(f)  ((((f)>>18)&7)+1)


/* ---------------------------------------------------------------- */
/*  animation                                                       */
/* ---------------------------------------------------------------- */

enum {
	GMO_REPEAT_HOLD  = 0,
	GMO_REPEAT_CYCLE = 1
} ;

/* ---------------------------------------------------------------- */
/*  header structure                                                */
/* ---------------------------------------------------------------- */

typedef struct GmoHeader {
	unsigned int signature;
	unsigned int version;
	unsigned int style;
	unsigned int option;
} GmoHeader;

/* ---------------------------------------------------------------- */
/*  chunk structure                                                 */
/* ---------------------------------------------------------------- */

typedef struct GmoChunk {
	unsigned short type;
	unsigned short argsOffset;
	unsigned int nextOffset;
	unsigned int childOffset;
	unsigned int dataOffset;
} GmoChunk;

static __inline__ int GetGmoChunkType(const GmoChunk *chunk) {
	return (~GMO_HALF_CHUNK & chunk->type);
}

static __inline__ GmoChunk *GetNextGmoChunk(const GmoChunk *chunk) {
	return (GmoChunk*)((char*)chunk + chunk->nextOffset);
}

static __inline__ GmoChunk *GetChildGmoChunk(const GmoChunk *chunk) {
	if (GMO_HALF_CHUNK & chunk->type) return GetNextGmoChunk(chunk);
	return (GmoChunk*)((char*)chunk + chunk->childOffset );
}

static __inline__ char *GetGmoChunkName(const GmoChunk *chunk) {
	if (GMO_HALF_CHUNK & chunk->type) return NULL;
	return (char*)(chunk+1);
}

static __inline__ void *GetGmoChunkArgs(const GmoChunk *chunk) {
	if (GMO_HALF_CHUNK & chunk->type) return (char *)chunk + 8;
	return (char*)chunk + chunk->argsOffset;
}

/* ---------------------------------------------------------------- */
/*  bone structure                                                  */
/* ---------------------------------------------------------------- */

enum {
	GMO_BONE_IS_SCALE_STACKED	= 0x80000000,
	GMO_BONE_IS_LOCAL_DIRTY		= 0x40000000,
	GMO_BONE_IS_BLEND_DIRTY		= 0x20000000,
	
	GMO_BONE_HAS_TRANSLATE		= 0x0001,
	GMO_BONE_HAS_ROTATE			= 0x0002,
	GMO_BONE_HAS_SCALE			= 0x001c,
	GMO_BONE_HAS_SCALE_1		= 0x0004,
	GMO_BONE_HAS_SCALE_2		= 0x0008,
	GMO_BONE_HAS_SCALE_3		= 0x0010,
	GMO_BONE_HAS_MULT_MATRIX	= 0x0040,
	GMO_BONE_HAS_PIVOT			= 0x0080,
	GMO_BONE_HAS_MORPH			= 0x0300,
	GMO_BONE_HAS_MORPH_WEIGHTS	= 0x0100,
	GMO_BONE_HAS_MORPH_INDEX	= 0x0200,
	GMO_BONE_HAS_BLEND			= 0x0400,
	GMO_BONE_HAS_VISIBILITY		= 0x0800,
	GMO_BONE_HAS_COLOR			= 0x1000
};

enum {
	GMO_BONE_ANIM_MODIFIED	= 0x0000ffff,
	GMO_BONE_ANIM_COMPLETE	= 0xffff0000,
	
	GMO_BONE_CHAN_MATRIX	= 0,
	GMO_BONE_CHAN_TRANSLATE	= 1,
	GMO_BONE_CHAN_ROTATE	= 2,
	GMO_BONE_CHAN_SCALE		= 3,
	GMO_BONE_CHAN_MORPH		= 4,
	GMO_BONE_CHAN_COUNT
};


/* ---------------------------------------------------------------- */
/*  material structure                                              */
/* ---------------------------------------------------------------- */

enum {
	GMO_MATERIAL_HAS_EXPLICIT_AMBIENT		= 0x80000000,
	GMO_MATERIAL_HAS_IMPLICIT_LAYERS		= 0x00ff0000,
	GMO_MATERIAL_HAS_IMPLICIT_DIFFUSE		= 0x00010000,
	GMO_MATERIAL_HAS_IMPLICIT_EMISSION		= 0x00040000,
	GMO_MATERIAL_HAS_IMPLICIT_REFLECTION	= 0x00100000,
	
	GMO_MATERIAL_HAS_DIFFUSE		= 0x0001,
	GMO_MATERIAL_HAS_SPECULAR		= 0x0002,
	GMO_MATERIAL_HAS_EMISSION		= 0x0004,
	GMO_MATERIAL_HAS_AMBIENT		= 0x0008,
	GMO_MATERIAL_HAS_REFLECTION		= 0x0010,
	GMO_MATERIAL_HAS_REFRACTION		= 0x0020,
	GMO_MATERIAL_HAS_BUMP			= 0x0040,
	GMO_MATERIAL_HAS_TEX_CROP		= 0x0100,
	GMO_MATERIAL_HAS_TEX_CROPS		= 0xff00,
	
	GMO_MATERIAL_MAX_LAYERS		= 8
};

enum {
	GMO_MATERIAL_COLOR_BLACK		= 0,
	GMO_MATERIAL_COLOR_DIFFUSE		= 1,
	GMO_MATERIAL_COLOR_SPECULAR		= 2,
	GMO_MATERIAL_COLOR_EMISSION		= 3,
	GMO_MATERIAL_COLOR_AMBIENT		= 4,
	GMO_MATERIAL_COLOR_REFLECTION	= 5,
	GMO_MATERIAL_COLOR_COUNT
};

enum {
	GMO_MATERIAL_ANIM_MODIFIED		= 0x0000ffff,
	GMO_MATERIAL_ANIM_COMPLETE		= 0xffff0000,
	
	GMO_MATERIAL_CHAN_DIFFUSE		= 0,
	GMO_MATERIAL_CHAN_SPECULAR		= 1,
	GMO_MATERIAL_CHAN_EMISSION		= 2,
	GMO_MATERIAL_CHAN_AMBIENT		= 3,
	GMO_MATERIAL_CHAN_REFLECTION	= 4,
	GMO_MATERIAL_CHAN_COUNT
};

enum {
	GMO_ENABLE_ALL			= 0xffff,
	GMO_ENABLE_LIGHTING		= 0x0001,
	GMO_ENABLE_FOG			= 0x0002,
	GMO_ENABLE_TEXTURE		= 0x0004,
	GMO_ENABLE_CULL_FACE	= 0x0008,
	GMO_ENABLE_DEPTH_TEST	= 0x0010,
	GMO_ENABLE_DEPTH_MASK	= 0x0020,
	GMO_ENABLE_ALPHA_TEST	= 0x0040,
	GMO_ENABLE_ALPHA_MASK	= 0x0080
};

enum {
	GMO_BLEND_ADD		= 0,
	GMO_BLEND_SUB		= 1,
	GMO_BLEND_REV		= 2,
	GMO_BLEND_MIN		= 3,
	GMO_BLEND_MAX		= 4,
	GMO_BLEND_DIFF		= 5,
	
	GMO_BLEND_ZERO		= 0,	
	GMO_BLEND_ONE		= 1,	
	GMO_BLEND_SRC_COLOR		= 2,
	GMO_BLEND_INV_SRC_COLOR	= 3,
	GMO_BLEND_DST_COLOR		= 4,
	GMO_BLEND_INV_DST_COLOR	= 5,
	GMO_BLEND_SRC_ALPHA		= 6,
	GMO_BLEND_INV_SRC_ALPHA	= 7,
	GMO_BLEND_DST_ALPHA		= 8,
	GMO_BLEND_INV_DST_ALPHA	= 9	
};

/* ---------------------------------------------------------------- */
/*  layer structure                                                 */
/* ---------------------------------------------------------------- */

enum {
	GMO_LAYER_HAS_TEX_CROP = 0x0001
} ;

static __inline__ void GmoCol4BSet(GmoCol4B *dst, byte r, byte g, byte b, byte a) {
	dst->r = r;
	dst->g = g;
	dst->b = b;
	dst->a = a;
}

static __inline__ void GmoCol4FToGmoCol4B(GmoCol4B *dst, GmoCol4F *src) {
	dst->r = (byte)(src->r*255.0f);
	dst->g = (byte)(src->g*255.0f);
	dst->b = (byte)(src->b*255.0f);
	dst->a = (byte)(src->a*255.0f);
}

static __inline__ void GmoRectSet(GmoRectF *dst, float x, float y, float w, float h) {
	dst->x = x;
	dst->y = y;
	dst->w = w;
	dst->h = h;
}

static __inline__ void GmoRectCopy(GmoRectF *dst, const GmoRectF *src) {
	dst->x = src->x;
	dst->y = src->y;
	dst->w = src->w;
	dst->h = src->h;
}

enum {
	GMO_STATE_LIGHTING		= 0,
	GMO_STATE_FOG			= 1,
	GMO_STATE_TEXTURE		= 2,
	GMO_STATE_CULL_FACE		= 3,
	GMO_STATE_DEPTH_TEST	= 4,
	GMO_STATE_DEPTH_MASK	= 5,
	GMO_STATE_ALPHA_TEST	= 6,
	GMO_STATE_ALPHA_MASK	= 7,
};

/* ---------------------------------------------------------------- */
/*  block reference type                                            */
/* ---------------------------------------------------------------- */

#define GMO_REF_TYPE(ref) (0x7fff&((ref)>>16))
#define GMO_REF_LEVEL(ref) (0x000f&((ref)>>12))
#define GMO_REF_INDEX(ref) (0x0fff&(ref))

/* ---------------------------------------------------------------- */
/*  command args ( common commands )                                */
/* ---------------------------------------------------------------- */

typedef struct {
	char name[1];
} GmoFileName;

typedef struct {
	int size;
	int data[1];
} GmoFileImage;

typedef struct {
	GmoVec3F lower;
	GmoVec3F upper;
} GmoBoundingBox;
/*
typedef struct {
	int n_points;
	SceGmoVec3F points[1];
} GmoBoundingPoints;
*/
typedef struct {
	int format;
	float offset[1];
} GmoVertexOffset;

/* ---------------------------------------------------------------- */
/*  block args                                                      */
/* ---------------------------------------------------------------- */

typedef struct {
	int format;
	int n_verts;
	int n_morphs;
	int format2;
} GmoArraysHeader;

typedef struct {
	int format;
	int n_dims;
	int n_keys;
	int reserved;
} GmoFCurveHeader;

/* ---------------------------------------------------------------- */
/*  command args ( bone commands )                                  */
/* ---------------------------------------------------------------- */

typedef struct {
	int bone;
} GmoParentBone;

typedef struct {
	int visibility;
} GmoVisibility;

typedef struct {
	int n_weights;
	float weights[ 1 ];
} GmoMorphWeights;

typedef struct {
	float index;
} GmoMorphIndex;

typedef struct {
	int n_bones;
	int bones[ 1 ];
} GmoBlendBones;

typedef struct {
	int n_offsets;
	GmoMat4F offsets[1];
} GmoBlendOffsets;

typedef struct {
	GmoVec3F pivot;
} GmoPivot;

typedef struct {
	GmoMat4F matrix;
} GmoMultMatrix;

typedef struct {
	GmoVec3F translate;
} GmoTranslate;

typedef struct {
	GmoVec3F rotate;
} GmoRotateZYX;

typedef struct {
	GmoVec3F rotate;
} GmoRotateYXZ;

typedef struct {
	GmoQuatF rotate;
} GmoRotateQ;

typedef struct {
	GmoVec3F scale;
} GmoScale;

typedef struct {
	GmoVec3F scale;
} GmoScale2;

typedef struct {
	GmoVec3F scale;
} GmoScale3;

typedef struct {
	int part;
} GmoDrawPart;

typedef struct {
	int state;
	int value;
} GmoBoneState;

/* ---------------------------------------------------------------- */
/*  command args ( mesh commands )                                  */
/* ---------------------------------------------------------------- */

typedef struct {
	int material;
} GmoSetMaterial;

typedef struct {
	int n_indices;
	int indices[1];
} GmoBlendSubset;

typedef struct {
	int arrays;
	int mode;
	int n_verts;
	int n_prims;
	unsigned short indices[1];
} GmoDrawArrays;


/* ---------------------------------------------------------------- */
/*  command args ( material commands )                              */
/* ---------------------------------------------------------------- */

typedef struct {
	int state;
	int value;
} GmoRenderState;

typedef struct {
	GmoCol4F color;
} GmoDiffuse;

typedef struct {
	GmoCol4F color;
	float shininess;
} GmoSpecular;

typedef struct {
	GmoCol4F color;
} GmoEmission;

typedef struct {
	GmoCol4F color;
} GmoAmbient;

typedef struct {
	float reflection;
} GmoReflection;

typedef struct {
	float refraction;
} GmoRefraction;

typedef struct {
	float bump;
} GmoBump;

/* ---------------------------------------------------------------- */
/*  command args ( layer commands )                                 */
/* ---------------------------------------------------------------- */

typedef struct {
	int texture;
} GmoSetTexture;

typedef struct {
	int type;
} GmoMapType;

typedef struct {
	float factor;
} GmoMapFactor;

typedef struct {
	int mode;
	int src;
	int dst;
} GmoBlendFunc;

typedef struct {
	int func;
	int comp;
} GmoTexFunc;

typedef struct {
	int mag;
	int min;
} GmoTexFilter;

typedef struct {
	int wrap_u;
	int wrap_v;
} GmoTexWrap;

typedef struct {
	GmoRectF crop;
} GmoTexCrop;

/* ---------------------------------------------------------------- */
/*  command args ( motion commands )                                */
/* ---------------------------------------------------------------- */

typedef struct {
	float start;
	float end;
} GmoFrameLoop;

typedef struct {
	float fps;
} GmoFrameRate;

typedef struct {
	int mode;
} GmoFrameRepeat;

typedef struct {
	int block;
	int cmd;
	int index;
	int fcurve;
} GmoAnimate;

#define SHORTX_TO_FLOAT(x) (((float)x)/32768.0f)
#define BYTEX_TO_FLOAT(x) (((float)x)/128.0f)
#define USHORTX_TO_FLOAT(x) (((float)x)/32768.0f)
#define UBYTEX_TO_FLOAT(x) (((float)x)/128.0f)

#define MAX_BLEND_COUNT 4

/*******************************************************************
 * Objective C structures
 *******************************************************************/

@interface NezGmoPart : NSObject {
	
@public
	NSMutableArray *meshArray;
	NSMutableArray *vertexArrayArray; //Array of NSMutableArray. The inside array contains the list of vertexes
	NSMutableArray *blendOffsetArray;
	NSMutableArray *blendIndexArray;
	int boneIndex;
}

+(NezGmoPart*) makeNezGmoPart;

@end

@interface NezGmoMesh : NSObject {
	
@public
	NSMutableArray *blendOffsetIndexArray;
	NSMutableArray *indexArrayArray; //Array of NSMutableArray. The inside array contains the list of indexes
	NSMutableArray *vertexArrayIndexArray;
	int materialIndex;
}

+(NezGmoMesh*) makeNezGmoMesh;

@end

@interface NezGmoBone : NSObject {

@public
	NSString *name;
	int parent;
	float translate[3];
	float pivot[3];
	float scale[3];
	float quaternion[4];
	float inverseQuaternion[4];
	float matrix[16];
	float inverseMatrix[16];
	unsigned int flags;
	int visibility;
	int partIndex;
}

+(NezGmoBone*) makeNezGmoBone;

@end

@interface NezGmoVertex : NSObject {
	
@public
	
	float pos[3];
	float normal[3];
	float uv[2];
	unsigned char color[4];
	unsigned char blendCount;
	unsigned char blendOffsetIndexList[MAX_BLEND_COUNT];
	unsigned char blendIndexList[MAX_BLEND_COUNT];
	float boneWeightList[MAX_BLEND_COUNT];
	int materialIndex;
	float normalSumation[3];
	int normalAdds;
}

+(NezGmoVertex*) makeNezGmoVertex;
	
@end
	
@interface NezGmoMatrix : NSObject {
	
@public
	
	GmoMat4F matrix;
}

+(NezGmoMatrix*) makeNezGmoMatrixWithGmoMat4F:(GmoMat4F*)mat4F;
- (id)initWithGmoMat4F:(GmoMat4F*)mat4F;

@end

@interface NezGmoMaterial : NSObject {
	
@public
	int flags;
	
	NSMutableArray *layerArray;
	
	int enableMask;
	int enableBits;
	GmoCol4B colors[GMO_MATERIAL_COLOR_COUNT];
	float shininess;
	float refraction;
	float bump;
	
	int animFlags;
	float animWeights[GMO_MATERIAL_CHAN_COUNT];
}

+(NezGmoMaterial*) makeNezGmoMaterial;

@end

@interface NezGmoLayer : NSObject {
	
@public
	int flags;
	
	int mapType;
	float mapFactor;
	int blendFunc[3];
	int texture;
	
	unsigned int enableMask;
	unsigned int enableBits;
	int diffuse;
	int specular;
	int ambient;
	
	GmoRectF texCrop;
}

+(NezGmoLayer*) makeNezGmoLayer;

@end

@interface NezGmoMotion : NSObject {
	
@public
	int flags;
	
	NSMutableArray *animationArray;
	NSMutableArray *fCurveArray;
	
	float frameLoop[2];
	float frameRate;
	int frameRepeat;
	float frame;
	float weight;
}

+(NezGmoMotion*) makeNezGmoMotion;

@end

@interface NezGmoAnimate : NSObject {
	
@public
	int type;
	int index;
	int cmd;
	int dataIndex;
	int fCurve;
}

+(NezGmoAnimate*) makeNezGmoAnimate;

@end

@interface NezGmoFCurve : NSObject {
	
@public
	int format;
	int dims;
	int keys;
	unsigned char *data;
}

+(NezGmoFCurve*) makeNezGmoFCurve;

@end




