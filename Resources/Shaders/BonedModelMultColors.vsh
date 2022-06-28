//
//  Shader.vsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright NezSoft 2010. All rights reserved.
//

//precision mediump float;

const int NUM_MATRICES = 48; // 32 matrices in matrix palette

const int c_0 = 0;
const int c_1 = 1;
const int c_2 = 2;
const int c_3 = 3;

attribute vec4 a_position;
attribute vec3 a_normal;
attribute vec2 a_uv;
attribute vec4 a_color;

attribute vec4 a_indexArray;
attribute vec4 a_weightArray;

varying vec2 v_uv;
varying vec4 v_color;

uniform mat4 u_modelViewProjectionMatrix;
uniform vec4 u_matPal[NUM_MATRICES*c_3];
uniform int u_blendCount;

void main() {
	if (u_blendCount > c_0) {
		int mIdx = int(a_indexArray[c_0])*c_3;
		vec4 pos = vec4(dot(a_position, u_matPal[mIdx]), dot(a_position, u_matPal[mIdx+c_1]), dot(a_position, u_matPal[mIdx+c_2]), a_position.w)*a_weightArray[c_0];
//		vec3 normal = vec3(dot(a_normal, u_matPal[mIdx].xyz), dot(a_normal, u_matPal[mIdx+c_1].xyz), dot(a_normal, u_matPal[mIdx+c_2].xyz))*a_weightArray[c_0];

		if (u_blendCount > c_1) {
			mIdx = int(a_indexArray[c_1])*c_3;
			pos += vec4(dot(a_position, u_matPal[mIdx]), dot(a_position, u_matPal[mIdx+c_1]), dot(a_position, u_matPal[mIdx+c_2]), a_position.w)*a_weightArray[c_1];
//			normal += vec3(dot(a_normal, u_matPal[mIdx].xyz), dot(a_normal, u_matPal[mIdx+c_1].xyz), dot(a_normal, u_matPal[mIdx+c_2].xyz))*a_weightArray[c_1];
		}
		if (u_blendCount > c_2) {
			mIdx = int(a_indexArray[c_2])*c_3;
			pos += vec4(dot(a_position, u_matPal[mIdx]), dot(a_position, u_matPal[mIdx+c_1]), dot(a_position, u_matPal[mIdx+c_2]), a_position.w)*a_weightArray[c_2];
//			normal += vec3(dot(a_normal, u_matPal[mIdx].xyz), dot(a_normal, u_matPal[mIdx+c_1].xyz), dot(a_normal, u_matPal[mIdx+c_2].xyz))*a_weightArray[c_2];
		}
		if (u_blendCount > c_3) {
			mIdx = int(a_indexArray[c_3])*c_3;
			pos += vec4(dot(a_position, u_matPal[mIdx]), dot(a_position, u_matPal[mIdx+c_1]), dot(a_position, u_matPal[mIdx+c_2]), a_position.w)*a_weightArray[c_3];
//			normal += vec3(dot(a_normal, u_matPal[mIdx].xyz), dot(a_normal, u_matPal[mIdx+c_1].xyz), dot(a_normal, u_matPal[mIdx+c_2].xyz))*a_weightArray[c_3];
		}
		gl_Position = u_modelViewProjectionMatrix * (pos);
	} else {
		gl_Position = u_modelViewProjectionMatrix * (a_position);
	}
	v_uv = a_uv;
	v_color = a_color;
}
