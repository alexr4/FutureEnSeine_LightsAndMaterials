//Simple diffuse shader
#version 130
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D sprite;

in vec4 vertColor;
in vec4 vertTexCoord;


out vec4 fragColor;
void main()
{
	//textures
	vec4 texdiffuse = texture2D(sprite, vertTexCoord.xy);
	vec4 Albedo = texdiffuse * vertColor;
	
	//fragColor = texdiffuse * vertColor;
	fragColor = gl_FrontFacing ? Albedo : Albedo;
}