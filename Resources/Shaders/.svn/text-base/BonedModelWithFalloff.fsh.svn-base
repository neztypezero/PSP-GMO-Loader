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
varying float v_distanceFalloff;

uniform sampler2D u_sampler;

void main() {
	gl_FragColor = texture2D(u_sampler, v_uv);
	if (gl_FragColor.a < 0.9) {
		discard;
	} else {
		gl_FragColor *= vec4(v_distanceFalloff, v_distanceFalloff, v_distanceFalloff, 1.0);
	}
}
