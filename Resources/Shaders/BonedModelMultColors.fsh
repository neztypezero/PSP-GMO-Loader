//
//  Shader.fsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright NezSoft 2010. All rights reserved.
//
precision mediump float;

varying vec2 v_uv;
varying vec4 v_color;

uniform sampler2D u_sampler;

void main() {
	gl_FragColor = texture2D(u_sampler, v_uv)*v_color;
}
