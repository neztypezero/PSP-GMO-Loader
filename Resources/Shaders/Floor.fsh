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

varying vec2 v_uv;

void main() {
	vec2 texcoord = mod(floor(v_uv * (u_frequency * 2.0)), 2.0); 
	float delta = abs(texcoord.x - texcoord.y);

	gl_FragColor = mix(u_color0, u_color1, delta);
}
