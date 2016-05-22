//Simple diffuse shader
#version 130
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

in vec4 vertColor;
in vec3 rimVDN;

uniform float rimPower = 0.65;

out vec4 fragColor;
void main()
{
	vec4 rimsmooth = vec4(smoothstep(rimPower, 1.0, rimVDN), 1.0);
	
	fragColor =  rimsmooth;
	//fragColor = gl_FrontFacing ? rimsmooth + vertColor : rimsmooth + vertColor;
}