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

void main() {
	gl_Position = a_position;
	v_uv = a_uv;
}
