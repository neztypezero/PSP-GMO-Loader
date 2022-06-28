//
//  Shader.fsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright NezSoft 2010. All rights reserved.
//
precision highp float;

uniform sampler2D u_sampler;
uniform sampler2D u_shadowMapSampler;
uniform float u_shadowMapPixelWidth;
uniform float u_shadowMapPixelHeight;

varying vec2 v_uv;
varying vec4 v_shadowCoord;

const vec4 bitShifts = vec4(1.0/(256.0*256.0*256.0), 1.0/(256.0*256.0), 1.0/256.0, 1.0);

void main() {
	gl_FragColor = texture2D(u_sampler, v_uv);
	if (gl_FragColor.a < 0.9) {
		discard;
	} else {
//		vec4 shadowCoordinateWdivide = v_shadowCoord / v_shadowCoord.w;
		// Used like pixel offset
//		shadowCoordinateWdivide.z += 0.0035;
		
//		float distanceFromLight = dot(texture2D(u_shadowMapSampler, shadowCoordinateWdivide.st), bitShifts);
//		if (distanceFromLight < shadowCoordinateWdivide.z) {
//			gl_FragColor = vec4(1.0,0.0,0.0,1.0);//vec4(gl_FragColor.rgb*0.8, gl_FragColor.a);
//		}

		if(v_shadowCoord.z > 0.0) {
			vec4 shadowCoordinateWdivide = v_shadowCoord / v_shadowCoord.w;
			float x,y;

			float distanceFromLight = 0.0;
			float shadow = 0.0;
			
			shadowCoordinateWdivide.z += 0.0035;
			for (y = -1.5 ; y <=1.5 ; y+=1.0) {
				for (x = -1.5 ; x <=1.5 ; x+=1.0) {
					vec2 mapOffset = vec2(x, y)/vec2(u_shadowMapPixelWidth, u_shadowMapPixelHeight);
					float distanceFromLight = dot(texture2D(u_shadowMapSampler, shadowCoordinateWdivide.st+mapOffset), bitShifts);
					if (distanceFromLight < shadowCoordinateWdivide.z) {
						shadow += 1.0;//vec4(gl_FragColor.rgb*0.8, gl_FragColor.a);
					}
				}
			}
			shadow /= 16.0;
			if (shadow > 0.0) {
				gl_FragColor = vec4(vec3(0.8+(0.2*(1.0-shadow)), 0.0, 0.0), gl_FragColor.a);
//				gl_FragColor = vec4(gl_FragColor.rgb*(0.8+(0.2*(1.0-shadow))), gl_FragColor.a);
			}
		}
	}
}
