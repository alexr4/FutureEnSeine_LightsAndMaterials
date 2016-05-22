//Simple iridescent shader based on Diego Inàcio implementation (https://vimeo.com/83798053)
uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;

in vec4 vertex;
in vec3 normal;
in vec4 color;

out vec4 vertColor;
out vec3 ecVertex;
out vec3 ecNormal;

void main()
{
	vertColor = color;

	ecVertex = vec3(modelview * vertex);
	ecNormal = normalize(normalMatrix * normal);

	gl_Position = transform * vertex;
}