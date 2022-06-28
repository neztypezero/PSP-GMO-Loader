//
//  Shader.fsh
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright NezSoft 2010. All rights reserved.
//

precision highp float;

uniform float u_frequency;
uniform vec4 u_color0;
uniform vec4 u_color1;

uniform sampler2D u_shadowMapSampler;

varying vec2 v_uv;
varying vec4 v_shadowCoord;

const vec4 bitShifts = vec4(1.0/(256.0*256.0*256.0), 1.0/(256.0*256.0), 1.0/256.0, 1.0);
	
void main() {
	vec4 shadowCoordinateWdivide = v_shadowCoord / v_shadowCoord.w;
	
	// Used like pixel offset
	shadowCoordinateWdivide.z += 0.0039;
	
	float distanceFromLight = dot(texture2D(u_shadowMapSampler,shadowCoordinateWdivide.st), bitShifts);
 	float shadow = 1.0;
 	if (v_shadowCoord.w > 1.0) {
 		shadow = distanceFromLight < shadowCoordinateWdivide.z ? 0.8 : 1.0;
	}

	vec2 texcoord = mod(floor(v_uv * (u_frequency * 2.0)), 2.0); 
	float delta = abs(texcoord.x - texcoord.y);
	
	gl_FragColor = mix(u_color0, u_color1, delta)*shadow;
}
