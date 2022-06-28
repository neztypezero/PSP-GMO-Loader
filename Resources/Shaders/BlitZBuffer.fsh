//
//  Shader.fsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright NezSoft 2010. All rights reserved.
//
precision mediump float;

varying vec4 v_pos;

const vec4 packFactors = vec4(256.0*256.0*256.0, 256.0*256.0, 256.0, 1.0);
const vec4 bitMask     = vec4(0.0, 1.0/256.0, 1.0/256.0, 1.0/256.0);

void main() {
	float normalizedDistance  = v_pos.z / v_pos.w;
	normalizedDistance = (normalizedDistance + 1.0) / 2.0;

	vec4 packedValue = vec4(fract(packFactors*normalizedDistance));
	packedValue -= packedValue.xxyz * bitMask;

	gl_FragColor = packedValue;
}
