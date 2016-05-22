#version 430
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec4 nearColor = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 farColor = vec4(0.0, 0.0, 0.0, 1.0);
uniform float near = 0.0;
uniform float far = 4500.0;

in vec4 vertColor;

out vec4 fragColor;

// In the default shader we won't be able to access the shadowMap's depth anymore,
// just the color, so this function will pack the 16bit depth float into the first
// two 8bit channels of the rgba vector.
vec4 packDepth(float depth) {
    float depthFrac = fract(depth * 255.0);
    return vec4(depth - depthFrac / 255, depthFrac, 1.0, 1.0);
}
void main()
{
	//depth informations
	float depth = smoothstep(near, far, gl_FragCoord.z / gl_FragCoord.w);
	
	fragColor = packDepth(depth);
	//fragColor = gl_FrontFacing ? mix(nearColor, farColor, depth) : mix(nearColor, farColor, depth);
}