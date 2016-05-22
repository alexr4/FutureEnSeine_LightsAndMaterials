uniform mat4 transform;

in vec4 vertex;
in vec4 color;

out vec4 vertColor;

void main()
{
	vertColor = color;

	gl_Position = transform * vertex;
}