//
//  NezBonedModelStructures.h
//  GmoLoader
//
//  Created by David Nesbitt on 9/7/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#define MATRIX_PALETTE_ENTRIES 48
#ifndef MAX_BLEND_COUNT
	#define MAX_BLEND_COUNT 4
#endif

#define PART_INVISIBLE 1

#define THIRTY_FRAMES_PER_SECOND 30

#define FOV_60_DEGREES 1.04719755f
#define FOV_90_DEGREES 1.57079632f

typedef struct TextureInfo {
	unsigned int name;
	unsigned int width;
	unsigned int height;
} TextureInfo;

typedef struct vec2 {
	float x, y;
} vec2;

typedef struct vec3 {
	float x, y, z;
} vec3;

typedef struct vec4 {
	float x, y, z, w;
} vec4;

typedef struct Bone {
	int parent;
	float inverseMatrix[16];
	float currentMatrix[16];
	float rotate[4];
	float scale[3];
	float translate[3];
	unsigned int updateFlags;
	int partIndex;
} Bone;

typedef struct Vertex2D {
	vec2 pos;
	vec2 uv;
} Vertex2D;

typedef struct Vertex {
	float pos[3];
	float normal[3];
	float uv[2];
	unsigned char color[4];
	unsigned char indexArray[MAX_BLEND_COUNT];
	float weightArray[MAX_BLEND_COUNT];
} Vertex;

typedef struct IndexArray {
	unsigned int vboPtr;
	int indexCount;
	int vertexArrayIndex;
} IndexArray;

typedef struct Mesh {
	IndexArray *indexArrayArray;
	int indexArrayCount;
	int materialIndex;
	
	unsigned short *blendIndexArray;
	int blendIndexCount;
} Mesh;

typedef struct VertexArray {
	unsigned int vboPtr;
	int maxBlendCount;
	int vertexCount;
	int vertexStride;
} VertexArray;

typedef struct Part {
	VertexArray *vertexArrayArray;
	int vertexArrayCount;
	
	Mesh *meshArray;
	int meshCount;
	
	unsigned short *boneIndexArray;
	int boneIndexCount;
	
	int state;
} Part;

typedef struct Layer {
	int blendFunc[3];
	int textureIndex;
} Layer;

typedef struct Material {
	Layer *layerArray;
	int layerCount;
	unsigned int enableMask;
	unsigned int enableBits;
} Material;

