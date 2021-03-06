//
//  GLSLProgram.h
//  GmoLoader
//
//  Created by David Nesbitt on 9/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define MAX_NAME_LENGTH 32

@interface GLSLProgram : NSObject {
@public
	GLuint program;
	GLint a_color;
	GLint a_indexArray;
	GLint a_weightArray;
	GLint a_uv;
	GLint a_position;
	GLint a_normal;
	GLint u_textureMatrix;
	GLint u_shadowMapPixelHeight;
	GLint u_matPal;
	GLint u_color1;
	GLint u_color0;
	GLint u_sampler;
	GLint u_frequency;
	GLint u_blendCount;
	GLint u_shadowMapPixelWidth;
	GLint u_modelViewProjectionMatrix;
	GLint u_haloScale;
	GLint u_shadowMapSampler;
}

- (id)initWithProgramName:(NSString*)programName;

@end

