//Simple diffuse shader
#version 130
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D displacementMap;

in vec4 vertColor;
in vec4 vertTexCoord;


out vec4 fragColor;
void main()
{
	//textures
	vec4 texdiffuse = texture2D(displacementMap, vertTexCoord.st);
	
	//fragColor = texdiffuse;
	fragColor = gl_FrontFacing ? texdiffuse : vertColor;
}