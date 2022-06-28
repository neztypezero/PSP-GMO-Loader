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

uniform mat4 u_modelViewProjectionMatrix;

void main() {
	gl_Position = u_modelViewProjectionMatrix * a_position;
	v_uv = a_uv;
}
