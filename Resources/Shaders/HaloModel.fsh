//
//  Shader.fsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright NezSoft 2010. All rights reserved.
//
precision mediump float;

uniform sampler2D u_sampler;

varying vec2 v_uv;
//varying vec4 v_color;

void main() {
	if (texture2D(u_sampler, v_uv).a < 0.9) {
		discard;
	} else {
		gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0);
	}
}
