//Simple diffuse shader
#version 130
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 tiling = vec2(1.0, 1.0);

in vec4 vertColor;
in vec4 vertTexCoord;


out vec4 fragColor;
void main()
{
	vec2 tilingPhase = fract(vertTexCoord.st / tiling.xy);
	//textures
	vec4 texdiffuse = texture2D(texture, tilingPhase);
	
	//fragColor = texdiffuse;
	fragColor = gl_FrontFacing ? texdiffuse : texdiffuse;
}