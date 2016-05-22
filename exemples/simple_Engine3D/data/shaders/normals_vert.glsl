uniform mat4 transform;

in vec4 vertex;
in vec3 normal;

out vec4 vertColor;

void main()
{
	vertColor = vec4(normal.xyz, 1);

	gl_Position = transform * vertex;
}