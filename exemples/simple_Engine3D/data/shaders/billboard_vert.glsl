//Simple diffuse shader
uniform mat4 projection; //clip coordinate
uniform mat4 modelview; // eye coordinate

uniform float weight;

in vec4 vertex;
in vec4 color;
in vec2 offset;

out vec4 vertColor;
out vec4 vertTexCoord;

void main()
{

	vec4 pos = modelview * vertex;
	vec4 clip = projection * pos;

	vertColor = color;
	vertTexCoord =  vec4(vec2(vec2(0.5) + offset / weight).xy, 1.0, 1.0);

	gl_Position = clip + projection * vec4(offset.xy, 0, 0);
}