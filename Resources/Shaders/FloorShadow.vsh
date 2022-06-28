//
//  Shader.vsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright NezSoft 2010. All rights reserved.
//

attribute vec4 a_position;
attribute vec2 a_uv;

varying vec2 v_uv;
varying vec4 v_shadowCoord;

uniform mat4 u_modelViewProjectionMatrix;
uniform mat4 u_textureMatrix;

void main() {
	gl_Position = u_modelViewProjectionMatrix * a_position;
	v_shadowCoord = u_textureMatrix * a_position;
	v_uv = a_uv;
}
