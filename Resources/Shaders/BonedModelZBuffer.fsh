//
//  Shader.fsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright NezSoft 2010. All rights reserved.
//
precision mediump float;

varying vec2 v_uv;
varying vec4 v_pos;

uniform sampler2D u_sampler;

const vec4 packFactors = vec4(256.0*256.0*256.0, 256.0*256.0, 256.0, 1.0);
const vec4 bitMask     = vec4(0.0,1.0/256.0,1.0/256.0,1.0/256.0);

void main() {
	gl_FragColor = texture2D(u_sampler, v_uv);
	if (gl_FragColor.a < 0.9) {
		discard;
	} else {
		float normalizedDistance  = v_pos.z / v_pos.w;
		normalizedDistance = (normalizedDistance + 1.0) / 2.0;

		vec4 packedValue = vec4(fract(packFactors*normalizedDistance));
		packedValue -= packedValue.xxyz * bitMask;

		gl_FragColor = packedValue;
	}
}