uniform mat4 transform;

in vec4 vertex;

out vec4 vertColor;

void main()
{
	vertColor = vec4(1, 1, 1, 1);

	gl_Position = transform * vertex;
}