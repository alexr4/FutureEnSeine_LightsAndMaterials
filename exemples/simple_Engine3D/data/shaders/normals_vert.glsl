uniform mat4 transform;
uniform mat3 normalMatrix;

in vec4 vertex;
in vec3 normal;

out vec4 vertColor;

void main()
{
	vec3 norm = normalMatrix * normal;
	vertColor = vec4(norm.xyz, 1);

	gl_Position = transform * vertex;
}