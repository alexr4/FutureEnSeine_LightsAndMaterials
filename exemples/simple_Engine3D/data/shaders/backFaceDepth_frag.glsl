#version 130
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

// just the color, so this function will pack the 16bit depth float into the first 2 channels
vec4 packDepth(float depth) {
    float depthFrac = fract(depth * 255.0);
    return vec4(depth - depthFrac / 255, depthFrac, 1.0, 1.0);
}
void main()
{
	//depth informations
	float depth = smoothstep(near, far, gl_FragCoord.z / gl_FragCoord.w);

	
	//fragColor = vec4(depth, depth, depth, 1.0);//packDepth(depth); if you want to encode depth into 16Bit texture and hav more than 255 level of depth
	//fragColor = gl_FrontFacing ? mix(nearColor, farColor, depth); : mix(nearColor, farColor, depth);
	if(gl_FrontFacing)
	{
		discard;
	}
	else
	{
		fragColor = vec4(depth, depth, depth, 1.0);
	}
}