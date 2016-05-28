uniform mat4 transform;
uniform mat4 modelview;

in vec4 vertex;

out vec4 vertColor;

void main()
{
	vec4 pos = modelview * vertex;
	vertColor = vec4(pos.xyz, 1);

	gl_Position = transform * vertex;
}